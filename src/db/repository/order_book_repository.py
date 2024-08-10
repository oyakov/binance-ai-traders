from pandas import DataFrame
from sqlalchemy import select

from db.config import get_db
from db.model.binance.order_book import OrderBook
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

    async def get_order_book(self, symbol: str, start_time: int, end_time: int) -> DataFrame:
        logger.debug(f"Getting order book for {symbol}")
        async with self.session_maker() as session:
            stmt = select(OrderBook).filter(OrderBook.symbol == symbol, OrderBook.tx_time >= start_time,
                                            OrderBook.tx_time <= end_time)
            result = await session.execute(stmt)
            order_book = result.scalars().all()
        order_book = DataFrame([order.__dict__ for order in order_book])
        logger.debug(f"Order book for {symbol} is retrieved")
        return order_book

    async def get_latest_order_book(self, symbol: str) -> DataFrame:
        logger.debug(f"Getting latest order book for {symbol}")
        async with self.session_maker() as session:
            stmt = select(OrderBook).filter(OrderBook.symbol == symbol).order_by(
                OrderBook.tx_time.desc())
            result = await session.execute(stmt)
            order_book = result.scalars().first()
        if order_book is None:
            logger.debug(f"No order book found for {symbol}")
            return DataFrame()
        order_book = DataFrame([order_book.__dict__])
        logger.debug(f"Latest order book for {symbol} is retrieved")
        return order_book
