from sqlalchemy import Integer, Column, DateTime, Float, String, BigInteger

from db.model.base import Base


class MACDTrend(Base):
    __tablename__ = 'macd_trend'
    id = Column(Integer, primary_key=True)
    symbol = Column(String)
    timestamp = Column(BigInteger)
    display_time = Column(DateTime)
    interval = Column(String)  # 1m, 5m, 15m, 1h, 1d
    trend = Column(String)
    histogram = Column(Float)
