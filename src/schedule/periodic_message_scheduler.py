from oam import log_config

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from db.model.calendars import CalendarData
from db.repository.calendar_repository import CalendarRepository
from service.telegram_service import TelegramService


logger = log_config.get_logger(__name__)

calendar_repository = CalendarRepository()
telegram_service = TelegramService()


async def check_calendar(bot: Bot):
    """
    Check all periodic message schedules and send only the required messages
    """
    for calendar_entry in await calendar_repository.load_calendar_data_all():
        # Construct the message to be sent
        logger.debug(f"Send telegram message {calendar_entry.data} to chat_id {calendar_entry.chat_id} for customer {calendar_entry.username}")
        await telegram_service.send_telegram_message(bot,
                                                     calendar_entry.chat_id,
                                                     calendar_entry.data)


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
