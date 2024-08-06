from sqlalchemy import Integer, Column, JSON, String, BigInteger

from db.model.base import Base


class OrderBook(Base):
    __tablename__ = 'order_books'
    id = Column(Integer, primary_key=True, autoincrement=True)
    symbol = Column(String, nullable=False)
    lastUpdateId = Column('last_update_id', BigInteger, nullable=False)
    bids = Column(JSON, nullable=False)
    asks = Column(JSON, nullable=False)
