from typing import Any

from pandas import DataFrame
from sqlalchemy import select

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

        # Convert the DataFrame to a list of dictionaries
        orders = order.to_dict(orient='records')

        async with self.session_maker() as session:
            for order_data in orders:
                # Select the order from the database using order_id
                stmt = select(Order).filter(Order.order_id == order_id)
                result = await session.execute(stmt)
                db_order = result.scalars().first()

                if db_order is None:
                    logger.debug(f"Order with order_id {order_id} for {symbol} not found")
                    return

                # Update the fields of the order with the new data
                for key, value in order_data.items():
                    if hasattr(db_order, key):
                        setattr(db_order, key, value)

                # Optionally, you can add more custom logic here

            # Commit the transaction
            await session.commit()

        logger.debug(f"Order with order_id {order_id} for {symbol} is updated")

    async def get_orders(self, symbol: str) -> list:
        logger.debug(f"Getting orders for {symbol}")
        async with self.session_maker() as session:
            orders = session.query(Order).filter(Order.symbol == symbol).all()
            return orders
