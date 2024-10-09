from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from db.repository.calendar_repository import CalendarRepository
from oam import log_config
from service.telegram_service import TelegramService

logger = log_config.get_logger(__name__)

calendar_repository = CalendarRepository()
telegram_service = TelegramService()


async def check_calendar(bot: Bot):
    """
    Check all periodic message schedules and send only the required messages
    """
    logger.debug(f"Advertiser job is engaged")
    try:
        for calendar_entry in await calendar_repository.load_calendar_data_all():
            # Construct the message to be sent
            logger.debug(f"{calendar_entry}")
            logger.debug(
                f"Send telegram message {calendar_entry.data} to chat_id {calendar_entry.chat_id} for customer {calendar_entry.username}")
            await telegram_service.send_advertisement(
                bot,
                calendar_entry.chat_id,
                calendar_entry.data)
    except Exception as e:
        logger.error(f"Error sending periodic message: {e}\n\t"
                     f"Error class:{e.__class__}")


async def initialize_advertiser(bot: Bot, interval_minutes: int = 1):
    """
    Initialize the periodic job for sending messages
    Job will run approximately every interval_minutes and will check if this time there are messages
    which schedule has arrived and send those messages to the configured list of chats
    """
    logger.info("Initialize the advertiser job")
    scheduler = AsyncIOScheduler()
    scheduler.add_job(check_calendar, 'interval', args=[bot], minutes=interval_minutes)
    scheduler.start()
    logger.info("Advertiser is initialized")
