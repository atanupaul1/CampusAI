"""
Campus AI Assistant — Profile Router

Endpoints:
- GET /profile     — Get current user's profile and preferences
- PATCH /profile   — Update profile preferences
"""

from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from supabase import Client

from app.database import get_supabase_admin_client
from app.dependencies import get_current_user

router = APIRouter()


class ProfileUpdate(BaseModel):
    notification_preferences: Optional[Dict[str, bool]] = None


@router.get("", status_code=status.HTTP_200_OK)
async def get_profile(
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
):
    """Return the current user's profile data from Supabase."""
    try:
        result = (
            db.table("profiles")
            .select("*")
            .eq("id", user["id"])
            .single()
            .execute()
        )
        return result.data
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch profile: {e}"
        )


@router.patch("", status_code=status.HTTP_200_OK)
async def update_profile(
    body: ProfileUpdate,
    user: dict = Depends(get_current_user),
    db: Client = Depends(get_supabase_admin_client),
):
    """Update user profile fields, such as notification preferences."""
    try:
        update_data = {}
        if body.notification_preferences is not None:
            update_data["notification_preferences"] = body.notification_preferences

        if not update_data:
            return {"status": "no changes"}

        result = (
            db.table("users")
            .update(update_data)
            .eq("id", user["id"])
            .execute()
        )
        return {"status": "profile updated", "data": result.data}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {e}"
        )
