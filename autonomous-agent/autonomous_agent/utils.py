"""Utility helpers for the autonomous agent."""

from __future__ import annotations

import json
from typing import Any


def extract_json_blob(text: str) -> Any:
    """Extract JSON from a text response.

    The model is encouraged to respond with plain JSON, but we also try to strip
    triple backtick code fences when present.
    """

    candidate = text.strip()
    if candidate.startswith('```'):
        lines = candidate.splitlines()
        if len(lines) >= 3:
            # Drop first and last line that contain fences
            candidate = '\n'.join(lines[1:-1])
    return json.loads(candidate)


__all__ = ['extract_json_blob']
