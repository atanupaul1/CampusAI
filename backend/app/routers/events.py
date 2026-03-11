"""
Campus AI Assistant — Events Router

Serves campus event data from the campus_events table.
- GET /events       — paginated list with optional category/date filters
- GET /events/{id}  — single event by UUID
"""

from datetime import date
from typing import List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from supabase import Client

from app.database import get_supabase_admin_client
from app.models.schemas import ErrorResponse, EventResponse
from app.services.cache_service import context_cache

router = APIRouter()


@router.get(
    "",
    response_model=List[EventResponse],
    summary="List campus events",
)
async def list_events(
    category: Optional[str] = Query(None, description="Filter by category"),
    from_date: Optional[date] = Query(None, description="Events starting on or after this date"),
    to_date: Optional[date] = Query(None, description="Events starting on or before this date"),
    limit: int = Query(50, ge=1, le=100, description="Max results"),
    offset: int = Query(0, ge=0, description="Pagination offset"),
    db: Client = Depends(get_supabase_admin_client),
) -> List[EventResponse]:
    """Return campus events, optionally filtered by category and date range.

    Results are ordered by start_time descending (newest first).
    """
    try:
        query = db.table("campus_events").select("*")

        if category:
            query = query.eq("category", category)
        if from_date:
            query = query.gte("start_time", from_date.isoformat())
        if to_date:
            query = query.lte("start_time", to_date.isoformat())

        query = query.order("start_time", desc=True).range(offset, offset + limit - 1)
        result = query.execute()

        return [EventResponse(**row) for row in (result.data or [])]

    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch events: {str(exc)}",
        ) from exc


@router.get(
    "/{event_id}",
    response_model=EventResponse,
    responses={404: {"model": ErrorResponse}},
    summary="Get a single campus event",
)
async def get_event(
    event_id: UUID,
    db: Client = Depends(get_supabase_admin_client),
) -> EventResponse:
    """Return a single campus event by its UUID."""
    try:
        result = (
            db.table("campus_events")
            .select("*")
            .eq("id", str(event_id))
            .single()
            .execute()
        )

        if result.data is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Event {event_id} not found",
            )

        return EventResponse(**result.data)

    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event not found: {str(exc)}",
        ) from exc


@router.post(
    "/clear-cache",
    status_code=status.HTTP_200_OK,
    summary="Clear the campus context cache",
)
async def clear_campus_cache():
    """Manually clear the cached events and FAQs.
    
    This should be called by the Admin App or a webhook after
    making changes to the database.
    """
    context_cache.delete("campus_context")
    return {"status": "cache cleared"}
