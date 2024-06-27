import logging
from typing import Any, Awaitable, Callable, Dict

from aiogram.dispatcher.middlewares.base import BaseMiddleware
from aiogram.types import TelegramObject


# Middleware to inject the MessageService
class ServiceMiddleware(BaseMiddleware):
    def __init__(self, service):
        super().__init__()
        self.service = service

    async def __call__(
        self,
        handler: Callable[[TelegramObject, Dict[str, Any]], Awaitable[Any]],
        event: TelegramObject,
        data: Dict[str, Any],
    ) -> Any:
        logging.info(f'Middleware called handler: {handler}, event: {event}, data: {data}')
        data['message_service'] = self.service
        logging.info(f'Service: {data['message_service']}')
        return await handler(event, data)