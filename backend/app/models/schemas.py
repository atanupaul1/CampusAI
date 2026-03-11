"""
Campus AI Assistant — Pydantic Request / Response Schemas

Every API endpoint uses these models for input validation and
response serialization. All fields have type hints; optional fields
have sensible defaults.
"""

from datetime import datetime
from enum import Enum
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


# ------------------------------------------------------------------
# Enums
# ------------------------------------------------------------------

class MessageRole(str, Enum):
    """Allowed roles for chat messages."""
    USER = "user"
    ASSISTANT = "assistant"


# ------------------------------------------------------------------
# Auth
# ------------------------------------------------------------------

class UserRegisterRequest(BaseModel):
    """Body for POST /auth/register."""
    email: EmailStr
    password: str = Field(..., min_length=6, description="Minimum 6 characters")
    display_name: Optional[str] = None


class UserLoginRequest(BaseModel):
    """Body for POST /auth/login."""
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    """Public user profile returned by auth endpoints."""
    id: UUID
    email: str
    display_name: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: Optional[datetime] = None


class AuthResponse(BaseModel):
    """Wrapper returned after successful login / register."""
    access_token: str
    user: UserResponse


# ------------------------------------------------------------------
# Chat
# ------------------------------------------------------------------

class ChatRequest(BaseModel):
    """Body for POST /chat."""
    session_id: UUID
    message: str = Field(..., min_length=1, max_length=2000)


class ChatResponse(BaseModel):
    """Response from POST /chat."""
    session_id: UUID
    reply: str
    created_at: datetime


class MessageResponse(BaseModel):
    """Single chat message (used in history lists)."""
    id: UUID
    session_id: UUID
    role: MessageRole
    content: str
    created_at: datetime


class SessionCreateRequest(BaseModel):
    """Body for POST /chat/sessions."""
    title: Optional[str] = "New Chat"


class SessionResponse(BaseModel):
    """Single chat session summary."""
    id: UUID
    user_id: UUID
    title: str
    summary: Optional[str] = None
    created_at: datetime
    updated_at: datetime


# ------------------------------------------------------------------
# Events
# ------------------------------------------------------------------

class EventResponse(BaseModel):
    """Single campus event."""
    id: UUID
    title: str
    description: Optional[str] = None
    location: Optional[str] = None
    start_time: Optional[datetime] = None
    end_time: Optional[datetime] = None
    category: Optional[str] = None
    source_url: Optional[str] = None
    created_at: Optional[datetime] = None


# ------------------------------------------------------------------
# Generic
# ------------------------------------------------------------------

class HealthResponse(BaseModel):
    """Response for GET /health."""
    status: str = "ok"


class ErrorResponse(BaseModel):
    """Standard error envelope."""
    detail: str
