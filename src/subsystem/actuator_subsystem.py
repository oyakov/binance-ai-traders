from oam import log_config
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class ActuatorSubsystem(Subsystem):
    def __init__(self, bot, router, subsystem_manager):
        self.bot = bot
        self.router = router
        self.subsystem_manager = subsystem_manager

    async def initialize(self):
        logger.info(f"Initializing Actuator subsystem {self.bot}")
        self.is_initialized = True

    async def collect_health_data(self):
        """
        Collect and print health data from all the subsystems
        """
        logger.info("SUBSYSTEM HEALTH DATA")
        for subsystem in self.subsystem_manager.subsystems:
            logger.info(f"{subsystem.__class__} initialized: {subsystem.is_initialized }")

    async def shutdown(self):
        logger.info(f"Shutting down Actuator subsystem")

    def get_router(self):
        return self.router
