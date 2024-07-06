import logging

from db.config import engine, get_db
from db.model.base import Base
from db.model.telegram_group import TelegramGroup
from subsystem.subsystem import Subsystem

logger = logging.getLogger(__name__)


async def create_tables():
    logger.info("create tables")
    try:
        async with engine.begin() as conn:
            # While testing we will also drop all
            # TODO: remove when going to production
            await conn.run_sync(Base.metadata.drop_all)
            # Create all tables from the model class
            await conn.run_sync(Base.metadata.create_all)
    except() as exception:
        logger.error(f"Error creating tables in the database: {exception}")


async def populate_test_groups():
    logger.info("Populate test Telegram Groups")
    initial_groups = [
        TelegramGroup('-1002060021902', 'oyakov', 'Test Group 1', 'https://t.me/beograd_service'),
        TelegramGroup('-4284276251', 'oyakov', 'Test Group 2', 'https://t.me/ruskie_v_belgrade')
    ]
    async with get_db() as session:
        session.add_all(initial_groups)
        await session.commit()


class DatabaseSubsystem(Subsystem):
    async def initialize(self):
        logger.info(f"Initializing the DB")
        try:
            await create_tables()
            logger.info(f"Tables are created")
            await populate_test_groups()
            logger.info(f"Database is initialized")
        except() as exception:
            logger.error(f"Error initializing the database {exception}")