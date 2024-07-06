import asyncio
import logging
import os

# aiogram
from aiogram import Bot
from dotenv import load_dotenv

# Project dependencies
import db.config as db_config
from db.repository.telegram_group_repository import populate_test_groups
from routers.configuration_router import configuration_router
# Routers
from routers.dispatcher import create_dispatcher
from routers.new_message_router import new_message_router
from routers.openai_router import openai_router
# Subsystems
from subsystem.scheduler import initialize_message_sender_job

load_dotenv()

############################################################################
# Access the variables
API_TOKEN = os.getenv('BOT_TOKEN')
CHAT_ID = os.getenv('CHAT_ID')
DEBUG_CORO = os.getenv('COROUTINE_DEBUG')
############################################################################
# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)
############################################################################


async def initialize_database() -> None:
    """Auto-create database table schema from the model classes and populate test data"""
    logger.info(f"Initializing the DB")
    try:
        await db_config.create_tables()
        logger.info(f"Tables are created")
        await populate_test_groups()
        logger.info(f"Database is initialized")
    except() as exception:
        logger.error(f"Error initializing the database {exception}")


async def initialize_bot(bot: Bot) -> None:
    """Launch telegram bot API server connection"""
    logger.info(f"Initializing bot {bot}")
    dispatcher = create_dispatcher([new_message_router,
                                    configuration_router,
                                    openai_router], bot)
    # Launch bot
    await dispatcher.start_polling(bot)


async def main(bot: Bot) -> None:
    """Initialize application subsystems concurrently"""
    await asyncio.gather(
        initialize_database(),
        initialize_bot(bot=bot),
        initialize_message_sender_job(bot=bot, interval_minutes=1))

# Run the application
if __name__ == '__main__':
    logger.info(f"Debug coroutines: {DEBUG_CORO}")    
    bot_instance = Bot(token=API_TOKEN)
    logger.info(f"Bot instance created: {bot_instance}")
    try:
        asyncio.run(
            main(bot=bot_instance),
            debug=DEBUG_CORO)
    except(SystemExit, KeyboardInterrupt) as ex:
        logger.warning(f"Bot stopped with interrupt {ex}")
    except() as err:
        logger.error(f"Bot stopped with error {err}")
