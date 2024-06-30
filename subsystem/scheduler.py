import logging

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from service.telegram_service import send_telegram_message
from db.repository import calendar_repository

############################################################################
# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
############################################################################


async def check_calendar(bot: Bot):
    """
    Check all periodic message schedules and send only the required messages
    """
    calendar_entries = await calendar_repository.load_calendar_data_all()
    logger.info(f"calendar entries: {calendar_entries}")
    for username, data, dow_id, dom_id, moy_id, tod_id in calendar_entries:
        # Construct the message to be sent
        logger.info(f"Send telegram message for username {username}")
        await send_telegram_message(bot, '-1002060021902', data)


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
