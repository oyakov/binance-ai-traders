from src import log_config
from typing import Any, Awaitable, Callable, Dict

from aiogram.dispatcher.middlewares.base import BaseMiddleware
from aiogram.types import TelegramObject

logger = log_config.get_logger(__name__)


# Middleware to inject the services into context
class ChatIDMiddleware(BaseMiddleware):
    """Middleware to inject any given service instance to the aiogram callback or message handlers"""
    def __init__(self):
        super().__init__()

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        logger.info(f'ChatIDMiddleware called: {handler}, event: {event}, data: {data}')
        return await handler(event, data)
