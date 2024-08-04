from db.config import get_db
from db.model.order_book import OrderBook
from oam import log_config

logger = log_config.get_logger(__name__)


class OrderBookRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_order_book(self, symbol: str, order_book: dict) -> None:
        logger.debug(f"Writing order book for {symbol}")
        async with self.session_maker() as session:
            session.add(OrderBook(symbol=symbol, **order_book))
            await session.commit()
        logger.debug(f"Order book for {symbol} is written")
