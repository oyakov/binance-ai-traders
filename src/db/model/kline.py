from sqlalchemy import Integer, Column, DateTime, Float, String

from db.model.base import Base


class Kline(Base):
    __tablename__ = 'klines'
    id = Column(Integer, primary_key=True)
    symbol = Column(String)
    interval = Column(String)  # 1m, 5m, 15m, 1h, 1d
    timestamp = Column(DateTime)
    open = Column(Float)
    high = Column(Float)
    low = Column(Float)
    close = Column(Float)
    volume = Column(Float)
    close_time = Column(DateTime)
    quote_asset_volume = Column(Float)
    number_of_trades = Column(Integer)
    taker_buy_base_asset_volume = Column(Float)
    taker_buy_quote_asset_volume = Column(Float)
    ignore = Column(String)
