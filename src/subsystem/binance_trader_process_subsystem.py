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
        self.long_interval = Client.KLINE_INTERVAL_15MINUTE
        self.short_interval = Client.KLINE_INTERVAL_1MINUTE
        self.long_window = 15
        self.short_window = 5
        self.notional = 0.00034
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

            # Cancel all open orders
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
            last_macd_short = await self.macd_repository.get_latest_macd(symbol, self.short_interval)
            macd_trend_short = self.indicator_service.trend_regression(last_macd_short['histogram'],
                                                                       window=self.short_window)
            last_macd_trend_short = await self.macd_trend_repository.get_latest_macd_trend(symbol, self.short_interval)
            if macd_trend_short != last_macd_trend_short:
                logger.info(f"MACD trend changed from {last_macd_trend_short} to {macd_trend_short} "
                            f"on 1m interval at {datetime.now()}")
                await self.macd_trend_repository.write_macd_trend(symbol, self.short_interval, macd_trend_short,
                                                                  last_macd_short['histogram'].iloc[-1])
            # Long term trend analysis
            last_macd_long = await self.macd_repository.get_latest_macd(symbol, self.long_interval)
            macd_trend_long = self.indicator_service.trend_regression(last_macd_long['histogram'],
                                                                      window=self.long_window)
            last_macd_trend_15m = await self.macd_trend_repository.get_latest_macd_trend(symbol, self.long_interval)

            # Track the trend change
            if macd_trend_long != last_macd_trend_15m:
                logger.info(f"MACD trend changed from {last_macd_trend_15m} to {macd_trend_long} "
                            f"on 15m interval at {datetime.now()}")
                await self.macd_trend_repository.write_macd_trend(symbol, self.long_interval, macd_trend_long,
                                                                  last_macd_long['histogram'].iloc[-1])

                # New trend is detected, place a trade
                if macd_trend_long == UPWARD:
                    # Create a BUY order
                    order_details = None
                    try:
                        order_details = await self.binance_service.create_order(symbol,
                                                                                Client.SIDE_BUY,
                                                                                Client.ORDER_TYPE_MARKET,
                                                                                "{:.8f}".format(0.00034))
                    except Exception as e:
                        logger.error(f"Error creating order", exc_info=e)

                    try:
                        await self.order_repository.write_order(symbol, order_details)
                    except Exception as e:
                        logger.error(f"Error writing order to database", exc_info=e)
                    logger.info(f"Order details: {order_details}")
                if macd_trend_short == DOWNWARD:
                    # Create a SELL order
                    order_details = None
                    try:
                        order_details = await self.binance_service.create_order(symbol,
                                                                                Client.SIDE_SELL,
                                                                                Client.ORDER_TYPE_MARKET,
                                                                                "{:.8f}".format(0.00034))
                    except Exception as e:
                        logger.error(f"Error creating order", exc_info=e)

                    try:
                        await self.order_repository.write_order(symbol, order_details)
                    except Exception as e:
                        logger.error(f"Error writing order to database", exc_info=e)
                    logger.info(f"Order details: {order_details}")

            # Find resistance and support levels based on the data collected from the database
            # Assess potential entry and exit points based on the resistance and support levels
            # Assess potential profitablity of the trade, based on the entry and exit points,
            # trading fees and other costs
            # Determine if current orders need to be cancelled or new orders need to be placed
            # Place orders based on the new assessment
            # Update the order with the new trades in the database
            # In case of an error, log the error, send a notification to the admin and stop the trade cycle
        except Exception as e:
            logger.error(f"Error in trade cycle", exc_info=e)

    async def shutdown(self):
        logger.info(f"Shutting down Binance Trader Process subsystem")

    def get_router(self):
        return self.router

    def get_priority(self):
        return InitPriority.DATA_CONSUMPTION
