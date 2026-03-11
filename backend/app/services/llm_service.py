"""
Campus AI Assistant — LLM Service

Manages all communication with AI providers (Gemini and Groq).
Implements a primary + fallback strategy:
  1. Try Google Gemini API first.
  2. If Gemini fails (quota exceeded, network error), fall back to Groq.

The system prompt, context injection, and token capping logic all
live here so callers just pass a user message and get a reply.
"""

import json
from typing import List

import httpx

from app.config import get_settings
from app.services.context_service import build_campus_context, count_tokens, truncate_to_tokens
from app.utils.retry_utils import async_retry

# ------------------------------------------------------------------ #
# Constants
# ------------------------------------------------------------------ #
MAX_CONTEXT_TOKENS = 2000  # hard cap for the full prompt context
GEMINI_MODEL = "gemini-2.0-flash"
GROQ_MODEL = "llama-3.3-70b-versatile"  # free tier on Groq


def _build_system_prompt(university_name: str, campus_context: str, session_summary: str = "") -> str:
    """Construct the system prompt with campus context and history summary injected.

    Args:
        university_name: Name of the university for personalisation.
        campus_context: Pre-formatted events + FAQs string.
        session_summary: Previous conversation summary for long-term memory.

    Returns:
        The full system prompt string.
    """
    base = (
        f"You are CampusBot, a friendly and helpful AI assistant for {university_name}. "
        "You help students with campus events, academic schedules, deadlines, FAQs, "
        "campus facilities, and general student life questions. Be concise, friendly, "
        "and accurate. If you do not know something, say so honestly and suggest where "
        "the student can find the answer. Never make up event dates, office hours, or "
        "official policies."
    )

    if session_summary:
        base += f"\n\nHere is a summary of your previous conversation history:\n{session_summary}"

    if campus_context:
        base += (
            "\n\nHere is some current campus information you can reference "
            "when answering questions:\n\n" + campus_context
        )

    return base


def _prepare_messages(
    user_message: str,
    chat_history: List[dict],
    university_name: str,
    session_summary: str = "",
) -> tuple[str, list[dict]]:
    """Build the system prompt and message list for the LLM call.

    1. Builds campus context (events + FAQs).
    2. Constructs system prompt with summary and campus context.
    3. Includes the last 5 messages from chat history for continuity.
    4. Truncates context if total tokens exceed MAX_CONTEXT_TOKENS.

    Args:
        user_message: The new message from the user.
        chat_history: Previous messages (dicts with 'role' and 'content').
        university_name: Name of the university.
        session_summary: Optional summary of older history.

    Returns:
        A tuple of (system_prompt, messages_list).
    """
    campus_context = build_campus_context(max_tokens=1200)
    system_prompt = _build_system_prompt(university_name, campus_context, session_summary)

    # Keep last 5 messages for continuity
    recent_history = chat_history[-5:] if len(chat_history) > 5 else chat_history

    messages = [{"role": msg["role"], "content": msg["content"]} for msg in recent_history]
    messages.append({"role": "user", "content": user_message})

    # Check total token count and truncate system prompt context if needed
    total = count_tokens(system_prompt) + sum(count_tokens(m["content"]) for m in messages)
    if total > MAX_CONTEXT_TOKENS:
        overflow = total - MAX_CONTEXT_TOKENS
        # Reduce the campus context portion
        reduced_ctx = truncate_to_tokens(campus_context, max(0, 1200 - overflow))
        system_prompt = _build_system_prompt(university_name, reduced_ctx)

    return system_prompt, messages


# ------------------------------------------------------------------ #
# Gemini API
# ------------------------------------------------------------------ #

@async_retry(retries=3, base_delay=1.0)
async def call_gemini(
    system_prompt: str,
    messages: list[dict],
    api_key: str,
) -> str:
    """Send a chat completion request to Google Gemini API.

    Args:
        system_prompt: The system instruction.
        messages: Conversation messages list.
        api_key: Gemini API key.

    Returns:
        The assistant's reply text.

    Raises:
        Exception: On any API or network error.
    """
    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{GEMINI_MODEL}:generateContent?key={api_key}"
    )

    # Convert messages to Gemini's format
    contents = []
    for msg in messages:
        role = "user" if msg["role"] == "user" else "model"
        contents.append({
            "role": role,
            "parts": [{"text": msg["content"]}],
        })

    payload = {
        "system_instruction": {
            "parts": [{"text": system_prompt}],
        },
        "contents": contents,
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 1024,
        },
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(url, json=payload)
        response.raise_for_status()

    data = response.json()
    # Extract text from Gemini response
    candidates = data.get("candidates", [])
    if candidates:
        parts = candidates[0].get("content", {}).get("parts", [])
        if parts:
            return parts[0].get("text", "I'm sorry, I couldn't generate a response.")

    return "I'm sorry, I couldn't generate a response."


# ------------------------------------------------------------------ #
# Groq API (fallback)
# ------------------------------------------------------------------ #

@async_retry(retries=3, base_delay=1.0)
async def call_groq(
    system_prompt: str,
    messages: list[dict],
    api_key: str,
) -> str:
    """Send a chat completion request to Groq API (OpenAI-compatible).

    Args:
        system_prompt: The system instruction.
        messages: Conversation messages list.
        api_key: Groq API key.

    Returns:
        The assistant's reply text.

    Raises:
        Exception: On any API or network error.
    """
    url = "https://api.groq.com/openai/v1/chat/completions"

    # Groq uses OpenAI-compatible format
    formatted_messages = [{"role": "system", "content": system_prompt}]
    formatted_messages.extend(messages)

    payload = {
        "model": GROQ_MODEL,
        "messages": formatted_messages,
        "temperature": 0.7,
        "max_tokens": 1024,
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    async with httpx.AsyncClient(timeout=30.0) as client:
        response = await client.post(url, json=payload, headers=headers)
        response.raise_for_status()

    data = response.json()
    choices = data.get("choices", [])
    if choices:
        return choices[0].get("message", {}).get("content", "I'm sorry, I couldn't generate a response.")

    return "I'm sorry, I couldn't generate a response."


# ------------------------------------------------------------------ #
# Unified entry point with automatic fallback
# ------------------------------------------------------------------ #

async def get_ai_response(
    user_message: str,
    chat_history: List[dict],
    session_summary: str = "",
) -> str:
    """Get an AI response to the user's message.

    Tries Gemini first; on any failure (quota exceeded, network error,
    etc.) automatically falls back to Groq.

    Args:
        user_message: The new user message.
        chat_history: List of previous messages with 'role' and 'content'.
        session_summary: Optional summary of older conversation history.

    Returns:
        The AI-generated reply string.

    Raises:
        Exception: If both Gemini and Groq fail.
    """
    settings = get_settings()
    system_prompt, messages = _prepare_messages(
        user_message=user_message,
        chat_history=chat_history,
        university_name=settings.university_name,
        session_summary=session_summary,
    )

    # --- Attempt 1: Gemini ---
    if settings.gemini_api_key:
        try:
            return await call_gemini(system_prompt, messages, settings.gemini_api_key)
        except Exception as gemini_err:
            print(f"[LLM] Gemini failed, falling back to Groq: {gemini_err}")

    # --- Attempt 2: Groq (fallback) ---
    if settings.groq_api_key:
        try:
            return await call_groq(system_prompt, messages, settings.groq_api_key)
        except Exception as groq_err:
            raise RuntimeError(
                f"Both AI providers failed. Gemini and Groq are unavailable. "
                f"Groq error: {groq_err}"
            ) from groq_err

    raise RuntimeError(
        "No AI provider configured. Set GEMINI_API_KEY or GROQ_API_KEY in your .env file."
    )
