import re

import pandas as pd
from binance.client import Client
from pandas import DataFrame

from oam import log_config
from oam.environment import BINANCE_TOKEN, BINANCE_SECRET_TOKEN, BINANCE_TESTNET_TOKEN, BINANCE_TESTNET_SECRET_TOKEN, \
    BINANCE_TESTNET_ENABLED

# Initialize logger
logger = log_config.get_logger(__name__)


# Helper function to convert camelCase to snake_case
def camel_to_snake(name):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()


def convert_dict_keys_to_snake_case(data: dict):
    """Convert all dictionary keys from camelCase to snake_case."""
    if isinstance(data, dict):
        new_data = {}
        for key, value in data.items():
            new_key = camel_to_snake(key)
            new_data[new_key] = convert_dict_keys_to_snake_case(value) if isinstance(value, (dict, list)) else value
        return new_data
    elif isinstance(data, list):
        return [convert_dict_keys_to_snake_case(item) for item in data]
    else:
        return data


class BinanceService:

    def __init__(self):
        # Initialize Binance client with API token and secret
        if BINANCE_TESTNET_ENABLED:
            logger.info("Binance Client is initialized with Testnet configuration...")
            self.client = Client(BINANCE_TESTNET_TOKEN, BINANCE_TESTNET_SECRET_TOKEN, testnet=True)
        else:
            logger.info("Binance Client is initialized with production configuration...")
            self.client = Client(BINANCE_TOKEN, BINANCE_SECRET_TOKEN)
        logger.info("Binance Client is initialized")

    async def get_account_info(self):
        # Get account information
        account_info = self.client.get_account()
        return account_info

    async def get_asset_balance(self, asset):
        # Get the balance of a specific asset
        balance = self.client.get_asset_balance(asset=asset)
        return balance

    async def get_ticker(self, symbol) -> DataFrame:
        # Get ticker information for a specific symbol
        ticker = self.client.get_ticker(symbol=symbol)
        df_ticker = DataFrame([ticker])

        # Convert specified columns to float
        float_columns = [
            'priceChange', 'priceChangePercent', 'weightedAvgPrice', 'prevClosePrice', 'lastPrice', 'lastQty',
            'bidPrice', 'bidQty', 'askPrice', 'askQty', 'openPrice', 'highPrice', 'lowPrice', 'volume',
            'quoteVolume', 'count'
        ]
        df_ticker[float_columns] = df_ticker[float_columns].astype(float)

        # Convert time columns to datetime
        df_ticker['dispayOpenTime'] = pd.to_datetime(df_ticker['openTime'], unit='ms')
        df_ticker['displayCloseTime'] = pd.to_datetime(df_ticker['closeTime'], unit='ms')

        # Convert column names to snake_case for consistency
        df_ticker.columns = [camel_to_snake(col) for col in df_ticker.columns]

        return df_ticker

    async def get_symbol_ticker(self, symbol) -> float:
        # Get ticker information for a specific symbol
        ticker = self.client.get_symbol_ticker(symbol=symbol)
        return ticker['price']

    async def get_klines(self, symbol, interval=Client.KLINE_INTERVAL_1MINUTE,
                         start_time=None, end_time=None, timezone='0', limit=500) -> DataFrame:
        # Get historical candlestick data for a specific symbol
        candles = self.client.get_klines(symbol=symbol, interval=interval, startTime=start_time,
                                         endTime=end_time, timeZone=timezone, limit=limit)

        # Convert to DataFrame for easier manipulation
        df = DataFrame(candles, columns=[
            'timestamp', 'open', 'high', 'low', 'close', 'volume', 'close_time', 'quote_asset_volume',
            'number_of_trades', 'taker_buy_base_asset_volume', 'taker_buy_quote_asset_volume', 'ignore'
        ])

        float_columns = ['open', 'high', 'low', 'close', 'volume', 'quote_asset_volume',
                         'taker_buy_base_asset_volume', 'taker_buy_quote_asset_volume']

        # Convert specified columns to float
        df[float_columns] = df[float_columns].astype(float)

        # Convert time columns to datetime
        df['display_time'] = pd.to_datetime(df['timestamp'], unit='ms')
        df['display_close_time'] = pd.to_datetime(df['close_time'], unit='ms')
        return df

    async def get_all_tickers(self):
        # Get ticker information for all symbols
        tickers = self.client.get_all_tickers()
        return tickers

    async def get_order_book(self, symbol, limit=100) -> pd.DataFrame:
        # Get the order book for a specific symbol
        order_book = self.client.get_order_book(symbol=symbol, limit=limit)

        # Extract bids and asks as separate DataFrames
        bids_df = pd.DataFrame(order_book.get('bids', []), columns=['price', 'quantity'])
        asks_df = pd.DataFrame(order_book.get('asks', []), columns=['price', 'quantity'])

        # Convert specified columns to float
        float_columns = ['price', 'quantity']
        bids_df[float_columns] = bids_df[float_columns].astype(float)
        asks_df[float_columns] = asks_df[float_columns].astype(float)

        # Optionally, add an identifier to distinguish between bids and asks
        bids_df['type'] = 'bid'
        asks_df['type'] = 'ask'

        # Concatenate the two DataFrames, if needed
        df_order_book = pd.concat([bids_df, asks_df], ignore_index=True)

        # Add current time and last_update_id
        df_order_book['tx_time'] = pd.Timestamp.now()
        df_order_book['last_update_id'] = order_book.get('lastUpdateId')

        return df_order_book

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
                           time_in_force=Client.TIME_IN_FORCE_GTC) -> DataFrame:
        params = {
            "symbol": symbol,
            "side": side,
            "type": order_type,
            "quantity": quantity
        }

        # Handling LIMIT orders
        if order_type == "LIMIT":
            if price is None:
                raise ValueError("Price must be specified for LIMIT orders")
            params["price"] = price
            params["timeInForce"] = time_in_force  # or another valid option like 'IOC' or 'FOK'

        # Handling MARKET orders
        elif order_type == "MARKET":
            # Ensure that price and timeInForce are not included for MARKET orders
            if price is not None:
                raise ValueError("Price should not be specified for MARKET orders")

        # Create a new order
        order = self.client.create_order(**params)
        df_order = DataFrame([order])
        float_columns = ['price', 'origQty', 'executedQty', 'cummulativeQuoteQty']
        df_order[float_columns] = df_order[float_columns].astype(float)

        # Convert time columns to datetime
        df_order['display_transact_time'] = pd.to_datetime(df_order['transactTime'], unit='ms')
        df_order['display_working_time'] = pd.to_datetime(df_order['workingTime'], unit='ms')

        # Convert column names to snake_case for consistency
        df_order.columns = [camel_to_snake(col) for col in df_order.columns]
        logger.info(f"Order created: {df_order}")
        return df_order

    async def create_test_order(self, symbol, side, order_type, quantity, price=None):
        # Base parameters for the order
        params = {
            "symbol": symbol,
            "side": side,
            "type": order_type,
            "quantity": quantity
        }

        # Handling LIMIT orders
        if order_type == "LIMIT":
            if price is None:
                raise ValueError("Price must be specified for LIMIT orders")
            params["price"] = price
            params["timeInForce"] = "GTC"  # or another valid option like 'IOC' or 'FOK'

        # Handling MARKET orders
        elif order_type == "MARKET":
            # Ensure that price and timeInForce are not included for MARKET orders
            if price is not None:
                raise ValueError("Price should not be specified for MARKET orders")

        # Additional handling for other order types can be added here

        # Place the test order
        order = self.client.create_test_order(**params)
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

    async def cancel_order(self, symbol, order_id) -> DataFrame:
        # Cancel a specific order
        cancel_result = self.client.cancel_order(symbol=symbol, orderId=order_id)
        logger.info(f"Order cancelled for {symbol} with order ID {order_id}: {cancel_result}")
        df_cancel_result = DataFrame([cancel_result])
        float_columns = ['price', 'origQty', 'executedQty', 'cummulativeQuoteQty']
        df_cancel_result[float_columns] = df_cancel_result[float_columns].astype(float)
        # Convert time columns to datetime
        df_cancel_result['display_transact_time'] = pd.to_datetime(df_cancel_result['transactTime'], unit='ms')
        # Convert column names to snake_case for consistency
        df_cancel_result.columns = [camel_to_snake(col) for col in df_cancel_result.columns]
        return df_cancel_result

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
