from typing import Any

from pandas import DataFrame

from db.config import get_db
from db.model.binance.order import Order
from db.model.binance.order_book import OrderBook
from oam import log_config

logger = log_config.get_logger(__name__)


class OrderRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_order(self, symbol: str, order: DataFrame) -> None:
        logger.debug(f"Writing orders for {symbol}")
        orders = order.to_dict(orient='records')
        async with self.session_maker() as session:
            for order in orders:
                session.add(Order(**order))
            await session.commit()
        logger.debug(f"Orders for {symbol} are written")

    async def update_order(self, symbol: str, order_id: int, order: DataFrame) -> None:
        logger.debug(f"Updating order for {symbol}")
        orders = order.to_dict(orient='records')
        async with self.session_maker() as session:
            for order in orders:
                session.query(Order).filter(Order.order_id == order_id).update(order)
            await session.commit()
        logger.debug(f"Order for {symbol} is updated")

    async def get_orders(self, symbol: str) -> list:
        logger.debug(f"Getting orders for {symbol}")
        async with self.session_maker() as session:
            orders = session.query(Order).filter(Order.symbol == symbol).all()
            return orders
