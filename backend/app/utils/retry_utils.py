"""
Campus AI Assistant — Retry Utilities

Provides a decorator for exponential backoff retries on asynchronous functions.
Useful for handling transient network errors or API quota issues.
"""

import asyncio
import functools
import random
from typing import Any, Callable, Type


def async_retry(
    retries: int = 3,
    base_delay: float = 1.0,
    max_delay: float = 10.0,
    exceptions: Type[Exception] = Exception,
):
    """Decorator to retry an async function with exponential backoff.

    Args:
        retries: Maximum number of retry attempts.
        base_delay: Initial delay in seconds.
        max_delay: Maximum delay in seconds.
        exceptions: The exception type(s) that should trigger a retry.
    """
    def decorator(func: Callable):
        @functools.wraps(func)
        async def wrapper(*args, **kwargs) -> Any:
            delay = base_delay
            last_err = None

            for attempt in range(retries + 1):
                try:
                    return await func(*args, **kwargs)
                except exceptions as e:
                    last_err = e
                    if attempt == retries:
                        print(f"[Retry] Max retries ({retries}) reached for {func.__name__}. Error: {e}")
                        break
                    
                    # Add jitter to the delay
                    jitter = random.uniform(0, 0.1 * delay)
                    wait_time = min(delay + jitter, max_delay)
                    
                    print(f"[Retry] Attempt {attempt + 1} failed for {func.__name__}. Retrying in {wait_time:.2f}s... Error: {e}")
                    await asyncio.sleep(wait_time)
                    delay *= 2  # Exponential backoff

            raise last_err
        return wrapper
    return decorator
