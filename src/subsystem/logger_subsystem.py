import logging.config

from oam.environment import APP_NAME, LOGGING_CONFIG_PATH
from oam.log_config import get_logger
from subsystem.subsystem import Subsystem, InitPriority


class LoggerSubsystem(Subsystem):

    def __init__(self):
        self.logger = get_logger(__name__)
        self.app_logger = get_logger(APP_NAME)

    async def initialize(self, subsystem_manager):
        self.logger.info(f"Initializing logger subsystem")
        logging.config.fileConfig(fname=LOGGING_CONFIG_PATH, disable_existing_loggers=False)
        self.logger.info(f"Logger subsystem is initialized")

    async def shutdown(self):
        pass

    def get_priority(self) -> InitPriority:
        return InitPriority.CRITICAL
