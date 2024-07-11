from binance.client import Client
import pandas as pd

from src import log_config
from src.environment import BINANCE_TOKEN, BINANCE_SECRET_TOKEN

logger = log_config.get_logger(__name__)


class BinanceService:

    def __init__(self):
        self.client = Client(BINANCE_TOKEN, BINANCE_SECRET_TOKEN)

    async def get_account_info(self):
        # Get account information
        account_info = self.client.get_account()
        logger.info(account_info)
        return account_info

    async def get_ticker(self, symbol):
        # Get ticker information for a specific symbol
        ticker = self.client.get_ticker(symbol=symbol)
        logger.info(ticker)
        return ticker

    async def get_klines(self, symbol):
        # Get historical candlestick data for a specific symbol
        candles = self.client.get_klines(symbol=symbol, interval=Client.KLINE_INTERVAL_1MINUTE)

        # Convert to DataFrame for easier manipulation
        df = pd.DataFrame(candles, columns=[
            'timestamp', 'open', 'high', 'low', 'close', 'volume',
            'close_time', 'quote_asset_volume', 'number_of_trades',
            'taker_buy_base_asset_volume', 'taker_buy_quote_asset_volume', 'ignore'
        ])
        logger.info(df)
        return df
