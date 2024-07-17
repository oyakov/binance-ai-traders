from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler

from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BinanceDataOffloadSubsystem(Subsystem):
    def __init__(self, bot, router):
        self.bot = bot
        self.router = router
        self.binance_service: BinanceService | None = None
        self.elastic_service: ElasticService | None = None

    async def initialize(self):
        logger.info(f"Initializing Binance Data Offload subsystem {self.bot}")
        try:
            logger.info(f"Initializing BinanceService")
            self.binance_service = BinanceService()
            logger.info(f"Initializing ElasticService")
            self.elastic_service = ElasticService()
            logger.info("Initialize the data offload cycle job")
            scheduler = AsyncIOScheduler()
            scheduler.add_job(self.data_offload_cycle, 'interval', args=[
                "BTCUSDT"
            ], minutes=1)
            scheduler.start()
            logger.info("Data offload cycle job is initialized")
        except Exception as e:
            print(f"Error initializing Binance Data Offload subsystem: {e}")
            raise e
        self.is_initialized = True
        logger.info(f"Binance Data Offload subsystem is initialized")

    async def shutdown(self):
        logger.info(f"Shutting down Binance Data Offload subsystem")

    async def data_offload_cycle(self, symbol: str = "BTCUSDT"):
        logger.info(f"Data offload cycle for symbol {symbol}")
        try:
            account_info = await self.binance_service.get_account_info()
            ticker = await self.binance_service.get_ticker(symbol)
            klines = await self.binance_service.get_klines(symbol)
            self.elastic_service.add_to_index(symbol, {
                "account_info": account_info,
                "ticker": ticker,
                "klines": klines
            })
        except Exception as e:
            logger.error(f"Error in data offload cycle: {e}")
        logger.info(f"Data offload cycle for symbol {symbol} is complete")

    def get_binance_service(self):
        return self.binance_service

    def get_router(self):
        return self.router
