# Description: MACD indicator calculation using pandas DataFrame.
# https://en.wikipedia.org/wiki/MACD
from pandas import Series

from oam import log_config

logger = log_config.get_logger(__name__)


class MACD:
    def __init__(self):
        self.ema_fast: Series | None = None
        self.ema_slow: Series | None = None
        self.macd: Series | None = None
        self.signal: Series | None = None
        self.histogram: Series | None = None
        logger.info("MACD is initialized")
