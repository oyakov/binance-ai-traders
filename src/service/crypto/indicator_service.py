import pandas as pd
from pandas import DataFrame
from scipy.stats import linregress

from oam import log_config

UPWARD = "Upward"
DOWNWARD = "Downward"
NO_CLEAR_TREND = "No Clear Trend"

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
        logger.info(f"MACD is calculated for DataFrame: {macd}")
        return macd

    def trend_regression(self, series: pd.Series, window: int = 5) -> (int, str):
        # Consider only the last `window` values
        recent_hist = series.tail(window)

        # Fit a linear regression line
        slope, _, _, _, _ = linregress(range(len(recent_hist)), recent_hist)

        # Determine the trend based on the slope
        if slope > 0:
            return slope, UPWARD
        elif slope < 0:
            return slope, DOWNWARD
        else:
            return slope, NO_CLEAR_TREND

    def generate_signals(self, df: DataFrame) -> DataFrame:
        df['signal_buy'] = ((df['macd'] > df['signal']) & (df['macd'].shift(1) <= df['signal'].shift(1)))
        df['signal_sell'] = ((df['macd'] < df['signal']) & (df['macd'].shift(1) >= df['signal'].shift(1)))
        df['volume_signal'] = True #df['volume'] > df['volume'].rolling(window=20).mean() * 1.5  # Example volume condition

        df['buy'] = df['signal_buy'] & df['volume_signal']
        df['sell'] = df['signal_sell'] & df['volume_signal']
        return df

    def calculate_rsi(self, prices: pd.Series, period: int = 14) -> pd.Series:
        """Calculate the Relative Strength Index (RSI) for a given price series."""
        delta = prices.diff()
        gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
        loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()

        rs = gain / loss
        rsi = 100 - (100 / (1 + rs))

        return rsi

    def calculate_bollinger_bands(self, prices: pd.Series, period: int = 20, std_dev_multiplier: int = 2):
        """Calculate Bollinger Bands for a given price series."""
        sma = prices.rolling(window=period).mean()
        std_dev = prices.rolling(window=period).std()

        upper_band = sma + (std_dev_multiplier * std_dev)
        lower_band = sma - (std_dev_multiplier * std_dev)

        return upper_band, lower_band

    def calculate_atr(self, high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> pd.Series:
        """Calculate the Average True Range (ATR) for a given period."""
        high_low = high - low
        high_close = (high - close.shift()).abs()
        low_close = (low - close.shift()).abs()
        true_range = pd.concat([high_low, high_close, low_close], axis=1).max(axis=1)
        atr = true_range.rolling(window=period).mean()
        return atr