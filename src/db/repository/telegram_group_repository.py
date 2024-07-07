from src import log_config

from sqlalchemy import select, text

from src.db.config import get_db
from src.db.model.telegram_group import TelegramGroup

logger = log_config.get_logger(__name__)


class TelegramGroupRepository:

    def __init__(self):
        self.session_maker = get_db

    async def create_telegram_group(self, chat_id: str, owner_username: str, display_name: str, t_me_url: str) -> None:
        async with self.session_maker() as session:
            logger.info(f"Session {session}")
            group = TelegramGroup(chat_id, owner_username, display_name, t_me_url)
            session.add(group)
            await session.commit()

    async def load_telegram_group_by_chat_id(self, chat_id: str) -> TelegramGroup:
        async with self.session_maker() as session:
            async with session.begin():
                logger.info(f"Load Telegram chat by chat id {chat_id}")
                stmt = select(TelegramGroup).where(TelegramGroup.chat_id == chat_id)
                telegram_group = await session.execute(stmt)
                telegram_group = telegram_group.fetchall()
                return telegram_group

    async def load_telegram_groups_by_username(self, username: str) -> list[TelegramGroup]:
        async with self.session_maker() as session:
            async with session.begin():
                logger.info(f"Load all telegram chats for the owner {username}")
                stmt = text('''
                SELECT
                    tg.chat_id,
                    tg.display_name,
                    tg.owner_username,
                    tg.t_me_url
                FROM telegram_group tg
                WHERE owner_username = :username
                ''')
                telegram_groups = await session.execute(stmt, {'username': username})
                telegram_groups = telegram_groups.fetchall()
                return telegram_groups

