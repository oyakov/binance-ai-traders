from datetime import datetime

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from injector import inject

from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService
from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem

logger = log_config.get_logger(__name__)


class BinanceDataOffloadSubsystem(Subsystem):

    @inject
    def __init__(self,
                 bot: Bot,
                 binance_service: BinanceService,
                 elastic_service: ElasticService,
                 indicator_service: IndicatorService):
        self.bot = bot
        self.binance_service = binance_service
        self.elastic_service = elastic_service
        self.indicator_service = indicator_service

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Data Offload subsystem {self.bot}")
        try:
            logger.info("Initialize the data offload cycle job")
            scheduler = AsyncIOScheduler()
            scheduler.add_job(self.data_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"]
                              ], minutes=1)
            scheduler.add_job(self.macd_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"]
                              ], minutes=60)
            scheduler.start()
            logger.info("Data offload cycle job is initialized")
        except Exception as e:
            logger.error(f"Error initializing Binance Data Offload subsystem: {e.__class__}\n\t{e}")
            raise e
        self.is_initialized = True
        logger.info(f"Binance Data Offload subsystem is initialized")

    async def shutdown(self):
        logger.info(f"Shutting down Binance Data Offload subsystem")

    async def data_offload_cycle(self, symbols=None):
        if symbols is None:
            symbols = ["BTCUSDT"]
        logger.info(f"Binance data offload cycle for symbols {symbols} has begun")
        try:
            for symbol in symbols:
                ticker = await self.binance_service.get_ticker(symbol)
                logger.info(f"Ticker is loaded for symbol {symbol}")
                order_book = await self.binance_service.get_order_book(symbol)
                logger.info(f"Order book is loaded for symbols {symbol}")
                self.elastic_service.add_to_index(symbol.lower()[:4], {
                    "ticker": ticker,
                    "order_book": order_book,
                    "timestamp": datetime.now().isoformat()
                })
        except Exception as e:
            logger.error(f"Error in data offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{e.__traceback__}")
        logger.info(f"Binance data offload cycle for symbols {symbols} has completed")

    async def macd_offload_cycle(self, symbols: list[str] = "BTCUSDT"):
        try:
            for symbol in symbols:
                klines = await self.binance_service.get_klines(symbol, '1m', limit=60)
                logger.info(f"Klines are loaded for symbol {symbol}")
                macd = await self.indicator_service.calculate_macd(klines)
                logger.info(f"MACD is calculated for symbol {symbol}")
                self.elastic_service.add_to_index(symbol.lower()[:4], {
                    "ema_fast": macd.ema_fast,
                    "ema_slow": macd.ema_slow,
                    "macd": macd.macd,
                    "signal": macd.signal,
                    "histogram": macd.histogram,
                    "timestamp": datetime.now().isoformat()
                })
        except Exception as e:
            logger.error(f"Error in MACD offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{e.__traceback__}")

    def get_binance_service(self):
        return self.binance_service
