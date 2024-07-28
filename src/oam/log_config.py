import logging.config
import traceback

from oam.environment import APP_NAME, LOGGING_CONFIG_PATH


class CustomLogger(logging.getLoggerClass()):
    def error(self, msg, *args, exc_info=None, **kwargs):
        if exc_info:
            msg = f"{msg}: {exc_info.__class__}\n\t{exc_info}\n\t{traceback.format_exc()}"
        super().error(msg, *args, **kwargs)


logging.setLoggerClass(CustomLogger)


# Get the logger specified in the file
def get_logger(name: str):
    return logging.getLogger(name)


def get_app_logger():
    return logging.getLogger(APP_NAME)
