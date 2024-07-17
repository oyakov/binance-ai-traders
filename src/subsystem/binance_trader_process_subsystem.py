from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BinanaceTraderProcessSubsystem(Subsystem):
    def __init__(self, bot, router):
        self.bot = bot
        self.router = router
        self.binance_service = None

    async def initialize(self):
        logger.info(f"Initializing Binance Trader Process subsystem {self.bot}")
        self.binance_service = BinanceService()
        logger.info(f"Created new BinanceService instance")
        self.is_initialized = True
        logger.info(f"Binance Trader Process subsystem is initialized")

    async def initialize_trader(self, bot: Bot, interval_minutes: int = 1):
        """
        Initialize the periodic job for sending messages
        Job will run approximately every interval_minutes and will check if this time there are messages
        which schedule has arrived and send those messages to the configured list of chats
        """
        logger.info("Initialize the advertiser job")
        scheduler = AsyncIOScheduler()
        scheduler.add_job(self.trade_cycle, 'interval', args=[bot], minutes=interval_minutes)
        scheduler.start()
        logger.info("Advertiser is initialized")

    async def trade_cycle(self):
        logger.info(f"Trade cycle engaged")
        # Read the current state of the market from the BinanceService

        # Make decisions based on the current state of the market

        # Execute trades based on the decisions made

        # Update the order book with the new trades in the database

        # In case of an error, log the error, send a notification to the admin and stop the trade cycle
        pass

    async def shutdown(self):
        logger.info(f"Shutting down Binance Trader Process subsystem")

    def get_router(self):
        return self.router
