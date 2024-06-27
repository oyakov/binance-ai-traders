import asyncio
import logging
import os
import db.config as db_config

from dotenv import load_dotenv
load_dotenv()

# aiogram
from aiogram import Bot, Dispatcher
from aiogram.fsm.scene import SceneRegistry
from aiogram.fsm.storage.memory import SimpleEventIsolation

from routers.new_message_router import new_message_router
from subsystem.scheduler import init_scheduler

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
    scene_registry = SceneRegistry(dispatcher)

    return dispatcher


async def initialize_bot(bot: Bot) -> None:
    await db_config.init_db()
    logger.info(f"Database is initialized")
    dispatcher = create_dispatcher()
    # Launch bot
    await dispatcher.start_polling(bot)


async def main(bot: Bot) -> None:
    # Run both the bot and scheduler concurrently
    await asyncio.gather(
        initialize_bot(bot=bot),
        init_scheduler(bot=bot)
    )

if __name__ == '__main__':
    logger.info(f"Debug coroutines: {DEBUG_CORO}")    
    bot_instance = Bot(token=API_TOKEN)
    logger.info(f"Bot instance created: {bot_instance}")
    try:
        asyncio.run(main(bot=bot_instance), debug=DEBUG_CORO, loop_factory=None)
    except(SystemExit, KeyboardInterrupt) as int:
        logger.warning(f"Bot stopped with interrupt {int}")
    except() as err:
        logger.error(f"Bot stopped with errot {err}")