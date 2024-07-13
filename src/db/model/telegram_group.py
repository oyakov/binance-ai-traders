from typing import Any

from sqlalchemy import Column, Integer, String

from db.model.base import Base


class TelegramGroup(Base):
    """
    A chats that is managed by the users
    """
    __tablename__ = "telegram_group"

    id = Column(Integer, primary_key=True, index=True)
    chat_id = Column(String, unique=True, index=False)
    worker_bot_instance_id = Column(Integer, index=True)
    owner_username = Column(String, unique=False, index=True)
    display_name = Column(String, unique=False, index=False)
    t_me_url = Column(String, unique=False, index=False)

    def __init__(self, chat_id: str, owner_username: str, display_name: str, t_me_url: str, **kw: Any):
        super().__init__(**kw)
        self.chat_id = chat_id
        self.owner_username = owner_username
        self.display_name = display_name
        self.t_me_url = t_me_url

    def __str__(self) -> str:
        return f'Telegram Group (' \
               f'chat_id: {self.chat_id}, ' \
               f'owner_username: {self.owner_username}, ' \
               f'display_name: {self.display_name})' \
               f'URL: {self.t_me_url}'
