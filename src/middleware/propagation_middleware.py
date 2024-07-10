from src import log_config
from typing import Any, Awaitable, Callable, Dict

from aiogram.dispatcher.middlewares.base import BaseMiddleware
from aiogram.types import TelegramObject, Message

logger = log_config.get_logger(__name__)


class PropagationMiddleware(BaseMiddleware):
    def __init__(self):
        super().__init__()

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        logger.info(f'PropagationMiddleware called')
        if isinstance(event, Message):
            logger.info(f'PropagationMiddleware called for message')
        return await handler(event, data)
