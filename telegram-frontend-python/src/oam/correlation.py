import uuid
from contextvars import ContextVar
from typing import Optional

# Context variable for storing correlation ID
_correlation_id_ctx: ContextVar[Optional[str]] = ContextVar('correlation_id', default=None)

CORRELATION_ID_HEADER = 'X-Correlation-ID'
CORRELATION_ID_KAFKA_HEADER = 'correlationId'


def generate_correlation_id() -> str:
    """Generate a new correlation ID using UUID"""
    return str(uuid.uuid4())


def set_correlation_id(correlation_id: str) -> None:
    """Set the correlation ID in the current context"""
    _correlation_id_ctx.set(correlation_id)


def get_correlation_id() -> Optional[str]:
    """Get the correlation ID from the current context"""
    return _correlation_id_ctx.get()


def get_or_generate_correlation_id() -> str:
    """Get the correlation ID from context or generate a new one"""
    corr_id = get_correlation_id()
    if corr_id is None:
        corr_id = generate_correlation_id()
        set_correlation_id(corr_id)
    return corr_id


def clear_correlation_id() -> None:
    """Clear the correlation ID from the current context"""
    _correlation_id_ctx.set(None)

