from sqlalchemy import select, delete

from db.config import get_db
from db.model.binance.account import Account
from oam import log_config

logger = log_config.get_logger(__name__)


class AccountRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_account(self, account: dict) -> None:
        logger.debug(f"Writing account {account}")
        async with self.session_maker() as session:
            session.add(Account(**account))
            await session.commit()
        logger.debug(f"Account {account} is written")

    async def update_account(self, uid: int, account: dict) -> None:
        logger.debug(f"Updating account {uid}")
        async with self.session_maker() as session:
            stmt = select(Account).filter(Account.uid == uid)
            result = await session.execute(stmt)
            db_account = result.scalars().first()
            if db_account is None:
                logger.debug(f"Account with uid {uid} not found")
                return
            for key, value in account.items():
                if hasattr(db_account, key):
                    setattr(db_account, key, value)
            await session.commit()
        logger.debug(f"Account with uid {uid} is updated")

    async def get_account(self, uid: int) -> Account:
        logger.debug(f"Getting account {uid}")
        async with self.session_maker() as session:
            stmt = select(Account).filter(Account.uid == uid)
            result = await session.execute(stmt)
            account = result.scalars().first()
        logger.debug(f"Account {uid} is retrieved")
        return account
