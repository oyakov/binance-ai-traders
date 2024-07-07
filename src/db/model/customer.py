from sqlalchemy import Column, Integer, String

from src.db.model.base import Base


class Customer(Base):
    __tablename__ = "customers"
    id = Column(Integer, primary_key=True, index=True)
    telegram_username = Column(String, unique=False, index=False)
    display_name = Column(String, unique=False, index=False)
    comment = Column(String, unique=False, index=False)
