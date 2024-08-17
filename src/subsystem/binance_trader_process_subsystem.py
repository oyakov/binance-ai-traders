from datetime import datetime

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from binance import Client
from injector import inject

from db.repository.klines_repository import KlinesRepository
from db.repository.macd_repository import MACDRepository
from db.repository.macd_trend_repository import MACDTrendRepository
from db.repository.order_book_repository import OrderBookRepository
from db.repository.order_repository import OrderRepository
from db.repository.ticker_repository import TickerRepository
from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService, UPWARD, DOWNWARD
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class BinanceTraderProcessSubsystem(Subsystem):

    @inject
    def __init__(self,
                 bot: Bot,
                 binance_service: BinanceService,
                 indicator_service: IndicatorService,
                 order_repository: OrderRepository,
                 klines_repository: KlinesRepository,
                 macd_repository: MACDRepository,
                 macd_trend_repository: MACDTrendRepository,
                 order_book_repository: OrderBookRepository,
                 ticker_repository: TickerRepository):
        self.router = None
        self.bot = bot
        self.binance_service = binance_service
        self.indicator_service = indicator_service
        self.order_repository = order_repository
        self.klines_repository = klines_repository
        self.macd_repository = macd_repository
        self.macd_trend_repository = macd_trend_repository
        self.order_book_repository = order_book_repository
        self.ticker_repository = ticker_repository
        self.long_interval = Client.KLINE_INTERVAL_1HOUR
        self.short_interval = Client.KLINE_INTERVAL_15MINUTE
        self.long_window = 2
        self.short_window = 2
        self.slope_threshold_buy = 1.0
        self.slope_threshold_sell = 0.2
        self.notional = 0.00034
        self.mode = Client.SIDE_BUY
        self.is_initialized = False

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Trader Process subsystem {self.bot}")
        scheduler = AsyncIOScheduler()
        await self.trade_cycle("BTCUSDT")
        scheduler.add_job(self.trade_cycle, 'interval', args=["BTCUSDT"], minutes=1)
        scheduler.start()
        logger.info("Advertiser is initialized")
        self.is_initialized = True
        logger.info(f"Binance Trader Process subsystem is initialized")

    async def trade_cycle(self, symbol: str):
        try:
            logger.info(f"Trade cycle engaged")
            # Get our current orders
            open_orders = await self.binance_service.get_open_orders(symbol)

            # Cancel all open (primarily MARKET if any) orders for safety for now
            for order in open_orders:
                logger.info(f"Order exists: {order}")
                try:
                    cancel_result = await self.binance_service.cancel_order(symbol, order['orderId'])
                    logger.info(f"Order cancelled: {cancel_result}")
                except Exception as e:
                    logger.error(f"Error cancelling order", exc_info=e)
            logger.info(f"Open orders: {open_orders}")

            # ==========================================================================================================
            # Read the current state of the market from the database, collected by the data offload subsystem
            # Read the latest MACD data from the database
            # Short term trend analysis
            # ==========================================================================================================
            macd_histogram = await self.macd_repository.get_latest_macd(symbol, self.short_interval)
            macd_signals = self.indicator_service.generate_signals(macd_histogram)
            macd_lin_regression_2, trend_2 = self.indicator_service.trend_regression(macd_histogram['histogram'], 2)
            macd_lin_regression_3, trend_3 = self.indicator_service.trend_regression(macd_histogram['histogram'], 3)
            # Check if the last two values are greater than zero
            if self.buy_condition(macd_histogram, macd_lin_regression_2, macd_lin_regression_3):
                logger.info("Buy condition is satisfied, placing order")
                # Place a buy order
                order = None
                try:
                    order = await self.binance_service.create_order(symbol, Client.SIDE_BUY, Client.ORDER_TYPE_MARKET, self.notional)
                    logger.info(f"Order placed: {order}")
                except Exception as e:
                    logger.error(f"Error placing order", exc_info=e)

                # Save the order to the database
                try:
                    await self.order_repository.write_order(symbol, order)
                except Exception as e:
                    logger.error(f"Error saving order to the database", exc_info=e)
                self.mode = Client.SIDE_SELL
            elif self.sell_condition(macd_histogram, macd_lin_regression_2, macd_lin_regression_3):
                logger.info("Sell condition is statisfied, placing order")
                # Place a sell order
                order = None
                try:
                    order = await self.binance_service.create_order(symbol, Client.SIDE_SELL, Client.ORDER_TYPE_MARKET, self.notional)
                    logger.info(f"Order placed: {order}")
                except Exception as e:
                    logger.error(f"Error placing order", exc_info=e)

                # Save the order to the database
                try:
                    await self.order_repository.write_order(symbol, order)
                except Exception as e:
                    logger.error(f"Error saving order to the database", exc_info=e)
                self.mode = Client.SIDE_BUY
        except Exception as e:
            logger.error(f"Error in trade cycle", exc_info=e)

    def buy_condition(self, macd_histogram, macd_lin_regression_2, macd_lin_regression_3):
        return (self.mode == Client.SIDE_BUY and
                macd_histogram.iloc[-1]['histogram'] > 0 > macd_histogram.iloc[-2]['histogram'])

    def sell_condition(self, macd_histogram, macd_lin_regression_2, macd_lin_regression_3):
        # Fake sell when no buy was committed, need to add a mode table to check if a buy was committed
        return (self.mode == Client.SIDE_SELL and
                macd_histogram.iloc[-1]['histogram'] < 0 < macd_histogram.iloc[-2]['histogram'])

    async def shutdown(self):
        logger.info(f"Shutting down Binance Trader Process subsystem")

    def get_router(self):
        return self.router

    def get_priority(self):
        return InitPriority.DATA_CONSUMPTION
