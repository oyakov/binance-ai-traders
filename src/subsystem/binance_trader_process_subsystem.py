from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from injector import inject

from db.repository.order_repository import OrderRepository
from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class BinanceTraderProcessSubsystem(Subsystem):

    @inject
    def __init__(self,
                 bot: Bot,
                 binance_service: BinanceService,
                 order_repository: OrderRepository):
        self.bot = bot
        self.binance_service = binance_service
        self.order_repository = order_repository

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Trader Process subsystem {self.bot}")
        scheduler = AsyncIOScheduler()
        await self.trade_cycle("BTCUSDT")
        scheduler.add_job(self.trade_cycle, 'interval',
                          args=["BTCUSDT"], minutes=1)
        scheduler.start()
        logger.info("Advertiser is initialized")
        self.is_initialized = True
        logger.info(f"Binance Trader Process subsystem is initialized")

    async def trade_cycle(self, symbol: str):
        try:
            logger.info(f"Trade cycle engaged")
            # Get the current account information
            open_orders = await self.binance_service.get_open_orders(symbol)
            for order in open_orders:
                logger.info(f"Order exists: {order}")
                cancel_result = await self.binance_service.cancel_order(symbol, order['orderId'])
                logger.info(f"Order cancelled: {cancel_result}")
            logger.info(f"Open orders: {open_orders}")
            # Create a test order
            test_order_details = await self.binance_service.create_test_order(symbol, "BUY", "LIMIT", 0.01, 30000)
            logger.info(f"Test order details: {test_order_details}")
            if not test_order_details:
                logger.info("Test order creation successful, no actual order created")
            order_details = await self.binance_service.create_order(symbol, "BUY", "LIMIT", 0.01, 30000)
            try:
                await self.order_repository.write_order(symbol, order_details)
            except Exception as e:
                logger.error(f"Error writing order to database", exc_info=e)
            logger.info(f"Order details: {order_details}")
            # Cancel the order
            order_id = order_details['order_id']
            logger.info(f"Test order created")
            cancel_result = await self.binance_service.cancel_order(symbol, order_id)
            try:
                await self.order_repository.update_order(symbol, order_id, cancel_result)
            except Exception as e:
                logger.error(f"Error updating order in database", exc_info=e)
            logger.info(f"Test order cancelled {cancel_result}")
            # Read the current state of the market from the database, collected by the data offload subsystem

            # Find resistance and support levels based on the data collected from the database

            # Assess potential entry and exit points based on the resistance and support levels

            # Assess potential profitablity of the trade, based on the entry and exit points,
            # trading fees and other costs

            # Place orders based on the assessment of the potential profitability of the trade

            # Update the order book with the new trades in the database

            # In case of an error, log the error, send a notification to the admin and stop the trade cycle
        except Exception as e:
            logger.error(f"Error in trade cycle", exc_info=e)

    async def shutdown(self):
        logger.info(f"Shutting down Binance Trader Process subsystem")

    def get_router(self):
        return self.router

    def get_priority(self):
        return InitPriority.DATA_CONSUMPTION
