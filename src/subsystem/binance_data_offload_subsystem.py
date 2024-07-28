import traceback
from datetime import datetime, timedelta

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
            await self.macd_offload_cycle(["BTCUSDT", "ETHUSDT"])
            scheduler.add_job(self.macd_offload_cycle,
                              'interval',
                              args=[
                                  ["BTCUSDT", "ETHUSDT"]
                              ], minutes=60)
            scheduler.start()
            logger.info("Data offload cycle job is initialized")
        except Exception as e:
            logger.error(f"Error initializing Binance Data Offload subsystem", exc_info=e)
            raise e
        self.is_initialized = True

    async def data_offload_cycle(self, symbols: list[str] = "BTCUSDT"):
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
            logger.error(f"Error in MACD offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{traceback.format_exc()}")
        logger.info(f"Binance data offload cycle for symbols {symbols} has completed")

    async def macd_offload_cycle(self, symbols: list[str] = "BTCUSDT"):
        try:
            for symbol in symbols:
                # Fetch the past 60 minutes of klines
                klines = await self.binance_service.get_klines(symbol, '1m', limit=60)
                logger.info(f"Klines are loaded for symbol {symbol}")

                # Calculate MACD values
                macd = await self.indicator_service.calculate_macd(klines)
                logger.info(f"MACD is calculated for symbol {symbol}")

                # Calculate the time range for the past 60 minutes
                end_time = datetime.now()
                start_time = end_time - timedelta(minutes=60)

                # Query to fetch all documents within the past 60 minutes
                query = {
                    "query": {
                        "range": {
                            "timestamp": {
                                "gte": start_time.isoformat(),
                                "lt": end_time.isoformat()
                            }
                        }
                    }
                }

                # Fetch existing documents within the time range
                existing_documents = self.elastic_service.search(symbol.lower()[:4], query)

                # Update existing documents or add new ones if not found
                if existing_documents and 'hits' in existing_documents and existing_documents['hits']['hits']:
                    index = 0
                    for hit in existing_documents['hits']['hits']:
                        doc_id = hit['_id']
                        logger.debug(f"Updating MACD values for symbol {symbol} at {doc_id} {hit['_id']}")
                        # Prepare the MACD data to be inserted, timestamp is not updated
                        macd_data = {
                            "doc": {
                                "ticker.ema_fast": float(macd.ema_fast[index]),
                                "ticker.ema_slow": float(macd.ema_slow[index]),
                                "ticker.macd": float(macd.macd[index]),
                                "ticker.signal": float(macd.signal[index]),
                                "ticker.histogram": float(macd.histogram[index])
                            }
                        }
                        self.elastic_service.update_index(symbol.lower()[:4], macd_data, doc_id)
                        index += 1
                else:
                    # If no existing documents are found, create new ones for each minute
                    current_time = start_time
                    index = 0
                    while current_time < end_time:
                        # Prepare the MACD data to be inserted
                        macd_data = {
                            "doc": {
                                "ticker.ema_fast": float(macd.ema_fast[index]),
                                "ticker.ema_slow": float(macd.ema_slow[index]),
                                "ticker.macd": float(macd.macd[index]),
                                "ticker.signal": float(macd.signal[index]),
                                "ticker.histogram": float(macd.histogram[index])
                            }
                        }
                        self.elastic_service.add_to_index(index=symbol.lower()[:4],
                                                          body=macd_data,
                                                          ts=current_time.isoformat())
                        current_time += timedelta(minutes=1)
                        index += 1
                logger.info(f"MACD values updated for the last 60 minutes for symbol {symbol}")
        except Exception as e:
            logger.error(f"Error in MACD offload cycle: {e.__class__}"
                         f"\n\t{e}"
                         f"\n\t{traceback.format_exc()}")

    def get_binance_service(self):
        return self.binance_service
