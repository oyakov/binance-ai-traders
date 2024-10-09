from sqlalchemy import Integer, Column, JSON, String, BigInteger, DateTime

from db.model.base import Base


class OrderBook(Base):
    __tablename__ = 'order_books'
    id = Column(Integer, primary_key=True, autoincrement=True)
    symbol = Column(String, nullable=False)
    last_update_id = Column(BigInteger, nullable=False)
    tx_time = Column(DateTime, nullable=False)
    type = Column(String, nullable=False)
    price = Column(BigInteger, nullable=False)
    quantity = Column(BigInteger, nullable=False)
