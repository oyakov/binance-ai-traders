import logging.config
import os

from oam.environment import APP_NAME, LOGGING_CONFIG_PATH
from oam.log_config import get_logger
from subsystem.subsystem import Subsystem, InitPriority


class LoggerSubsystem(Subsystem):

    def __init__(self):
        self.logger = get_logger(__name__)
        self.app_logger = get_logger(APP_NAME)

    async def initialize(self, subsystem_manager):
        self.logger.info(f"Initializing logger subsystem")
        
        # Check if JSON logging is enabled via environment variable
        logging_profile = os.getenv('LOGGING_PROFILE', 'default')
        json_logging_config = os.getenv('PYTHON_LOGGING_CONFIG')
        
        if logging_profile == 'json' and json_logging_config:
            self.logger.info(f"Loading JSON logging configuration from {json_logging_config}")
            logging.config.fileConfig(fname=json_logging_config, disable_existing_loggers=False)
        elif LOGGING_CONFIG_PATH:
            self.logger.info(f"Loading standard logging configuration from {LOGGING_CONFIG_PATH}")
            logging.config.fileConfig(fname=LOGGING_CONFIG_PATH, disable_existing_loggers=False)
        else:
            self.logger.warning("No logging configuration path specified, using default logging")
        
        # Add correlation ID filter to all handlers
        self._add_correlation_filter()
        
        self.logger.info(f"Logger subsystem is initialized")

    def _add_correlation_filter(self):
        """Add correlation ID to log records"""
        try:
            from oam.correlation import get_correlation_id
            
            class CorrelationIdFilter(logging.Filter):
                def filter(self, record):
                    record.correlation_id = get_correlation_id() or 'NO-CORR-ID'
                    return True
            
            # Add filter to all handlers
            for handler in logging.root.handlers:
                handler.addFilter(CorrelationIdFilter())
                
        except ImportError:
            self.logger.warning("Could not import correlation module, correlation IDs will not be added to logs")

    async def shutdown(self):
        pass

    def get_priority(self) -> InitPriority:
        return InitPriority.CRITICAL
