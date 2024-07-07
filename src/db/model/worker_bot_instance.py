from datetime import datetime, timezone

from sqlalchemy import Column, Integer, ForeignKey, DateTime, Boolean, Table
from sqlalchemy.orm import relationship

from src.db.model.base import Base

# Define the association table
worker_bot_instance_admin_user = \
    Table('worker_bot_instance_admin_user', Base.metadata,
          Column('worker_bot_instance_id', Integer, ForeignKey('worker_bot_instance.id')),
          Column('admin_user_id', Integer, ForeignKey('admin_user.id'))
          )


class WorkerBotInstance(Base):
    __tablename__ = 'worker_bot_instance'

    id = Column(Integer, primary_key=True)
    # Define the relationship to AdminUser
    admin_users = relationship('AdminUser', secondary=worker_bot_instance_admin_user, backref='worker_bot_instances')
    created_at = Column(DateTime, default=datetime.now(timezone.utc))
    updated_at = Column(DateTime, default=datetime.now(timezone.utc), onupdate=datetime.now(timezone.utc))
    deleted_at = Column(DateTime, nullable=True)
    deleted = Column(Boolean, default=False)
