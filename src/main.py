import asyncio
from oam import log_config

from aiogram import Bot

# Subsystems
from oam.environment import MASTER_BOT_TOKEN, COROUTINE_DEBUG
from routers.binance_router import binance_router
from routers.configuration_router import configuration_router
from routers.new_message_router import new_message_router
from routers.openai_router import openai_router
from subsystem.bot_subsystem import MasterBotSubsystem
from subsystem.database_subsystem import DatabaseSubsystem
from subsystem.openai_subsystem import OpenAiSubsystem
from subsystem.scheduler_subsystem import SchedulerSubsystem
from subsystem.subsystem_manager import subsystem_manager


############################################################################
# logging - Logger subsystem is initialized first
log_subsystem = log_config.LoggerSubsystem()
await subsystem_manager.initialize_subsystems([log_subsystem])
logger = log_config.get_logger(__name__)
############################################################################


async def main(bot: Bot) -> None:
    """Initialize application subsystems concurrently"""
    subsystems = [
        DatabaseSubsystem(),
        SchedulerSubsystem(bot, interval_minutes=1),
        OpenAiSubsystem(bot, openai_router),
        BinanceSubsystem(bot, binance_router)
    ]
    await subsystem_manager.initialize_subsystems(subsystems)

    bot_sub = MasterBotSubsystem(bot, routers=[configuration_router, binance_router, new_message_router, openai_router])
    await subsystem_manager.initialize_subsystems([bot_sub])

# Run the application
if __name__ == '__main__':
    logger.info(f"Debug coroutines: {COROUTINE_DEBUG}")
    master_bot_instance = Bot(token=MASTER_BOT_TOKEN)
    logger.info(f"Master Bot instantiated, running the main loop...")
    try:
        asyncio.run(
            main(bot=master_bot_instance),
            debug=COROUTINE_DEBUG)
    except(SystemExit, KeyboardInterrupt) as ex:
        logger.warning(f"Bot stopped with interrupt {ex}")
    except() as err:
        logger.error(f"Bot stopped with error {err}")
