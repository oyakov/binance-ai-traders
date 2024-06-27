from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import text, select

from db.config import *
from db.model.calendar_dom import CalendarDoM
from db.model.calendar_dow import CalendarDoW
from db.model.calendar_moy import CalendarMoY
from db.model.calendar_tod import CalendarToD
from service.telegram_service import send_telegram_message

############################################################################
# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)


############################################################################


async def check_calendar(bot: Bot):
    """
    Check all periodic message schedules and send only the required messages
    """
    calendar_entries = await load_calendar_data_all()
    logger.info(f"calendar entries: {calendar_entries}")
    for username, data, dow_id, dom_id, moy_id, tod_id in calendar_entries:
        # Construct the message to be sent
        logger.info(f"Send telegram message for username {username}")
        await send_telegram_message(bot, '-1002060021902', data)


async def load_calendar_data_all() -> list:
    """
    Load all periodic message schedules from the database
    """
    async with get_db() as session:
        async with session.begin():
            stmt = text('''
            SELECT 
                cd.username as username,
                cd.data as data,
                cd.dow_id as dow_id,
                cd.dom_id as dom_id,
                cd.moy_id as moy_id,
                cd.tod_id as tod_id
            from calendar_data cd''')
            calendar_entries = await session.execute(stmt)
            return calendar_entries.fetchall()


async def load_calendars(dow_id: int, dom_id: int, moy_id: int, tod_id: int):
    """
    Load all the calendars related to the periodic message by ids
    """
    async with get_db() as session:
        async with session.begin():
            logger.info("load calendars")
            stmt = select(CalendarDoW).where(CalendarDoW.id == dow_id)
            calendar_dow_entries = await session.execute(stmt)
            return calendar_dow_entries.fetchall()


async def init_scheduler(bot: Bot):
    """
    Initialize the periodic job for sending messages
    Job will run approximately every minute and will check if this minute there are
    messages which schedule has arrived and send those messages to the configured list of chats
    """
    logger.info("Initialize the scheduler job")
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=[bot], minutes=1)
    scheduler.start()
    logger.info("Scheduler initialized")
