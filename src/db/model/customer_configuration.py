# db_config.py
from sqlalchemy import Column, Integer, String, JSON

from db.config import get_db
from db.model.base import Base


class CustomerConfiguration(Base):
    __tablename__ = 'customer_configurations'
    customer_id = Column(Integer, primary_key=True, autoincrement=True)
    api_key = Column(String, nullable=False)
    subsystems = Column(JSON, nullable=False)
    status = Column(String, default='inactive')  # Add status column


# Read/Write operations
async def get_customer_configs():
    async with get_db() as session:
        return session.query(CustomerConfiguration).all()
