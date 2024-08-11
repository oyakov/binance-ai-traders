from datetime import datetime

from pandas import DataFrame
from sqlalchemy import delete, select

from db.config import get_db
from db.model.binance.macd_trend import MACDTrend
from oam import log_config

logger = log_config.get_logger(__name__)


class MACDTrendRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_macd_trend(self, symbol: str, interval: str, macd_trend: str, last_histogram: float) -> None:
        logger.debug(f"Writing MACD trend for {symbol}")

        macd_trend_record = {
            'symbol': symbol,
            'timestamp': int(datetime.now().timestamp()),
            'display_time': datetime.now(),
            'interval': interval,
            'trend': macd_trend,
            'histogram': last_histogram
        }

        async with self.session_maker() as session:
            async with session.begin():
                await session.execute(
                    delete(MACDTrend).filter(MACDTrend.symbol == symbol, MACDTrend.interval == interval)
                )
                session.add(MACDTrend(**macd_trend_record))
            await session.commit()
        logger.debug(f"MACD trend for {symbol} have been written")

    async def get_latest_macd_trend(self, symbol: str, interval: str) -> str:
        logger.debug(f"Reading latest MACD trend for symbol {symbol}")
        async with self.session_maker() as session:
            stmt = select(MACDTrend.trend).filter(
                MACDTrend.symbol == symbol, MACDTrend.interval == interval)
            result = await session.execute(stmt)
            macd_trend = result.scalars().first()
        logger.debug(f"Latest MACD trend for {symbol} is retrieved")
        return macd_trend
