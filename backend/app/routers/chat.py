"""
Campus AI Assistant — Chat Router

Manages chat sessions and the main AI conversation endpoint.
- POST /chat              — send a message and get an AI reply
- GET  /chat/sessions     — list all sessions for the current user
- POST /chat/sessions     — create a new chat session
- GET  /chat/history/{id} — fetch messages in a session
"""

from datetime import datetime, timezone
from typing import List
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.database import get_supabase_admin_client
from app.dependencies import get_current_user
from app.models.schemas import (
    ChatRequest,
    ChatResponse,
    ErrorResponse,
    MessageResponse,
    SessionCreateRequest,
    SessionResponse,
)
from app.services.llm_service import get_ai_response
from app.services.summarization_service import update_session_summary_if_needed

router = APIRouter()


async def _ensure_user_exists(user: dict, db: Client) -> None:
    """Ensure the user has a row in public.users.

    The Flutter app authenticates directly with Supabase Auth, which
    creates a record in auth.users but NOT in public.users. Since
    chat_sessions.user_id references public.users(id), we need to
    auto-create this row on first API call.
    """
    try:
        existing = (
            db.table("users")
            .select("id")
            .eq("id", user["id"])
            .execute()
        )
        if not existing.data:
            db.table("users").insert({
                "id": user["id"],
                "email": user.get("email", ""),
            }).execute()
    except Exception:
        pass  # Best-effort — if it already exists, ignore


# ------------------------------------------------------------------
# Sessions
# ------------------------------------------------------------------

@router.get(
    "/sessions",
    response_model=List[SessionResponse],
    summary="List chat sessions for the current user",
)
async def list_sessions(
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
) -> List[SessionResponse]:
    """Return all chat sessions for the authenticated user, newest first."""
    try:
        result = (
            db.table("chat_sessions")
            .select("*")
            .eq("user_id", user["id"])
            .order("updated_at", desc=True)
            .execute()
        )
        return [SessionResponse(**row) for row in (result.data or [])]

    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to list sessions: {str(exc)}",
        ) from exc


@router.post(
    "/sessions",
    response_model=SessionResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new chat session",
)
async def create_session(
    body: SessionCreateRequest,
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
) -> SessionResponse:
    """Create a new chat session for the authenticated user."""
    await _ensure_user_exists(user, db)
    try:
        result = (
            db.table("chat_sessions")
            .insert({
                "user_id": user["id"],
                "title": body.title or "New Chat",
            })
            .execute()
        )

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create session",
            )

        return SessionResponse(**result.data[0])

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create session: {str(exc)}",
        ) from exc


# ------------------------------------------------------------------
# Chat History
# ------------------------------------------------------------------

@router.get(
    "/history/{session_id}",
    response_model=List[MessageResponse],
    responses={404: {"model": ErrorResponse}},
    summary="Fetch messages in a chat session",
)
async def get_chat_history(
    session_id: UUID,
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
) -> List[MessageResponse]:
    """Return all messages in a session, ordered chronologically.

    Verifies that the session belongs to the authenticated user.
    """
    # Verify ownership
    session = (
        db.table("chat_sessions")
        .select("user_id")
        .eq("id", str(session_id))
        .single()
        .execute()
    )
    if not session.data or session.data["user_id"] != user["id"]:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Session not found",
        )

    try:
        result = (
            db.table("chat_messages")
            .select("*")
            .eq("session_id", str(session_id))
            .order("created_at", desc=False)
            .execute()
        )
        return [MessageResponse(**row) for row in (result.data or [])]

    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch history: {str(exc)}",
        ) from exc


# ------------------------------------------------------------------
# Main AI Chat Endpoint
# ------------------------------------------------------------------

@router.post(
    "",
    response_model=ChatResponse,
    responses={400: {"model": ErrorResponse}, 500: {"model": ErrorResponse}},
    summary="Send a message and get an AI reply",
)
async def chat(
    body: ChatRequest,
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
) -> ChatResponse:
    """Main AI chat endpoint.

    1. Verifies the session belongs to the user.
    2. Saves the user's message to chat_messages.
    3. Fetches the last 5 messages for context.
    4. Calls the LLM service (Gemini → Groq fallback).
    5. Saves the assistant reply to chat_messages.
    6. Updates the session's updated_at timestamp.
    7. Returns the AI reply.
    """
    await _ensure_user_exists(user, db)
    session_id_str = str(body.session_id)

    # Step 1 — Verify session ownership
    session = (
        db.table("chat_sessions")
        .select("user_id, summary")
        .eq("id", session_id_str)
        .single()
        .execute()
    )
    if not session.data or session.data["user_id"] != user["id"]:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Chat session not found",
        )
    
    session_summary = session.data.get("summary", "")

    # Step 2 — Save the user message
    try:
        db.table("chat_messages").insert({
            "session_id": session_id_str,
            "role": "user",
            "content": body.message,
        }).execute()
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save user message: {str(exc)}",
        ) from exc

    # Step 3 — Fetch last 5 messages for chat history
    try:
        history_result = (
            db.table("chat_messages")
            .select("role, content")
            .eq("session_id", session_id_str)
            .order("created_at", desc=True)
            .limit(5)
            .execute()
        )
        # Reverse to chronological order
        chat_history = list(reversed(history_result.data or []))
    except Exception:
        chat_history = []

    # Step 4 — Get AI response (Gemini → Groq fallback)
    try:
        ai_reply = await get_ai_response(
            user_message=body.message,
            chat_history=chat_history,
            session_summary=session_summary,
        )
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"AI service error: {str(exc)}",
        ) from exc

    # Step 5 — Save the assistant reply
    now = datetime.now(timezone.utc)
    try:
        db.table("chat_messages").insert({
            "session_id": session_id_str,
            "role": "assistant",
            "content": ai_reply,
        }).execute()
    except Exception as exc:
        # Log but don't fail the request — the user should still see the reply
        print(f"[WARN] Failed to save assistant message: {exc}")

    # Step 6 — Update session timestamp
    try:
        db.table("chat_sessions").update({
            "updated_at": now.isoformat(),
        }).eq("id", session_id_str).execute()
        
        # Step 6.1 — Trigger session summarization check
        # We don't await this so it doesn't block the user response
        import asyncio
        asyncio.create_task(update_session_summary_if_needed(session_id_str, db))
    except Exception:
        pass  # non-critical

    # Step 7 — Return the reply
    return ChatResponse(
        session_id=body.session_id,
        reply=ai_reply,
        created_at=now,
    )
