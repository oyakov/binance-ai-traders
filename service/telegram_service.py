from aiogram import Bot

async def send_telegram_message(bot: Bot, chat_id: int, text: str):
    await bot.send_message(chat_id, text)
