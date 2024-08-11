import pandas as pd
from pandas import DataFrame
from scipy.stats import linregress

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
        macd['signal'] = macd['macd'].ewm(span=signal_period, adjust=False).mean()
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

    def determine_macd_trend_regression(self, macd_hist: pd.Series, window: int = 5) -> str:
        # Consider only the last `window` values
        recent_hist = macd_hist.tail(window)

        # Fit a linear regression line
        slope, _, _, _, _ = linregress(range(len(recent_hist)), recent_hist)

        # Determine the trend based on the slope
        if slope > 0:
            return "Upward"
        elif slope < 0:
            return "Downward"
        else:
            return "No Clear Trend"
