import pandas as pd
from pandas import DataFrame

from oam import log_config

# Initialize logger
logger = log_config.get_logger(__name__)


class IndicatorService:

    def __init__(self):
        logger.info("Indicator service initialized")

    async def calculate_macd(self,
                             klines: DataFrame,
                             prev_ema_fast: float = None,
                             prev_ema_slow: float = None,
                             prev_signal: float = None,
                             fast_period: int = 12,
                             slow_period: int = 26,
                             signal_period: int = 9,
                             ) -> DataFrame:
        # Calculate MACD (Moving Average Convergence Divergence) indicator
        macd = DataFrame()
        macd['ema_fast'] = self.calculate_ema(klines['close'], fast_period, prev_ema_fast)
        macd['ema_slow'] = self.calculate_ema(klines['close'], slow_period, prev_ema_slow)
        macd['macd'] = macd['ema_fast'] - macd['ema_slow']
        macd['signal'] = self.calculate_ema(macd['macd'], signal_period, prev_signal)
        macd['histogram'] = macd['macd'] - macd['signal']
        macd['timestamp'] = klines['timestamp']
        macd['display_time'] = pd.to_datetime(klines['timestamp'], unit='ms')
        logger.info(f"MACD is calculated for DataFrame: {klines.head()}")
        return macd

    def calculate_ema(self, prices, window, previous_ema=None):
        if previous_ema is None:
            ema = prices.ewm(span=window, adjust=False).mean()
        else:
            alpha = 2 / (window + 1)
            ema = prices.copy()
            ema[0] = previous_ema
            for i in range(1, len(prices)):
                ema[i] = alpha * prices[i] + (1 - alpha) * ema[i - 1]
        return ema
