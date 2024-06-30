import os
import logging

from contextlib import asynccontextmanager
from dotenv import load_dotenv
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, DeclarativeBase

logger = logging.getLogger(__name__)

load_dotenv()
DATABASE_URL = os.getenv('DATABASE_URL')

engine = create_async_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession)


# AsyncAttrs mixin is added to the Base here
# to use awaitable attributes fecture in order to use attribute lazy-loading along with asyncio
class Base(AsyncAttrs, DeclarativeBase):
    pass


@asynccontextmanager
async def get_db():
    async with SessionLocal() as session:
        yield session


async def init_db():
    logger.info("Init db")
    async with engine.begin() as conn:
        # While testing we will also drop all
        # TODO: remove when going to production
        await conn.run_sync(Base.metadata.drop_all)
        # Create all tables from the model class
        await conn.run_sync(Base.metadata.create_all)
