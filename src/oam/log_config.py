import logging.config

from oam.environment import APP_NAME, LOGGING_CONFIG_PATH


# Get the logger specified in the file
def get_logger(name: str):
    return logging.getLogger(name)


def get_app_logger():
    return logging.getLogger(APP_NAME)
