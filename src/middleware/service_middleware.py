from oam import log_config
from typing import Any, Awaitable, Callable, Dict

from aiogram.dispatcher.middlewares.base import BaseMiddleware
from aiogram.types import TelegramObject

logger = log_config.get_logger(__name__)


# Middleware to inject the services into context
class ServiceMiddleware(BaseMiddleware):
    """Middleware to inject any given service instance to the aiogram callback or message handlers"""
    def __init__(self, key: str, service):
        super().__init__()
        self.key = key
        self.service = service

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        logger.info(f'ServiceMiddleware called: {handler}, event: {event}, data: {data}')
        data[self.key] = self.service
        logger.info(f'Service injected for key {self.key}: {data[self.key]}')
        return await handler(event, data)
