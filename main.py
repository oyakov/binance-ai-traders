import asyncio
import logging
import os
import db.config as db_config
from db.repository.telegram_group_repository import populate_test_groups
from routers.new_message_router import new_message_router
from subsystem.scheduler import initialize_scheduler
# aiogram
from aiogram import Bot, Dispatcher
from aiogram.fsm.storage.memory import SimpleEventIsolation
from dotenv import load_dotenv

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


def create_dispatcher():
    # Event isolation is needed to correctly handle fast user responses
    dispatcher = Dispatcher(
        events_isolation=SimpleEventIsolation(),
        # This is to enable DB Storage, temporarily commented out, needs some more work
        # storage=SQLAlchemyStorage()
    )
    dispatcher.include_router(new_message_router)

    # To use scenes, you should create a SceneRegistry and register your scenes there
    # Scenes are not currently used as an implementation pattern, use FSM isntead
    # scene_registry = SceneRegistry(dispatcher)

    return dispatcher


async def initialize_db() -> None:
    """Auto-create database table schema from the model classes annd populate test data"""
    logger.info(f"Initializing the DB")
    await db_config.create_tables()
    logger.info("Tables are created")
    await populate_test_groups()
    logger.info(f"Database is initialized")


async def initialize_bot(bot: Bot) -> None:
    logger.info(f"Initializing bot {bot}")
    dispatcher = create_dispatcher()
    # Launch bot
    await dispatcher.start_polling(bot)


async def main(bot: Bot) -> None:
    """Initialize application subsystemms concurrently"""
    await asyncio.gather(
        initialize_db(),
        initialize_bot(bot=bot),
        initialize_scheduler(bot=bot))

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
        logger.error(f"Bot stopped with errot {err}")
