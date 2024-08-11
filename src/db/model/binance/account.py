from sqlalchemy import Column, Integer, Boolean, String, JSON, BigInteger
from sqlalchemy.orm import relationship

from db.model.base import Base


class Account(Base):
    __tablename__ = 'accounts'

    id = Column(Integer, primary_key=True, autoincrement=True)
    uid = Column(BigInteger, unique=True, nullable=False)
    maker_commission = Column(Integer, nullable=False)
    taker_commission = Column(Integer, nullable=False)
    buyer_commission = Column(Integer, nullable=False)
    seller_commission = Column(Integer, nullable=False)
    can_trade = Column(Boolean, nullable=False)
    can_withdraw = Column(Boolean, nullable=False)
    can_deposit = Column(Boolean, nullable=False)
    brokered = Column(Boolean, nullable=False)
    require_self_trade_prevention = Column(Boolean, nullable=False)
    prevent_sor = Column(Boolean, nullable=False)
    account_type = Column(String, nullable=False)
    update_time = Column(BigInteger, nullable=False)

    # Relationship to balances
    balances = Column(JSON, nullable=False)

    # Optionally, you can store commission rates as a JSON column
    commission_rates = Column(JSON, nullable=False)

    permissions = Column(JSON, nullable=False)
