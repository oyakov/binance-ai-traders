from aiogram import Bot

from src import log_config

logger = log_config.get_logger(__name__)


class TelegramService:
    @staticmethod
    async def send_telegram_message(bot: Bot, chat_id: str, text: str):
        """Send Telegram message to the chat id"""
        await bot.send_message(chat_id, text)
