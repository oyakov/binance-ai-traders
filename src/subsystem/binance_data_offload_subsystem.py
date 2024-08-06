import traceback
from datetime import datetime, timedelta

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from injector import inject

from db.repository.klines_repository import KlinesRepository
from db.repository.macd_repository import MACDRepository
from db.repository.order_book_repository import OrderBookRepository
from db.repository.ticker_repository import TickerRepository
from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class BinanceDataOffloadSubsystem(Subsystem):

    @inject
    def __init__(self,
                 bot: Bot,
                 binance_service: BinanceService,
                 indicator_service: IndicatorService,
                 ticker_repository: TickerRepository,
                 order_book_repository: OrderBookRepository,
                 klines_repository: KlinesRepository,
                 macd_repository: MACDRepository):
        self.bot = bot
        self.binance_service = binance_service
        self.indicator_service = indicator_service
        self.ticker_repository = ticker_repository
        self.order_book_repository = order_book_repository
        self.klines_repository = klines_repository
        self.macd_repository = macd_repository

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Data Offload subsystem {self.bot}")
        try:
            logger.info("Initialize the data offload cycle job")
            scheduler = AsyncIOScheduler()
            await self.ticker_offload_cycle(["BTCUSDT", "ETHUSDT"])
            scheduler.add_job(self.ticker_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"]
                              ], minutes=1)
            await self.klines_offload_cycle(["BTCUSDT", "ETHUSDT"], '1m', 360)
            scheduler.add_job(self.klines_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"],
                                  '1m',
                                  360
                              ], minutes=1)
            await self.klines_offload_cycle(["BTCUSDT", "ETHUSDT"], '15m', 360)
            scheduler.add_job(self.klines_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"],
                                  '15m',
                                  360
                              ], minutes=1)
            await self.macd_offload_cycle(["BTCUSDT", "ETHUSDT"], '1m')
            scheduler.add_job(self.macd_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"],
                                  '1m',
                              ], minutes=1)
            await self.macd_offload_cycle(["BTCUSDT", "ETHUSDT"], '15m')
            scheduler.add_job(self.macd_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"],
                                  '15m',
                              ], minutes=1)
            scheduler.start()
            logger.info("Data offload cycle job is initialized")
        except Exception as e:
            logger.error(f"Error initializing Binance Data Offload subsystem", exc_info=e)
            raise e
        self.is_initialized = True

    async def shutdown(self):
        logger.info(f"Shutting down Binance Data Offload subsystem")
        self.is_initialized = False

    def get_priority(self):
        return InitPriority.DATA_OFFLOAD

    async def ticker_offload_cycle(self, symbols: list[str] = "BTCUSDT"):
        logger.info(f"Ticker offload cycle for symbols {symbols} has begun")
        try:
            for symbol in symbols:
                ticker = await self.binance_service.get_ticker(symbol)
                await self.ticker_repository.write_ticker(symbol, ticker)
                logger.info(f"Ticker is loaded for symbol {symbol}")
                order_book = await self.binance_service.get_order_book(symbol)
                await self.order_book_repository.write_order_book(symbol, order_book)
                logger.info(f"Order book is loaded for symbols {symbol}")
        except Exception as e:
            logger.error(f"Error in MACD offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{traceback.format_exc()}")
        logger.info(f"Ticker offload cycle for symbols {symbols} has completed")

    async def klines_offload_cycle(self, symbols: list[str] = "BTCUSDT", interval: str = '1m', initial_limit: int = 360):
        logger.info(f"Klines offload cycle for symbols {symbols} has begun")
        try:
            for symbol in symbols:
                logger.info(f"No klines found for symbol {symbol}")
                # Fetch the past {initial_inteval} minutes of klines
                klines = await self.binance_service.get_klines(symbol, interval, limit=initial_limit)
                logger.info(f"{len(klines)} klines were loaded for symbol {symbol}")
                # Write the klines to the database
                await self.klines_repository.write_klines(symbol, interval, klines)
                logger.info(f"Klines are loaded for symbol {symbol}")
        except Exception as e:
            logger.error(f"Error in Klines offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{traceback.format_exc()}")

    async def macd_offload_cycle(self, symbols: list[str] = "BTCUSDT", interval: str = '1m'):
        logger.info(f"MACD offload cycle for symbols {symbols} has begun")
        try:
            for symbol in symbols:

                start_time = (datetime.now() - timedelta(minutes=181)).timestamp()
                end_time = datetime.now().timestamp()

                klines = await self.klines_repository.get_klines(
                    symbol,
                    interval,
                    int(start_time * 1000),
                    int(end_time * 1000))
                logger.info(f"Klines are loaded for symbol {symbol}")
                # Calculate MACD values
                macd = await self.indicator_service.calculate_macd(klines)
                logger.info(f"MACD is calculated for symbol {symbol}")
                await self.macd_repository.write_macd(symbol, interval, macd)
                logger.info(f"MACD values updated for the last 60 minutes for symbol {symbol}")
        except Exception as e:
            logger.error(f"Error in MACD offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{traceback.format_exc()}")

    def get_binance_service(self):
        return self.binance_service
