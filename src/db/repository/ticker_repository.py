from pandas import DataFrame
from sqlalchemy import select

from db.config import get_db
from db.model.binance.ticker import Ticker
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

    async def get_last_ticker(self, symbol: str) -> DataFrame:
        logger.debug(f"Getting last ticker for {symbol}")
        async with self.session_maker() as session:
            stmt = select(Ticker).filter(Ticker.symbol == symbol).order_by(
                Ticker.close_time.desc())
            result = await session.execute(stmt)
            ticker = result.scalars().first()
        if ticker is None:
            logger.debug(f"No ticker found for {symbol}")
            return DataFrame()
        ticker = DataFrame([ticker.__dict__])
        logger.debug(f"Last ticker for {symbol} is retrieved")
        return ticker



