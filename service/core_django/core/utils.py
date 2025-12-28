"""
Utility functions.
"""
import re
from typing import Any, Optional


def extract_mentions(text: str) -> list[str]:
    """Extract @mentions from text."""
    pattern = r'@(\w+)'
    return re.findall(pattern, text)


def extract_hashtags(text: str) -> list[str]:
    """Extract #hashtags from text."""
    pattern = r'#(\w+)'
    return re.findall(pattern, text)


def truncate_text(text: str, max_length: int = 100, suffix: str = '...') -> str:
    """Truncate text to max length with suffix."""
    if len(text) <= max_length:
        return text
    return text[:max_length - len(suffix)] + suffix


def get_client_ip(request) -> Optional[str]:
    """Get client IP address from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0].strip()
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def safe_int(value: Any, default: int = 0) -> int:
    """Safely convert value to int."""
    try:
        return int(value)
    except (ValueError, TypeError):
        return default


def safe_bool(value: Any, default: bool = False) -> bool:
    """Safely convert value to bool."""
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.lower() in ('true', '1', 'yes', 'on')
    return default
