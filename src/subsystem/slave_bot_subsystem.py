from injector import inject

from oam import log_config
from routers.base_router import BaseRouter

from routers.dispatcher import create_dispatcher
from routers.gateway_router import configure_gateway_router
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class SlaveBotSubsystem(Subsystem):

    @inject
    def __init__(self, bot, routers: list[BaseRouter]):
        self.bot = bot
        self.routers = routers

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing bot {self.bot}")
        dispatcher = create_dispatcher([configure_gateway_router(self.routers)], self.bot)
        await dispatcher.start_polling(self.bot)
        logger.info(f"Bot is initialized")
        self.is_initialized = True

    async def shutdown(self):
        logger.info(f"Shutting down bot {self.bot}")
        self.is_initialized = False

    def get_priority(self):
        return InitPriority.TELEGRAM_ROUTER
