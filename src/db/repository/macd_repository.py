from pandas import DataFrame
from sqlalchemy import select

from db.config import get_db
from db.model.kline import Kline
from db.model.macd import MACD
from oam import log_config

logger = log_config.get_logger(__name__)


class MACDRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_macd(self, symbol: str, interval: str, macd: DataFrame) -> None:
        logger.debug(f"Writing MACD for {symbol}")
        macd = macd.to_dict(orient='records')
        async with self.session_maker() as session:
            for chunk in macd:
                session.add(MACD(symbol=symbol, interval=interval, **chunk))
            await session.commit()
        logger.debug(f"MACD for {symbol} are written")

    async def get_latest_macd(self, symbol: str, interval: str) -> DataFrame:
        logger.debug(f"Reading latest MACD for sybol {symbol}")
        async with self.session_maker() as session:
            stmt = select(MACD).filter(MACD.symbol == symbol, MACD.interval == interval).order_by(
                                       MACD.timestamp.desc())
            result = await session.execute(stmt)
            macd = result.scalars().first()
        if macd is None:
            return DataFrame()
        macd = DataFrame([macd.__dict__])
        logger.debug(f"Latest MACD for {symbol} is retrieved")
        return macd
