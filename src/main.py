import asyncio
from src import log_config

from aiogram import Bot

# Subsystems
from src.environment import BOT_TOKEN, COROUTINE_DEBUG
from subsystem.bot_subsystem import BotSubsystem
from subsystem.database_subsystem import DatabaseSubsystem
from subsystem.scheduler_subsystem import SchedulerSubsystem


############################################################################
# logging - Logger subsystem is initialized first
subsystem = log_config.LoggerSubsystem()
subsystem.initialize()
logger = log_config.get_logger(__name__)
############################################################################


async def main(bot: Bot) -> None:
    """Initialize application subsystems concurrently"""
    subsystems = [
        DatabaseSubsystem(),
        BotSubsystem(bot),
        SchedulerSubsystem(bot, interval_minutes=1)
    ]
    await asyncio.gather(*(subsys.initialize() for subsys in subsystems))

# Run the application
if __name__ == '__main__':
    logger.info(f"Debug coroutines: {COROUTINE_DEBUG}")
    bot_instance = Bot(token=BOT_TOKEN)
    logger.info(f"Bot instance created: {bot_instance}")
    try:
        asyncio.run(
            main(bot=bot_instance),
            debug=COROUTINE_DEBUG)
    except(SystemExit, KeyboardInterrupt) as ex:
        logger.warning(f"Bot stopped with interrupt {ex}")
    except() as err:
        logger.error(f"Bot stopped with error {err}")
