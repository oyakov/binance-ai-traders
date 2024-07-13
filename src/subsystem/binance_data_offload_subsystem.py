from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


async def initialize_message_sender_job(interval_minutes: int = 1):
    """
    Initialize the periodic job for sending messages
    Job will run approximately every interval_minutes and will check if this time there are messages
    which schedule has arrived and send those messages to the configured list of chats
    """



class BinanceDataOffloadSubsystem(Subsystem):
    def __init__(self, bot, router):
        self.bot = bot
        self.router = router
        self.binance_service: BinanceService | None = None

    async def initialize(self):
        logger.info(f"Initializing Binance Data Offload subsystem {self.bot}")
        try:
            self.binance_service = BinanceService()
            logger.info("Initialize the scheduler job")
            scheduler = AsyncIOScheduler()
            scheduler.add_job(self.data_offload_cycle, 'interval', args=[], minutes=1)
            scheduler.start()
            logger.info("Scheduler is initialized")
        except Exception as e:
            print(f"Error initializing BinanceService: {e}")
            raise e
        self.is_initialized = True
        logger.info(f"Binance Data Offload subsystem is initialized")

    async def shutdown(self):
        logger.info(f"Shutting down Binance Data Offload subsystem")

    async def data_offload_cycle(self, symbol: str = "BTCUSDT"):
        account_info = await self.binance_service.get_account_info()
        ticker = await self.binance_service.get_ticker(symbol)
        klines = await self.binance_service.get_klines(symbol)


    def get_binance_service(self):
        return self.binance_service

    def get_router(self):
        return self.router
