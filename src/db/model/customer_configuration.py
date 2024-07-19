# db_config.py
from sqlalchemy import Column, Integer, String, JSON
from sqlalchemy.ext.declarative import declarative_base

from db.config import get_db

Base = declarative_base()


class CustomerConfiguration(Base):
    __tablename__ = 'customer_configurations'
    customer_id = Column(Integer, primary_key=True, autoincrement=True)
    api_key = Column(String, nullable=False)
    subsystems = Column(JSON, nullable=False)
    status = Column(String, default='inactive')  # Add status column


# Read/Write operations
def get_customer_configs():
    async with get_db() as session:
        return session.query(CustomerConfiguration).all()
