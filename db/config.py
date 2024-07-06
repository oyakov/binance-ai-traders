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



