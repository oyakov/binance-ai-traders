from sqlalchemy.future import select
from sqlalchemy import text, select as sel
from db.config import *
from db.model.telegram_group import TelegramGroup

logger = logging.getLogger(__name__)


def static_groups_mock():
    return [
        TelegramGroup('-1002060021902', '@konsalex', 'Белградский Консьерж', 'https://t.me/beograd_service'),
        TelegramGroup('-1002060021902', '@konsalex', 'Русские в Белграде', 'https://t.me/ruskie_v_belgrade')
    ]


class TelegramGroupRepository:

    def __init__(self):
        self.session_maker = get_db
        for group in static_groups_mock():
            self.create_telegram_group(group.chat_id, group.owner_username, group.display_name, group.t_me_url)

    async def create_telegram_group(self, chat_id: str, owner_username: str, display_name: str, t_me_url: str) -> None:
        async with self.session_maker() as session:
            logger.info(f"Session {session}")
            group = TelegramGroup(chat_id, owner_username, display_name, t_me_url)
            session.add(group)
            await session.commit()

    async def load_telegram_group_by_chat_id(self, chat_id: str) -> TelegramGroup:
        async with self.session_maker() as session:
            async with session.begin():
                logger.info(f"load Telegram chat by chat id {chat_id}")
                stmt = sel(TelegramGroup).where(TelegramGroup.chat_id == chat_id)
                telegram_group = await session.execute(stmt)
                telegram_group = telegram_group.fetchall()
                return telegram_group

    async def load_telegram_groups_by_username(self, username: str) -> list[TelegramGroup]:
        async with self.session_maker() as session:
            async with session.begin():
                logger.info(f"load all tg chats for the username {username}")
                stmt = sel(TelegramGroup).where(TelegramGroup.owner_username == username)
                telegram_groups = await session.execute(stmt)
                telegram_groups = telegram_groups.fetchall()
                return telegram_groups
