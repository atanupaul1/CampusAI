"""
Campus AI Assistant — FastAPI Dependencies

Provides reusable dependency functions injected into route handlers,
most importantly `get_current_user` which validates the Supabase JWT
from the Authorization header.
"""

from fastapi import Depends, Header, HTTPException, status
from supabase import Client

from app.database import get_supabase_client


async def get_current_user(
    authorization: str = Header(..., description="Bearer <supabase-access-token>"),
    db: Client = Depends(get_supabase_client),
) -> dict:
    """Validate the Supabase JWT and return the authenticated user.

    Args:
        authorization: The Authorization header value (Bearer token).
        db: Supabase client instance.

    Returns:
        A dict with at least ``id`` and ``email`` of the authenticated user.

    Raises:
        HTTPException 401: If the token is missing, malformed, or invalid.
    """
    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header must start with 'Bearer '",
        )

    token = authorization.removeprefix("Bearer ").strip()
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Access token is missing",
        )

    try:
        # Supabase client can verify the JWT and return the user
        user_response = db.auth.get_user(token)
        user = user_response.user
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired access token",
            )
        return {"id": user.id, "email": user.email}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token validation failed: {str(exc)}",
        ) from exc
