from datetime import datetime

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from injector import inject

from db.repository.klines_repository import KlinesRepository
from db.repository.macd_repository import MACDRepository
from db.repository.macd_trend_repository import MACDTrendRepository
from db.repository.order_book_repository import OrderBookRepository
from db.repository.order_repository import OrderRepository
from db.repository.ticker_repository import TickerRepository
from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService
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

            # Create a test order
            order_details = await self.binance_service.create_order(symbol, "BUY", "LIMIT", 0.01, 30000)
            try:
                await self.order_repository.write_order(symbol, order_details)
            except Exception as e:
                logger.error(f"Error writing order to database", exc_info=e)
            logger.info(f"Order details: {order_details}")

            # Cancel the order
            order_id = order_details['order_id'].iloc[0]
            logger.info(f"Test order created")
            cancel_result = await self.binance_service.cancel_order(symbol, order_id)
            try:
                await self.order_repository.update_order(symbol, order_id, cancel_result)
            except Exception as e:
                logger.error(f"Error updating order in database", exc_info=e)
            logger.info(f"Test order cancelled {cancel_result}")

            # Read the current state of the market from the database, collected by the data offload subsystem
            # Read the latest MACD data from the database
            # Short term trend analysis
            last_macd_1m = await self.macd_repository.get_latest_macd(symbol, '1m')
            macd_trend_1m = self.indicator_service.determine_macd_trend_regression(last_macd_1m['histogram'], window=5)
            last_macd_trend_1m = await self.macd_trend_repository.get_latest_macd_trend(symbol, '1m')
            if macd_trend_1m != last_macd_trend_1m:
                logger.info(f"MACD trend changed from {last_macd_trend_1m} to {macd_trend_1m} "
                            f"on 1m interval at {datetime.now()}")
                await self.macd_trend_repository.write_macd_trend(symbol, '1m', macd_trend_1m,
                                                                  last_macd_1m['histogram'].iloc[-1])
            # Long term trend analysis
            last_macd_15m = await self.macd_repository.get_latest_macd(symbol, '15m')
            macd_trend_15m = self.indicator_service.determine_macd_trend_regression(last_macd_15m['histogram'],
                                                                                    window=5)
            last_macd_trend_15m = await self.macd_trend_repository.get_latest_macd_trend(symbol, '15m')
            if macd_trend_15m != last_macd_trend_15m:
                logger.info(f"MACD trend changed from {last_macd_trend_15m} to {macd_trend_15m} "
                            f"on 15m interval at {datetime.now()}")
                await self.macd_trend_repository.write_macd_trend(symbol, '15m', macd_trend_15m,
                                                                  last_macd_15m['histogram'].iloc[-1])


            last_ticker = await self.ticker_repository.get_last_ticker(symbol)

            last_order_book = await self.order_book_repository.get_order_book(symbol)

            klines_1m = await self.klines_repository.get_klines(symbol, '1m',
                                                                int((datetime.now().timestamp() - 3600) * 1000),
                                                                int(datetime.now().timestamp() * 1000))

            klines_15m = await self.klines_repository.get_klines(symbol, '15m',
                                                                 int((datetime.now().timestamp() - 72000) * 1000),
                                                                 int(datetime.now().timestamp() * 1000))

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
