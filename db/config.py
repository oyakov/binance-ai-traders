import logging
import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from db.model.base import Base
from db.model.telegram_group import TelegramGroup
from subsystem.subsystem import Subsystem

logger = logging.getLogger(__name__)

load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')
logger.info(f"Database URL: {DATABASE_URL}")

engine = create_async_engine(DATABASE_URL, echo=True)
logger.info(f"Engine created {engine}")
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession)
logger.info(f"Session generator created {SessionLocal}")


@asynccontextmanager
async def get_db():
    async with SessionLocal() as session:
        yield session


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
