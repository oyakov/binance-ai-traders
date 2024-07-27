from pandas import DataFrame

from oam import log_config
from service.crypto.indicators.macd import MACD

# Initialize logger
logger = log_config.get_logger(__name__)


class IndicatorService:

    def __init__(self):
        logger.info("Indicator service initialized")

    async def calculate_macd(self,
                             df: DataFrame,
                             fast_period: int = 12,
                             slow_period: int = 26,
                             signal_period: int = 9) -> MACD:
        # Calculate MACD (Moving Average Convergence Divergence)
        macd = MACD()
        macd.ema_fast = df['close'].ewm(span=fast_period, adjust=False).mean()
        macd.ema_slow = df['close'].ewm(span=slow_period, adjust=False).mean()
        macd.macd = df['ema_fast'] - df['ema_slow']
        macd.signal = df['macd'].ewm(span=signal_period, adjust=False).mean()
        macd.histogram = df['macd'] - df['signal']
        logger.info(f"MACD calculated for DataFrame: {df.head()}")
        return macd
