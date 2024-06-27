from apscheduler.schedulers.asyncio import AsyncIOScheduler
from db.model.calendar_data import CalendarData
from service.telegram_service import send_telegram_message
from aiogram import Bot
from db.config import *
from sqlalchemy import text

############################################################################
# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
############################################################################


async def check_calendar(bot: Bot):
    logger.info("job launched")
    async with get_db() as session:
        logger.info(f"session obtained {session}")
        async with session.begin():
            stmt = text('''
            SELECT 
                cd.username as username,
                cd.data as data
            from calendar_data cd''')
            calendar_entries = await session.execute(stmt)
            calendar_entries = calendar_entries.fetchall()
            logger.info(f"calendar entries: {calendar_entries}")
            for username, data in calendar_entries:
                # Construct the message to be sent
                logger.info(f"Send telegram message for username {username}")
                await send_telegram_message(bot, '-1002060021902', data)


async def init_scheduler(bot: Bot):
    """
    Initialize the periodic job for sending messages
    """
    logger.info("Initialize the scheduler job")
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=[bot], minutes=1)
    scheduler.start()
    logger.info("Scheduler initialized")
