from aiogram import Bot

from oam import log_config

logger = log_config.get_logger(__name__)


class TelegramService:
    @staticmethod
    async def send_advertisement(bot: Bot, chat_id: str, text: str):
        """Send advertisement to the chat id"""
        await bot.send_message(chat_id, "*Advertisement Bot*\n" + text, parse_mode="Markdown")
