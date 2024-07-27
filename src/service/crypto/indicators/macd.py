# Description: MACD indicator calculation using pandas DataFrame.
# https://en.wikipedia.org/wiki/MACD
from oam import log_config

logger = log_config.get_logger(__name__)


class MACD:
    def __init__(self):
        logger.info("MACD initialized")
        self.ema_fast = None
        self.ema_slow = None
        self.macd = None
        self.signal = None
        self.histogram = None