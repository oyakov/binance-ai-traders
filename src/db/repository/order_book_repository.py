from pandas import DataFrame
from sqlalchemy import select, delete

from db.config import get_db
from db.model.binance.order_book import OrderBook
from oam import log_config

logger = log_config.get_logger(__name__)


class OrderBookRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_order_books(self, symbol: str, order_books: DataFrame) -> None:
        logger.debug(f"Writing order book for {symbol}")
        # Delete existing order books for the symbol
        async with self.session_maker() as session:
            await session.execute(delete(OrderBook).filter(OrderBook.symbol == symbol))
            await session.commit()
        # Write new order books to the database
        async with self.session_maker() as session:
            for order_book in order_books.to_dict(orient='records'):
                session.add(OrderBook(symbol=symbol, **order_book))
            await session.commit()
        logger.debug(f"Order book for {symbol} is written")

    async def get_order_book(self, symbol: str) -> DataFrame:
        logger.debug(f"Getting order book for {symbol}")
        async with self.session_maker() as session:
            stmt = select(OrderBook).filter(OrderBook.symbol == symbol)
            result = await session.execute(stmt)
            order_book = result.scalars().all()
        order_book = DataFrame([order.__dict__ for order in order_book])
        logger.debug(f"Order book for {symbol} is retrieved")
        return order_book
