from sqlalchemy import Column, Integer, String, Float, BigInteger, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship

from db.model.base import Base


class Order(Base):
    __tablename__ = 'orders'
    id = Column(Integer, primary_key=True, autoincrement=True)
    symbol = Column(String(10), nullable=False)
    order_id = Column(BigInteger, nullable=False, unique=True)
    order_list_id = Column(Integer, nullable=False, default=-1)
    client_order_id = Column(String(50), nullable=False)
    transact_time = Column(BigInteger, nullable=False)
    price = Column(Float, nullable=False, default=0.0)
    orig_qty = Column(Float, nullable=False)
    executed_qty = Column(Float, nullable=False)
    cummulative_quote_qty = Column(Float, nullable=False)
    status = Column(String(20), nullable=False)
    time_in_force = Column(String(10), nullable=False)
    type = Column(String(20), nullable=False)
    side = Column(String(10), nullable=False)
    working_time = Column(BigInteger, nullable=False)
    self_trade_prevention_mode = Column(String(20), nullable=False, default="NONE")
    # Relationship to the Fill model
    fills = relationship("Fill", back_populates="order", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Order(order_id={self.order_id}, symbol={self.symbol}, status={self.status})>"


class Fill(Base):
    __tablename__ = 'fills'

    id = Column(Integer, primary_key=True, autoincrement=True)
    price = Column(Float, nullable=False)
    qty = Column(Float, nullable=False)
    commission = Column(Float, nullable=False)
    commission_asset = Column(String(10), nullable=False)
    trade_id = Column(Integer, nullable=False)

    # Foreign key to the orders table
    order_id = Column(Integer, ForeignKey('orders.id', ondelete='CASCADE'), nullable=False)

    # Relationship back to the Order model
    order = relationship("Order", back_populates="fills")

    def __repr__(self):
        return f"<Fill(trade_id={self.trade_id}, price={self.price}, qty={self.qty})>"