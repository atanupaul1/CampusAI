"""
Campus AI Assistant — Context Service

Queries campus_events and campus_faqs from Supabase, formats them
as a context string, and truncates to fit within the token budget
so the LLM system prompt stays within limits.
"""

from typing import List

import tiktoken
from supabase import Client

from app.database import get_supabase_admin_client


# Use cl100k_base encoder (same family as GPT-4 / Gemini tokenisers)
_ENCODER = tiktoken.get_encoding("cl100k_base")


def count_tokens(text: str) -> int:
    """Return the approximate token count for a string."""
    return len(_ENCODER.encode(text))


def truncate_to_tokens(text: str, max_tokens: int) -> str:
    """Truncate text to fit within max_tokens.

    Args:
        text: The input string.
        max_tokens: Maximum number of tokens allowed.

    Returns:
        The (possibly truncated) string.
    """
    tokens = _ENCODER.encode(text)
    if len(tokens) <= max_tokens:
        return text
    return _ENCODER.decode(tokens[:max_tokens])


def _format_events(events: List[dict]) -> str:
    """Format event rows into a readable context block."""
    if not events:
        return ""
    lines = ["### Upcoming Campus Events"]
    for ev in events:
        line = f"- **{ev.get('title', 'Untitled')}**"
        if ev.get("start_time"):
            line += f" | {ev['start_time']}"
        if ev.get("location"):
            line += f" | {ev['location']}"
        if ev.get("description"):
            line += f"\n  {ev['description'][:200]}"
        lines.append(line)
    return "\n".join(lines)


def _format_faqs(faqs: List[dict]) -> str:
    """Format FAQ rows into a readable context block."""
    if not faqs:
        return ""
    lines = ["### Campus FAQs"]
    for faq in faqs:
        lines.append(f"- **Q:** {faq.get('question', '')}")
        lines.append(f"  **A:** {faq.get('answer', '')}")
    return "\n".join(lines)


def build_campus_context(
    max_tokens: int = 1200,
    db: Client | None = None,
) -> str:
    """Fetch campus events and FAQs and return a formatted, token-capped context string.

    This context is appended to the LLM system prompt so the AI can
    answer questions about real campus data.

    Args:
        max_tokens: Maximum tokens for the campus context block.
        db: Optional Supabase client; defaults to the shared singleton.

    Returns:
        A formatted string containing events and FAQs.
    """
    if db is None:
        db = get_supabase_admin_client()

    # Fetch the 10 most recent / upcoming events
    try:
        events_result = (
            db.table("campus_events")
            .select("title, description, location, start_time")
            .order("start_time", desc=False)
            .limit(10)
            .execute()
        )
        events = events_result.data or []
    except Exception:
        events = []

    # Fetch up to 15 FAQs
    try:
        faqs_result = (
            db.table("campus_faqs")
            .select("question, answer")
            .limit(15)
            .execute()
        )
        faqs = faqs_result.data or []
    except Exception:
        faqs = []

    events_text = _format_events(events)
    faqs_text = _format_faqs(faqs)

    full_context = "\n\n".join(filter(None, [events_text, faqs_text]))

    # Truncate campus data first if over token budget
    return truncate_to_tokens(full_context, max_tokens)
