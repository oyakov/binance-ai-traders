from apscheduler.schedulers.asyncio import AsyncIOScheduler
from db.config import get_session
from db.model.calendar_data import CalendarData
from service.telegram_service import send_telegram_message
from aiogram import Bot
import asyncio

async def check_calendar(bot: Bot):
    async with get_session() as session:
        calendar_entries = await session.execute(CalendarData.select())
        calendar_entries = calendar_entries.fetchall()
        for entry in calendar_entries:
            # Construct the message to be sent
            message = f"Entry {entry}"
            await send_telegram_message(bot, entry.user_id, message)

async def init_scheduler(bot: Bot):
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=bot, minutes=15)
    scheduler.start()

    try:
        # To keep the script running
        asyncio.get_event_loop().run_forever()
    except (KeyboardInterrupt, SystemExit):
        pass
