from apscheduler.schedulers.asyncio import AsyncIOScheduler
from db.config import get_db
from db.model.calendar_data import CalendarData
from service.telegram_service import send_telegram_message
from sqlalchemy.future import select
from aiogram import Bot
import logging

############################################################################
# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
############################################################################

async def check_calendar(bot: Bot):
    logger.info("job launched")
    async with get_db() as session:
        logger.info(f"session obtaned {session}")
        async with session.begin():        
            calendar_entries = await session.execute(select(CalendarData))
            calendar_entries: list[CalendarData] = calendar_entries.fetchall()
            logger.info(f"calendar entries: {calendar_entries}")
            for entry in calendar_entries:
                # Construct the message to be sent
                message = f"Entry {entry}"
                for key, value in entry.__dict__.items():
                    if not key.startswith('_'):
                        print(f"{key}: {value}")
                logger.info(f"Send telegram message for entry {entry}")
                user_id = await entry.awaitable_attrs.username
                await send_telegram_message(bot, user_id, message)

async def init_scheduler(bot: Bot):

    logger.info("Initailize the scheduler")
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=[bot], minutes=2)
    scheduler.start()
    logger.info("Scheduler initialized")
