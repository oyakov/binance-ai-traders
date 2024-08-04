import pandas as pd
from binance.client import Client

from oam import log_config
from oam.environment import BINANCE_TOKEN, BINANCE_SECRET_TOKEN

# Initialize logger
logger = log_config.get_logger(__name__)


class BinanceService:

    def __init__(self):
        # Initialize Binance client with API token and secret
        self.client = Client(BINANCE_TOKEN, BINANCE_SECRET_TOKEN)
        logger.info("Binance client initialized")

    async def get_account_info(self):
        # Get account information
        account_info = self.client.get_account()
        return account_info

    async def get_asset_balance(self, asset):
        # Get the balance of a specific asset
        balance = self.client.get_asset_balance(asset=asset)
        return balance

    async def get_ticker(self, symbol):
        # Get ticker information for a specific symbol
        ticker = self.client.get_ticker(symbol=symbol)
        return ticker

    async def get_klines(self,
                         symbol,
                         interval=Client.KLINE_INTERVAL_1MINUTE,
                         start_time=None,
                         end_time=None,
                         timezone='0',
                         limit=500):
        # Get historical candlestick data for a specific symbol
        candles = self.client.get_klines(symbol=symbol,
                                         interval=interval,
                                         startTime=start_time,
                                         endTime=end_time,
                                         timeZone=timezone,
                                         limit=limit,)

        # Convert to DataFrame for easier manipulation
        df = pd.DataFrame(candles, columns=[
            'timestamp',
            'open',
            'high',
            'low',
            'close',
            'volume',
            'close_time',
            'quote_asset_volume',
            'number_of_trades',
            'taker_buy_base_asset_volume',
            'taker_buy_quote_asset_volume',
            'ignore'
        ])

        # Convert specified columns to float
        df[
            ['open',
             'high',
             'low',
             'close',
             'volume',
             'quote_asset_volume',
             'taker_buy_base_asset_volume',
             'taker_buy_quote_asset_volume']
        ] = df[
            ['open',
             'high',
             'low',
             'close',
             'volume',
             'quote_asset_volume',
             'taker_buy_base_asset_volume',
             'taker_buy_quote_asset_volume']
        ].astype(float)

        df['timestamp'] = pd.to_datetime(df['timestamp'], unit='ms')
        df['close_time'] = pd.to_datetime(df['close_time'], unit='ms')
        return df



    async def get_all_tickers(self):
        # Get ticker information for all symbols
        tickers = self.client.get_all_tickers()
        return tickers

    async def get_order_book(self, symbol, limit=100):
        # Get the order book for a specific symbol
        order_book = self.client.get_order_book(symbol=symbol, limit=limit)
        return order_book

    async def get_my_trades(self, symbol, limit=500):
        # Get trades for the current account
        my_trades = self.client.get_my_trades(symbol=symbol, limit=limit)
        return my_trades

    async def get_recent_trades(self, symbol, limit=500):
        # Get recent trades for a specific symbol
        recent_trades = self.client.get_recent_trades(symbol=symbol, limit=limit)
        return recent_trades

    async def get_historical_trades(self, symbol, limit=500, from_id=None):
        # Get historical trades for a specific symbol
        historical_trades = self.client.get_historical_trades(symbol=symbol, limit=limit, fromId=from_id)
        return historical_trades

    async def create_order(self, symbol, side, order_type, quantity, price=None,
                           time_in_force=Client.TIME_IN_FORCE_GTC):
        # Create a new order
        order = self.client.create_order(symbol=symbol, side=side, type=order_type, quantity=quantity, price=price,
                                         timeInForce=time_in_force)
        logger.info(f"Order created: {order}")
        return order

    async def create_test_order(self, symbol, side, order_type, quantity, price=None,
                                time_in_force=Client.TIME_IN_FORCE_GTC):
        # Create a test order
        order = self.client.create_test_order(symbol=symbol, side=side, type=order_type, quantity=quantity, price=price,
                                              timeInForce=time_in_force)
        logger.info(f"Test order created: {order}")
        return order

    async def get_open_orders(self, symbol=None):
        # Get all open orders, or open orders for a specific symbol
        open_orders = self.client.get_open_orders(symbol=symbol)
        logger.info(f"Open orders for {symbol}: {open_orders}")
        return open_orders

    async def get_order(self, symbol, order_id):
        # Get details of a specific order
        order = self.client.get_order(symbol=symbol, orderId=order_id)
        logger.info(f"Order details for {symbol} with order ID {order_id}: {order}")
        return order

    async def get_all_orders(self, symbol, limit=500):
        # Get all orders for a specific symbol
        all_orders = self.client.get_all_orders(symbol=symbol, limit=limit)
        logger.info(f"All orders for {symbol} with limit {limit}: {all_orders}")
        return all_orders

    async def cancel_order(self, symbol, order_id):
        # Cancel a specific order
        cancel_result = self.client.cancel_order(symbol=symbol, orderId=order_id)
        logger.info(f"Order cancelled for {symbol} with order ID {order_id}: {cancel_result}")
        return cancel_result

    async def get_deposit_history(self, asset):
        # Get deposit history for a specific asset
        deposit_history = self.client.get_deposit_history(asset=asset)
        logger.info(f"Deposit history for asset {asset}: {deposit_history}")
        return deposit_history

    async def get_withdraw_history(self, asset):
        # Get withdrawal history for a specific asset
        withdraw_history = self.client.get_withdraw_history(asset=asset)
        logger.info(f"Withdraw history for asset {asset}: {withdraw_history}")
        return withdraw_history

    async def withdraw(self, asset, address, amount):
        # Withdraw a specific amount of an asset to a given address
        withdrawal = self.client.withdraw(asset=asset, address=address, amount=amount)
        logger.info(f"Withdrawal of {amount} {asset} to address {address}: {withdrawal}")
        return withdrawal
