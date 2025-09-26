"""Simple HTTP client for OpenAI compatible chat endpoints."""

from __future__ import annotations

import json
import time
from dataclasses import dataclass
from typing import Iterable, List, Optional
from urllib import request, error

from .config import LLMConfig


@dataclass(slots=True)
class ChatMessage:
    role: str
    content: str


@dataclass(slots=True)
class ChatResponse:
    content: str
    raw: dict
    latency: float


class LLMError(RuntimeError):
    """Raised when the LLM endpoint returns an error."""


class LLMClient:
    def __init__(self, config: LLMConfig):
        self._config = config
        self._endpoint = config.base_url.rstrip('/') + '/chat/completions'

    def chat(self, messages: Iterable[ChatMessage], temperature: float = 0.2) -> ChatResponse:
        payload = {
            'model': self._config.model,
            'messages': [msg.__dict__ for msg in messages],
            'temperature': temperature,
            'stream': False,
        }

        headers = {
            'Content-Type': 'application/json',
        }
        if self._config.api_key:
            headers['Authorization'] = f'Bearer {self._config.api_key}'

        encoded = json.dumps(payload).encode('utf-8')
        req = request.Request(
            self._endpoint,
            data=encoded,
            headers=headers,
            method='POST',
        )
        start = time.perf_counter()
        try:
            with request.urlopen(req, timeout=self._config.request_timeout) as response:
                raw_body = response.read().decode('utf-8')
        except error.HTTPError as exc:
            detail = exc.read().decode('utf-8', errors='replace')
            raise LLMError(f'HTTP error {exc.code}: {detail}') from exc
        except error.URLError as exc:  # pragma: no cover - network error
            raise LLMError(f'Failed to reach LLM endpoint: {exc.reason}') from exc

        latency = time.perf_counter() - start
        try:
            decoded = json.loads(raw_body)
        except json.JSONDecodeError as exc:
            raise LLMError(f'Invalid JSON response: {exc}') from exc

        choices: List[dict] = decoded.get('choices', [])
        if not choices:
            raise LLMError('LLM response did not contain choices')

        message = choices[0].get('message') or {}
        content = message.get('content')
        if content is None:
            raise LLMError('LLM response missing message content')

        return ChatResponse(content=str(content), raw=decoded, latency=latency)


__all__ = ['ChatMessage', 'ChatResponse', 'LLMClient', 'LLMError']
