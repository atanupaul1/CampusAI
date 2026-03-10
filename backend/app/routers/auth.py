"""
Campus AI Assistant — Auth Router

Handles user registration and login via Supabase Auth.
- POST /auth/register  — creates a new user account
- POST /auth/login     — authenticates and returns an access token
"""

from fastapi import APIRouter, HTTPException, status, Depends
from supabase import Client

from app.database import get_supabase_admin_client
from app.models.schemas import (
    AuthResponse,
    ErrorResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)

router = APIRouter()


@router.post(
    "/register",
    response_model=AuthResponse,
    status_code=status.HTTP_201_CREATED,
    responses={400: {"model": ErrorResponse}},
    summary="Register a new user",
)
async def register(
    body: UserRegisterRequest,
    db: Client = Depends(get_supabase_admin_client),
) -> AuthResponse:
    """Create a new user account via Supabase Auth.

    1. Calls Supabase Auth sign-up with email + password.
    2. Inserts a row into the public.users table with display_name.
    3. Returns the access token and user profile.
    """
    try:
        # Step 1 — Supabase Auth sign-up
        auth_response = db.auth.sign_up({
            "email": body.email,
            "password": body.password,
        })

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Registration failed. The email may already be in use.",
            )

        user = auth_response.user
        access_token = auth_response.session.access_token if auth_response.session else ""

        # Step 2 — Insert into public.users
        display_name = body.display_name or body.email.split("@")[0]
        db.table("users").insert({
            "id": str(user.id),
            "email": body.email,
            "display_name": display_name,
        }).execute()

        return AuthResponse(
            access_token=access_token,
            user=UserResponse(
                id=user.id,
                email=body.email,
                display_name=display_name,
            ),
        )

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration error: {str(exc)}",
        ) from exc


@router.post(
    "/login",
    response_model=AuthResponse,
    responses={401: {"model": ErrorResponse}},
    summary="Log in an existing user",
)
async def login(
    body: UserLoginRequest,
    db: Client = Depends(get_supabase_admin_client),
) -> AuthResponse:
    """Authenticate a user with email + password via Supabase Auth.

    Returns the access token and user profile on success.
    """
    try:
        auth_response = db.auth.sign_in_with_password({
            "email": body.email,
            "password": body.password,
        })

        if auth_response.user is None or auth_response.session is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password.",
            )

        user = auth_response.user

        # Fetch display_name from public.users
        profile = (
            db.table("users")
            .select("display_name, avatar_url, created_at")
            .eq("id", str(user.id))
            .single()
            .execute()
        )

        profile_data = profile.data or {}

        return AuthResponse(
            access_token=auth_response.session.access_token,
            user=UserResponse(
                id=user.id,
                email=user.email or body.email,
                display_name=profile_data.get("display_name"),
                avatar_url=profile_data.get("avatar_url"),
                created_at=profile_data.get("created_at"),
            ),
        )

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Login failed: {str(exc)}",
        ) from exc
