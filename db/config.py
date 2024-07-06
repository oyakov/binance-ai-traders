import logging
import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, DeclarativeBase

logger = logging.getLogger(__name__)

load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')
logger.info(f"Database URL: {DATABASE_URL}")

engine = create_async_engine(DATABASE_URL, echo=True)
logger.info(f"Engine created {engine}")
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession)
logger.info(f"Session generator created {SessionLocal}")


# AsyncAttrs mixin is added to the Base here
# to use awaitable attributes fecture in order to use attribute lazy-loading along with asyncio
class Base(AsyncAttrs, DeclarativeBase):
    pass


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
