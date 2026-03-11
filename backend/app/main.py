"""
Campus AI Assistant — FastAPI Application Entry Point

Creates the FastAPI app, configures CORS, includes all routers,
and exposes the /health endpoint required for Render deployment.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.models.schemas import HealthResponse
from app.routers import auth, events, chat, notifications, profile

settings = get_settings()


def create_app() -> FastAPI:
    """Application factory — builds and returns the FastAPI instance."""
    application = FastAPI(
        title="Campus AI Assistant API",
        description="Backend API for the Campus AI Assistant mobile app.",
        version="1.0.0",
    )

    # ------------------------------------------------------------------
    # CORS — allow the Flutter app and local dev tools to call the API
    # ------------------------------------------------------------------
    application.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # tighten in production
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ------------------------------------------------------------------
    # Routers
    # ------------------------------------------------------------------
    application.include_router(auth.router, prefix="/auth", tags=["Auth"])
    application.include_router(events.router, prefix="/events", tags=["Events"])
    application.include_router(chat.router, prefix="/chat", tags=["Chat"])
    application.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
    application.include_router(profile.router, prefix="/profile", tags=["Profile"])

    # ------------------------------------------------------------------
    # Health check (required for Render zero-downtime deploys)
    # ------------------------------------------------------------------
    @application.get(
        "/health",
        response_model=HealthResponse,
        tags=["System"],
        summary="Health check",
    )
    async def health() -> HealthResponse:
        """Return a simple OK status for uptime monitoring."""
        return HealthResponse(status="ok")

    return application


app = create_app()
