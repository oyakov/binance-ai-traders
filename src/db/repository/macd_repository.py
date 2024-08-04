from pandas import DataFrame

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