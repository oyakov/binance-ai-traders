import asyncio
import logging
import os

from aiogram import Bot
from dotenv import load_dotenv

# Subsystems
from subsystem.database_subsystem import DatabaseSubsystem
from subsystem.scheduler_subsystem import SchedulerSubsystem
from subsystem.bot_subsystem import BotSubsystem

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


async def main(bot: Bot) -> None:
    """Initialize application subsystems concurrently"""
    subsystems = [
        DatabaseSubsystem(),
        BotSubsystem(bot),
        SchedulerSubsystem(bot, interval_minutes=1)
    ]
    await asyncio.gather(*(subsystem.initialize() for subsystem in subsystems))

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
