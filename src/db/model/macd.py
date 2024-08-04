from sqlalchemy import Integer, Column, DateTime, Float, String

from db.model.base import Base


class MACD(Base):
    __tablename__ = 'macd'
    id = Column(Integer, primary_key=True)
    symbol = Column(String)
    interval = Column(String)  # 1m, 5m, 15m, 1h, 1d
    timestamp = Column(DateTime)
    ema_fast = Column(Float)
    ema_slow = Column(Float)
    macd = Column(Float)
    signal = Column(Float)
    histogram = Column(Float)
