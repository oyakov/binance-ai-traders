from typing import Any, Awaitable, Callable, Dict

from aiogram.dispatcher.middlewares.base import BaseMiddleware
from aiogram.types import TelegramObject, Message

from oam import log_config

logger = log_config.get_logger(__name__)


# Middleware to inject the services into context
class ChatIDMiddleware(BaseMiddleware):
    """Middleware to inject collect chat id of any given chat it is added to"""
    def __init__(self):
        super().__init__()

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        logger.info(f'ChatIDMiddleware called: {handler}, event type: {event.__class__}, data: {data}')
        if isinstance(event,  Message):
            data['chat_id'] = event.chat.id
            logger.info(f'Chat ID injected: {data["chat_id"]}')
        return await handler(event, data)
