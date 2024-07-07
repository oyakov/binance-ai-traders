import logging.config

from src.subsystem.subsystem import Subsystem


class LoggerSubsystem(Subsystem):
    def __init__(self):
        self.logger = get_logger(__name__)

    async def initialize(self):
        self.logger.info(f"Initializing logger subsystem")
        logging.config.fileConfig(fname='logging.ini', disable_existing_loggers=False)
        self.logger.info(f"Logger subsystem is initialized")


# Get the logger specified in the file
def get_logger(name):
    return logging.getLogger(name)
