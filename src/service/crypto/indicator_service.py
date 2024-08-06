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
                             fast_period: int = 12,
                             slow_period: int = 26,
                             signal_period: int = 9,
                             ) -> DataFrame:
        # Calculate MACD (Moving Average Convergence Divergence) indicator
        macd = DataFrame()
        macd['ema_fast'] = klines['close'].ewm(span=fast_period, adjust=False).mean()
        macd['ema_slow'] = klines['close'].ewm(span=slow_period, adjust=False).mean()
        macd['macd'] = macd['ema_fast'] - macd['ema_slow']
        macd['signal'] = klines['close'].ewm(span=signal_period, adjust=False).mean()
        macd['histogram'] = macd['macd'] - macd['signal']
        macd['timestamp'] = klines['timestamp']
        macd['display_time'] = pd.to_datetime(klines['timestamp'], unit='ms')
        logger.info(f"MACD is calculated for DataFrame: {klines.head()}")
        return macd

    # def calculate_ema(self, prices, window, previous_ema=None):
    #     if previous_ema is None:
    #         ema = prices.ewm(span=window, adjust=False).mean()
    #     else:
    #         alpha = 2 / (window + 1)
    #         ema = prices.copy()
    #         ema.iloc[0] = previous_ema
    #         for i in range(1, len(prices)):
    #             ema[i] = alpha * prices[i] + (1 - alpha) * ema[i - 1]
    #     return ema
