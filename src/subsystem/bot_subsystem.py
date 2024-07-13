from oam import log_config

from routers.dispatcher import create_dispatcher
from routers.gateway_router import gateway_router
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BotSubsystem(Subsystem):
    def __init__(self, bot):
        self.bot = bot

    async def initialize(self):
        logger.info(f"Initializing bot {self.bot}")
        dispatcher = create_dispatcher([gateway_router], self.bot)
        await dispatcher.start_polling(self.bot)
        logger.info(f"Bot is initialized")
