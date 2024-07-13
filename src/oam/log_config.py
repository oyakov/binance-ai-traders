import logging.config

from oam.environment import APP_NAME, LOGGING_CONFIG_PATH
from subsystem.subsystem import Subsystem


class LoggerSubsystem(Subsystem):
    def __init__(self):
        self.logger = get_logger(__name__)
        self.initialize()
        self.app_logger = get_logger(APP_NAME)

    def initialize(self):
        self.logger.info(f"Initializing logger subsystem")
        logging.config.fileConfig(fname=LOGGING_CONFIG_PATH, disable_existing_loggers=False)
        self.logger.info(f"Logger subsystem is initialized")


# Get the logger specified in the file
def get_logger(name: str):
    return logging.getLogger(name)


def get_app_logger():
    return logging.getLogger(APP_NAME)
