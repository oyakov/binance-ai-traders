from sqlalchemy import Column, Integer, String

from src.db.model.base import Base


class AdminUser(Base):
    __tablename__ = "admin_user"
    id = Column(Integer, primary_key=True, index=True)
    telegram_username = Column(String, unique=False, index=False)
    display_name = Column(String, unique=False, index=False)
    comment = Column(String, unique=False, index=False)
