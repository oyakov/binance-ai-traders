from datetime import datetime

from pandas import DataFrame
from sqlalchemy import select

from db.config import get_db
from db.model.kline import Kline
from oam import log_config

logger = log_config.get_logger(__name__)


class KlinesRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_klines(self, symbol: str, interval: str, klines: DataFrame) -> None:
        logger.debug(f"Writing klines for {symbol}")
        klines = klines.to_dict(orient='records')
        async with self.session_maker() as session:
            for kline in klines:
                session.add(Kline(symbol=symbol, interval=interval, **kline))
            await session.commit()
        logger.debug(f"Klines for {symbol} are written")

    async def get_klines(self, symbol: str, interval: str, start_time: int, end_time: int) -> DataFrame:
        logger.debug(f"Getting klines for {symbol}")
        async with self.session_maker() as session:
            stmt = select(Kline).filter(Kline.symbol == symbol, Kline.interval == interval,
                                        Kline.timestamp >= start_time, Kline.timestamp <= end_time)
            result = await session.execute(stmt)
            klines = result.scalars().all()
        klines = DataFrame([kline.__dict__ for kline in klines])
        logger.debug(f"Klines for {symbol} are retrieved")
        return klines

    async def get_latest_kline(self, symbol: str, interval: str) -> DataFrame:
        logger.debug(f"Getting latest kline for {symbol}")
        async with self.session_maker() as session:
            stmt = select(Kline).filter(Kline.symbol == symbol, Kline.interval == interval).order_by(
                Kline.timestamp.desc())
            result = await session.execute(stmt)
            kline = result.scalars().first()
        if kline is None:
            logger.debug(f"No kline found for {symbol}")
            return DataFrame()
        kline = DataFrame([kline.__dict__])
        logger.debug(f"Latest kline for {symbol} is retrieved")
        return kline
