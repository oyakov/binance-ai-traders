from aiogram import Dispatcher, Router, Bot
from aiogram.fsm.storage.memory import SimpleEventIsolation
from aiogram.types import Message

from oam import log_config

logger = log_config.get_logger(__name__)

bot_instance: Bot | None = None


async def on_new_chat_member(message: Message):
    if message.new_chat_members:
        for new_member in message.new_chat_members:
            if new_member.id == (await bot_instance.me).id:
                group_id = message.chat.id
                logger.info(f'Bot added to a new group: {group_id}')
                await message.reply("Hello, group! I've been added to this group.")


async def on_left_chat_member(message: Message):
    if message.left_chat_member.id == (await bot_instance.me).id:
        group_id = message.chat.id
        logger.info(f'Bot removed from the group: {group_id}')


def create_dispatcher(routers: list[Router], bot: Bot) -> Dispatcher:
    """Create aiogram root router (dispatcher) all child routers are added there"""
    logger.info("Creating dispatcher")
    # Event isolation is needed to correctly handle fast user responses
    dispatcher = Dispatcher(
        events_isolation=SimpleEventIsolation(),
        # This is to enable DB Storage, temporarily commented out, needs some more work
        # storage=SQLAlchemyStorage()
    )

    # Add all the routers to root router (dispatcher)
    for router in routers:
        logger.info(f"Add router {router}")
        dispatcher.include_router(router)

    # To use scenes, you should create a SceneRegistry and register your scenes there
    # Scenes are not currently used as an implementation pattern, use FSM isntead
    # scene_registry = SceneRegistry(dispatcher)

    logger.info(f"Dispatcher is created {dispatcher}")
    bot_instance = bot
    return dispatcher


