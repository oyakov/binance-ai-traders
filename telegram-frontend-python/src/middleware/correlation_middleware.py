import logging
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response
from typing import Callable

from oam.correlation import (
    CORRELATION_ID_HEADER,
    get_correlation_id,
    set_correlation_id,
    generate_correlation_id,
    clear_correlation_id
)

logger = logging.getLogger(__name__)


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """
    Middleware to handle correlation IDs for distributed tracing.
    Extracts correlation ID from request header or generates a new one.
    Adds correlation ID to response header and makes it available in context.
    """
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Extract correlation ID from request header or generate new one
        correlation_id = request.headers.get(CORRELATION_ID_HEADER)
        
        if not correlation_id:
            correlation_id = generate_correlation_id()
            logger.debug(f"Generated new correlation ID: {correlation_id}")
        else:
            logger.debug(f"Extracted correlation ID from header: {correlation_id}")
        
        # Set correlation ID in context
        set_correlation_id(correlation_id)
        
        try:
            # Process request
            response = await call_next(request)
            
            # Add correlation ID to response header
            response.headers[CORRELATION_ID_HEADER] = correlation_id
            
            return response
        finally:
            # Clear correlation ID from context after request completes
            clear_correlation_id()

