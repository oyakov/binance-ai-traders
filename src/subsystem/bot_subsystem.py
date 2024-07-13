from oam import log_config
from routers.base_router import BaseRouter

from routers.dispatcher import create_dispatcher
from routers.gateway_router import configure_gateway_router
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class MasterBotSubsystem(Subsystem):

    def __init__(self, bot, routers: list[BaseRouter]):
        self.bot = bot
        self.routers = routers

    async def initialize(self):
        logger.info(f"Initializing bot {self.bot}")
        dispatcher = create_dispatcher([configure_gateway_router(self.routers)], self.bot)
        await dispatcher.start_polling(self.bot)
        logger.info(f"Bot is initialized")

    async def shutdown(self):
        pass
