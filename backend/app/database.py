"""
Campus AI Assistant — Supabase Database Client

Creates and caches a Supabase client singleton so every module
shares the same connection. Uses the anon key for user-facing
operations and provides a service-role client for admin tasks
(like n8n data ingestion).
"""

from functools import lru_cache

from supabase import create_client, Client

from app.config import get_settings


@lru_cache()
def get_supabase_client() -> Client:
    """Return a cached Supabase client using the anon (public) key."""
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_key)


@lru_cache()
def get_supabase_admin_client() -> Client:
    """Return a cached Supabase client using the service-role key.

    This client bypasses Row Level Security — use only for
    server-side admin operations (e.g., inserting scraped data).
    """
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_service_key)
