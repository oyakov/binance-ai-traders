import logging
import asyncio
import os
from dataclasses import dataclass, field
from typing import Any
from db.storage import SQLAlchemyStorage
from dotenv import load_dotenv
load_dotenv()

# aiogram
from aiogram import Bot, Dispatcher, types, F, Router, html
from aiogram.filters import CommandStart, Command
from aiogram.fsm.scene import SceneRegistry, on

from aiogram.fsm.storage.memory import SimpleEventIsolation
from aiogram.utils.formatting import (
    Bold,
    as_key_value,
    as_list,
    as_numbered_list,
    as_section,
)

from routers.new_message_router import new_message_router
import db.config as db_config

############################################################################
# Access the variables
API_TOKEN = os.getenv('BOT_TOKEN')
CHAT_ID = os.getenv('CHAT_ID')
DEBUG_CORO = os.getenv('COROUTINE_DEBUG')

# logging
logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

async def send_periodic_message(bot: Bot):
    while True:
        try:
            await bot.send_message(chat_id=CHAT_ID, text="This is a periodic message")
        except Exception as e:
            logger.error(f"Error sending message: {e}")
        await asyncio.sleep(10)  # Sleep for 1 hour


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

async def main() -> None:
    spammer_bot = Bot(token=API_TOKEN)
    await db_config.init_db()
    dispatcher = create_dispatcher()
    # Launch bot
    await dispatcher.start_polling(spammer_bot)

if __name__ == '__main__':
    logger.info(f"Debug coroutines: {DEBUG_CORO}")
    try:
        asyncio.run(main(), debug=DEBUG_CORO, loop_factory=None)
    except(SystemExit, KeyboardInterrupt) as int:
        logger.warning(f"Bot stopped with interrupt {int}")
    except() as err:
        logger.error(f"Bot stopped with errot {err}")