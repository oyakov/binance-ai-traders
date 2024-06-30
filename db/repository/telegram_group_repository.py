import logging

from sqlalchemy import select as sel
from db.config import get_db
from db.model.telegram_group import TelegramGroup

logger = logging.getLogger(__name__)


async def populate_test_groups():
    logger.info("Populate test Telegram Groups")
    initial_groups = [
        TelegramGroup('-1002060021902', '@oyakov', 'Test Group 1', 'https://t.me/beograd_service'),
        TelegramGroup('-4284276251', '@oyakov', 'Test Group 2', 'https://t.me/ruskie_v_belgrade')
    ]
    async with get_db() as session:
        session.add_all(initial_groups)
        await session.commit()


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
                stmt = sel(TelegramGroup).where(TelegramGroup.chat_id == chat_id)
                telegram_group = await session.execute(stmt)
                telegram_group = telegram_group.fetchall()
                return telegram_group

    async def load_telegram_groups_by_username(self, username: str) -> list[TelegramGroup]:
        async with self.session_maker() as session:
            async with session.begin():
                logger.info(f"Load all telegram chats for the owner {username}")
                stmt = sel(TelegramGroup).where(TelegramGroup.owner_username == username)
                telegram_groups = await session.execute(stmt)
                telegram_groups = telegram_groups.fetchall()
                return telegram_groups

