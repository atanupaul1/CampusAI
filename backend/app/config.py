"""
Campus AI Assistant — Application Configuration

Loads environment variables from .env and exposes them via a typed
Pydantic Settings model. All secrets (API keys, Supabase credentials)
are read from the environment — nothing is hardcoded.
"""

from functools import lru_cache
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Supabase
    supabase_url: str = ""
    supabase_key: str = ""  # anon / public key
    supabase_service_key: str = ""  # service-role key (for admin ops)

    # AI / LLM
    gemini_api_key: str = ""
    groq_api_key: str = ""

    # Firebase
    firebase_service_account_path: str = "serviceAccountKey.json"

    # App
    university_name: str = "Your University"
    app_env: str = "development"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache()
def get_settings() -> Settings:
    """Return a cached Settings instance (reads .env once)."""
    return Settings()
