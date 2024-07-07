from aiogram import Bot


async def send_telegram_message(bot: Bot, chat_id: str, text: str):
    """Send Telegram message to the chat id"""
    await bot.send_message(chat_id, text)
