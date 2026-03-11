"""
Campus AI Assistant — Notification Router

Endpoints:
- POST /notifications/token          — Register or update an FCM token for the user
- POST /notifications/event-trigger  — Trigger push notifications for an event (Internal/Admin)
"""

from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from supabase import Client

from app.database import get_supabase_admin_client
from app.dependencies import get_current_user
from app.services.notification_service import send_event_notification

router = APIRouter()


class TokenRegister(BaseModel):
    token: str
    platform: Optional[str] = "android"


class EventTrigger(BaseModel):
    event_id: UUID
    title: str
    category: str


@router.post("/token", status_code=status.HTTP_201_CREATED)
async def register_token(
    body: TokenRegister,
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
):
    """Register or update an FCM token for the current user."""
    try:
        # Upsert the token
        data = {
            "user_id": user["id"],
            "token": body.token,
            "platform": body.platform,
        }
        
        # We manually handle upsert to avoid duplicate entries for the same token
        db.table("device_tokens").upsert(data, on_conflict="token").execute()
        return {"status": "token registered"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to register token: {e}"
        )


@router.post("/event-trigger", status_code=status.HTTP_200_OK)
async def trigger_event_notification(
    body: EventTrigger,
    db: Client = Depends(get_supabase_admin_client),
):
    """Trigger notifications for a specific event.
    
    This is intended to be called by the Admin App or a backend process
    after successfully creating/updating an event.
    """
    sent_count = await send_event_notification(
        db=db,
        event_title=body.title,
        event_category=body.category,
        event_id=str(body.event_id),
    )
    return {"status": "notifications sent", "count": sent_count}
