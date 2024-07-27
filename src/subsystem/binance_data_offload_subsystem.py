from datetime import datetime

from apscheduler.schedulers.asyncio import AsyncIOScheduler

from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService
from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BinanceDataOffloadSubsystem(Subsystem):
    def __init__(self, bot):
        self.bot = bot
        self.binance_service: BinanceService | None = None
        self.elastic_service: ElasticService | None = None
        self.indicator_service: IndicatorService | None = None

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Data Offload subsystem {self.bot}")
        try:
            logger.info(f"Initializing BinanceService")
            self.binance_service = BinanceService()
            logger.info(f"Initializing ElasticService")
            self.elastic_service = ElasticService()
            logger.info("Initialize the data offload cycle job")
            scheduler = AsyncIOScheduler()
            scheduler.add_job(self.data_offload_cycle,
                              'interval',
                              args=[
                                  "BTCUSDT"
                              ], minutes=1)
            scheduler.start()
            logger.info("Data offload cycle job is initialized")
        except Exception as e:
            logger.error(f"Error initializing Binance Data Offload subsystem: {e.__class__}\n\t{e}")
            raise e
        self.is_initialized = True
        logger.info(f"Binance Data Offload subsystem is initialized")

    async def shutdown(self):
        logger.info(f"Shutting down Binance Data Offload subsystem")

    async def data_offload_cycle(self, symbol: str = "BTCUSDT"):
        logger.info(f"Data offload cycle for symbol {symbol} has begun")
        try:
            ticker = await self.binance_service.get_ticker(symbol)
            logger.info(f"Ticker is loaded for symbol {symbol}")
            klines = await self.binance_service.get_klines(symbol, '1h')
            logger.info(f"Klines are loaded for symbol {symbol}")
            macd = self.indicator_service.calculate_macd(klines)
            logger.info(f"MACD is calculated for symbol {symbol}")
            order_book = await self.binance_service.get_order_book(symbol)
            logger.info(f"Order book is loaded for symbol {symbol}")
            self.elastic_service.add_to_index("btcu", {
                "ticker": ticker,
                "klines": klines,
                "macd": macd,
                "order_book": order_book,
                "timestamp": datetime.now().isoformat()
            })
        except Exception as e:
            logger.error(f"Error in data offload cycle: {e.__class__}\n\t{e}")
        logger.info(f"Data offload cycle for symbol {symbol} is complete")

    def get_binance_service(self):
        return self.binance_service
