import asyncio

from aiogram import Bot
from injector import inject

from inject.bot_injector import injector
from oam import log_config
# Subsystems
from oam.environment import COROUTINE_DEBUG
from routers.base_router import BaseRouter
from subsystem.slave_bot_subsystem import SlaveBotSubsystem
from subsystem.subsystem import Subsystem
from subsystem.subsystem_manager import SubsystemManager

############################################################################
# logging - Logger subsystem is initialized first
logger = log_config.get_logger(__name__)


############################################################################

async def main(bot: Bot,
               subsystem_manager: SubsystemManager,
               subsystems_: list[Subsystem],
               routers_: list[BaseRouter],
               bot_sub: SlaveBotSubsystem) -> None:
    """Initialize application subsystems concurrently"""
    await subsystem_manager.initialize_subsystems(subsystems_)
    # Start the bot
    await subsystem_manager.initialize_subsystems([bot_sub])


# Run the application
if __name__ == '__main__':
    logger.info(f"Debug coroutines: {COROUTINE_DEBUG}")
    sub_manager = injector.get(SubsystemManager)
    worker_bot_instance = injector.get(Bot)
    subsystems = injector.get(list[Subsystem])
    routers = injector.get(list[BaseRouter])
    worker_bot_subsystem = injector.get(SlaveBotSubsystem)
    logger.info(f"Master Bot instantiated, running the main loop...")
    try:
        asyncio.run(
            main(bot=worker_bot_instance,
                 subsystem_manager=sub_manager,
                 subsystems_=subsystems,
                 routers_=routers,
                 bot_sub=worker_bot_subsystem),
            debug=COROUTINE_DEBUG)
    except (SystemExit, KeyboardInterrupt) as ex:
        logger.warning(f"Bot stopped with interrupt {ex}")
    except () as err:
        logger.error(f"Bot stopped with error {err}")
