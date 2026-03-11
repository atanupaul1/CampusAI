"""
Campus AI Assistant — Cache Service

A simple, in-memory TTL (Time-To-Live) cache to store expensive
database results like campus events and FAQs.
"""

import time
from typing import Any, Dict, Optional


class SimpleTTLCache:
    """A basic dictionary-based cache with expiration."""

    def __init__(self, default_ttl: int = 300):
        self._cache: Dict[str, Dict[str, Any]] = {}
        self.default_ttl = default_ttl

    def set(self, key: str, value: Any, ttl: Optional[int] = None) -> None:
        """Store a value in the cache with an expiration time."""
        expire_at = time.time() + (ttl if ttl is not None else self.default_ttl)
        self._cache[key] = {
            "value": value,
            "expire_at": expire_at
        }

    def get(self, key: str) -> Optional[Any]:
        """Retrieve a value from the cache if it hasn't expired."""
        data = self._cache.get(key)
        if not data:
            return None

        if time.time() > data["expire_at"]:
            del self._cache[key]
            return None

        return data["value"]

    def delete(self, key: str) -> None:
        """Remove a specific key from the cache."""
        if key in self._cache:
            del self._cache[key]

    def clear(self) -> None:
        """Clear all entries in the cache."""
        self._cache.clear()


# Shared singleton instance
context_cache = SimpleTTLCache(default_ttl=300)  # 5 minutes
