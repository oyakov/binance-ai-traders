from src import log_config

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from src.db.repository.calendar_repository import CalendarRepository
from src.service.telegram_service import TelegramService


logger = log_config.get_logger(__name__)

calendar_repository = CalendarRepository()
telegram_service = TelegramService()


async def check_calendar(bot: Bot):
    """
    Check all periodic message schedules and send only the required messages
    """
    calendar_entries = await calendar_repository.load_calendar_data_all()
    logger.info(f"calendar entries: {calendar_entries}")
    for chat_id, username, data, dow_id, dom_id, moy_id, tod_id in calendar_entries:
        # Construct the message to be sent
        logger.info(f"Send telegram message {data} to chat_id {chat_id} for customer {username}")
        await telegram_service.send_telegram_message(bot, chat_id, data)


async def initialize_message_sender_job(bot: Bot, interval_minutes: int = 1):
    """
    Initialize the periodic job for sending messages
    Job will run approximately every interval_minutes and will check if this time there are messages
    which schedule has arrived and send those messages to the configured list of chats
    """
    logger.info("Initialize the scheduler job")
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=[bot], minutes=interval_minutes)
    scheduler.start()
    logger.info("Scheduler is initialized")
