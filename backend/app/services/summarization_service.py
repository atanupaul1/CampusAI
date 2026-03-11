"""
Campus AI Assistant — Summarization Service

Handles compressing long chat histories into a single paragraph summary
to maintain long-term memory without exceeding token limits.
"""

from typing import List
from supabase import Client

from app.services.llm_service import call_gemini, call_groq
from app.config import get_settings

SUMMARIZATION_THRESHOLD = 10


async def summarize_history(messages: List[dict]) -> str:
    """Generate a concise summary of the conversation history.

    Args:
        messages: List of messages with 'role' and 'content'.

    Returns:
        A paragraph summarizing the key points of the conversation.
    """
    settings = get_settings()
    
    # Format messages for the summarization prompt
    history_text = "\n".join([f"{m['role'].upper()}: {m['content']}" for m in messages])
    
    prompt = (
        "You are a helpful assistant. Please summarize the following conversation "
        "history into a single, concise paragraph that captures the most important "
        "details, facts, and user preferences mentioned. This summary will be used "
        "as context for future messages so the assistant doesn't forget.\n\n"
        f"CONVERSATION HISTORY:\n{history_text}\n\n"
        "SUMMARY:"
    )

    # Simple system prompt for the summarizer
    system_prompt = "You are an expert summarizer. Be concise and accurate."
    summarizer_messages = [{"role": "user", "content": prompt}]

    # Try Gemini first, then Groq
    if settings.gemini_api_key:
        try:
            return await call_gemini(system_prompt, summarizer_messages, settings.gemini_api_key)
        except Exception as e:
            print(f"[Summarizer] Gemini failed: {e}")

    if settings.groq_api_key:
        try:
            return await call_groq(system_prompt, summarizer_messages, settings.groq_api_key)
        except Exception as e:
            print(f"[Summarizer] Groq failed: {e}")

    return ""


async def update_session_summary_if_needed(
    session_id: str, 
    db: Client,
    force: bool = False
) -> None:
    """Check if the session needs a summary update and trigger it.
    
    Triggers if message count > SUMMARIZATION_THRESHOLD and summary is empty,
    or if force is True.
    """
    try:
        # Check message count
        count_res = db.table("chat_messages").select("id", count="exact").eq("session_id", session_id).execute()
        msg_count = count_res.count if count_res.count is not None else 0
        
        if msg_count < SUMMARIZATION_THRESHOLD and not force:
            return

        # Fetch full history
        history_res = db.table("chat_messages").select("role, content").eq("session_id", session_id).order("created_at").execute()
        history = history_res.data or []
        
        if not history:
            return

        summary = await summarize_history(history)
        
        if summary:
            db.table("chat_sessions").update({"summary": summary}).eq("id", session_id).execute()
            print(f"[Summarizer] Updated summary for session {session_id}")
            
    except Exception as e:
        print(f"[Summarizer] Failed to update summary: {e}")
