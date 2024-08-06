from sqlalchemy import Column, String, Float, Integer, BigInteger, DateTime

from db.model.base import Base


class Ticker(Base):
    __tablename__ = 'tickers'
    id = Column(Integer, primary_key=True, autoincrement=True)
    symbol = Column(String, nullable=False)
    price_change = Column(Float)
    price_change_percent = Column(Float)
    weighted_avg_price = Column(Float)
    prev_close_price = Column(Float)
    last_price = Column(Float)
    last_qty = Column(Float)
    bid_price = Column(Float)
    bid_qty = Column(Float)
    ask_price = Column(Float)
    ask_qty = Column(Float)
    open_price = Column(Float)
    high_price = Column(Float)
    low_price = Column(Float)
    volume = Column(Float)
    quote_volume = Column(Float)
    open_time = Column(BigInteger)
    dispay_open_time = Column(DateTime)
    close_time = Column(BigInteger)
    display_close_time = Column(DateTime)
    first_id = Column(BigInteger)
    last_id = Column(BigInteger)
    count = Column(Integer)
