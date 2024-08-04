from pandas import DataFrame

from db.config import get_db
from db.model.ticker import Ticker
from oam import log_config

logger = log_config.get_logger(__name__)


class TickerRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_ticker(self, symbol: str, ticker: DataFrame) -> None:
        logger.debug(f"Writing ticker for {symbol}")
        tickers = ticker.to_dict(orient='records')
        async with self.session_maker() as session:
            for ticker in tickers:
                session.add(Ticker(**ticker))
            await session.commit()
        logger.debug(f"Ticker for {symbol} is written")

