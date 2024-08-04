from pandas import DataFrame

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