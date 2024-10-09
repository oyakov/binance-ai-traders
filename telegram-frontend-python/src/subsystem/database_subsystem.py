from sqlalchemy import text

from db.config import engine, get_db
from db.model.base import Base
# Ensure all models are imported
from db.model.telegram.telegram_group import TelegramGroup
from oam import log_config
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


async def create_tables():
    logger.info("create tables")
    async with engine.begin() as conn:
        # While testing we will also drop all
        # TODO: remove when going to production
        await conn.run_sync(Base.metadata.drop_all)
        # Create all tables from the model class
        await conn.run_sync(Base.metadata.create_all)


async def partition_klines_table():
    async with engine.begin() as conn:
        await conn.execute(text("CREATE TABLE klines_1m PARTITION OF klines FOR VALUES IN ('1m');"))
        await conn.execute(text("CREATE TABLE klines_1h PARTITION OF klines FOR VALUES IN ('1h');"))


async def populate_test_groups():
    logger.debug("Populate test Telegram Groups")
    initial_groups = [
        TelegramGroup('-1002060021902', 'oyakov', 'Test Group 1', 'https://t.me/beograd_service'),
        TelegramGroup('-4284276251', 'oyakov', 'Test Group 2', 'https://t.me/ruskie_v_belgrade')
    ]
    async with get_db() as session:
        session.add_all(initial_groups)
        await session.commit()


class DatabaseSubsystem(Subsystem):
    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing the DB")
        try:
            await create_tables()
            logger.debug(f"Tables are created")
            # await partition_klines_table()
            # logger.debug(f"Klines table is partitioned")
            await populate_test_groups()
            logger.debug(f"Test groups are populated")
            self.is_initialized = True
            logger.info(f"Database is initialized")
        except OSError as exception:
            logger.error(f"Error connecting to the database: {exception}")
        except Exception as exception:
            logger.error(f"Error creating tables: {exception}")

    async def shutdown(self):
        pass

    def get_priority(self) -> InitPriority:
        return InitPriority.DATA_SOURCE
