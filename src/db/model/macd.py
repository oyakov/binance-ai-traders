from sqlalchemy import Integer, Column, DateTime, Float, String, BigInteger

from db.model.base import Base


class MACD(Base):
    __tablename__ = 'macd'
    id = Column(Integer, primary_key=True)
    symbol = Column(String)
    interval = Column(String)  # 1m, 5m, 15m, 1h, 1d
    display_time = Column(DateTime)
    timestamp = Column(BigInteger)
    ema_fast = Column(Float)
    ema_slow = Column(Float)
    macd = Column(Float)
    signal = Column(Float)
    histogram = Column(Float)
