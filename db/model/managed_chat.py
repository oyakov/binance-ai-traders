from sqlalchemy import Column, Integer, String

from db.config import Base


class ManagedChat(Base):
    __tablename__ = "managed_chats"
    id = Column(Integer, primary_key=True, index=True)
    chat_id = Column(String, unique=False, index=False)
    display_name = Column(String, unique=False, index=False)
