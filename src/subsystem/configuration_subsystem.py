from oam import log_config
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class ConfigurationSubsystem(Subsystem):
    def __init__(self, bot, router):
        self.bot = bot
        self.router = router

    async def initialize(self):
        logger.info(f"Initializing Configuration subsystem {self.bot}")
        self.is_initialized = True

    async def shutdown(self):
        logger.info(f"Shutting down Configuration subsystem")

    def get_router(self):
        return self.router
