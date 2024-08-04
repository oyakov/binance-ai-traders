from db.config import get_db
from db.model.ticker import Ticker
from oam import log_config

logger = log_config.get_logger(__name__)


class TickerRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_ticker(self, symbol: str, ticker: dict) -> None:
        logger.debug(f"Writing ticker for {symbol}")
        async with self.session_maker() as session:
            session.add(Ticker(symbol=symbol, **ticker))
            await session.commit()
        logger.debug(f"Ticker for {symbol} is written")

