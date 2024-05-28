import logging
import asyncio
from dataclasses import dataclass, field
from os import getenv
from typing import Any
# from dotenv import load_dotenv
# load_dotenv()

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

from config_scene import ConfigScene

############################################################################

API_TOKEN = '6853220461:AAGIJo2a3GIMMqgz1w9iISW3Lv7ZnvAoRa8'
CHAT_ID = '-1002060021902'

# Configure logging
logging.basicConfig(level=logging.INFO)

async def send_periodic_message(bot: Bot):
    while True:
        try:
            await bot.send_message(chat_id=CHAT_ID, text="This is a periodic message")
        except Exception as e:
            logging.error(f"Error sending message: {e}")
        await asyncio.sleep(10)  # Sleep for 1 hour

config_router = Router(name=__name__)
# Add handler that initializes the scene
config_router.message.register(ConfigScene.as_handler(), Command("config"))

def create_dispatcher():
    # Event isolation is needed to correctly handle fast user responses
    dispatcher = Dispatcher(
        events_isolation=SimpleEventIsolation(),
    )
    dispatcher.include_router(config_router)

    # To use scenes, you should create a SceneRegistry and register your scenes there
    scene_registry = SceneRegistry(dispatcher)
    # ... and then register a scene in the registry
    # by default, Scene will be mounted to the router that passed to the SceneRegistry,
    # but you can specify the router explicitly using the `router` argument
    scene_registry.add(ConfigScene)
    return dispatcher

async def main() -> None:
    spammer_bot = Bot(token=API_TOKEN)
    # loop = asyncio.get_event_loop();
    # loop.create_task(send_periodic_message(bot=spammer_bot))
    # loop.get_debug()
    dispatcher = create_dispatcher()
    await dispatcher.start_polling(spammer_bot)

if __name__ == '__main__':
    asyncio.run(main())
    