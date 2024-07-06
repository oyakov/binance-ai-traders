import logging

from routers.configuration_router import configuration_router
from routers.dispatcher import create_dispatcher
from routers.new_message_router import new_message_router
from routers.openai_router import openai_router
from subsystem.subsystem import Subsystem

logger = logging.getLogger(__name__)


class BotSubsystem(Subsystem):
    def __init__(self, bot):
        self.bot = bot

    async def initialize(self):
        logger.info(f"Initializing bot {self.bot}")
        dispatcher = create_dispatcher([new_message_router,
                                        configuration_router,
                                        openai_router], self.bot)
        await dispatcher.start_polling(self.bot)
        logger.info(f"Bot is initialized")
