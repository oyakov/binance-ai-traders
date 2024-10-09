from sqlalchemy import Column, Integer, String, Float, ForeignKey

from db.model.base import Base


class Balance(Base):
    __tablename__ = 'balances'
    id = Column(Integer, primary_key=True, autoincrement=True)
    asset = Column(String, nullable=False)
    free = Column(Float, nullable=False)
    locked = Column(Float, nullable=False)

    # Foreign key to account
    account_id = Column(Integer, ForeignKey('accounts.id'), nullable=False)
