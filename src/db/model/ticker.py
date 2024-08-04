from sqlalchemy import Column, String, Float, Integer, BigInteger, DateTime

from db.model.base import Base


class Ticker(Base):
    __tablename__ = 'tickers'
    id = Column('id', Integer, primary_key=True, autoincrement=True)
    symbol = Column('symbol', String, nullable=False)
    priceChange = Column('price_change', Float)
    priceChangePercent = Column('price_change_percent', Float)
    weightedAvgPrice = Column('weighted_avg_price', Float)
    prevClosePrice = Column('prev_close_price', Float)
    lastPrice = Column('last_price', Float)
    lastQty = Column('last_qty', Float)
    bidPrice = Column('bid_price', Float)
    bidQty = Column('bid_qty', Float)
    askPrice = Column('ask_price', Float)
    askQty = Column('ask_qty', Float)
    openPrice = Column('open_price', Float)
    highPrice = Column('high_price', Float)
    lowPrice = Column('low_price', Float)
    volume = Column('volume', Float)
    quoteVolume = Column('quote_volume', Float)
    openTime = Column('open_time', DateTime)
    closeTime = Column('close_time', DateTime)
    firstId = Column('first_id', BigInteger)
    lastId = Column('last_id', BigInteger)
    count = Column('count', Integer)
