from contextlib import asynccontextmanager

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

from src import log_config
from src.environment import DATABASE_URL, DB_CONNECTION_POOL_MIN_SIZE, DB_CONNECTION_POOL_MAX_SIZE

logger = log_config.get_logger(__name__)
logger.info(f"Database URL: {DATABASE_URL}, DB_CONNECTION_POOL_MIN_SIZE: {DB_CONNECTION_POOL_MIN_SIZE}, "
            f"DB_CONNECTION_POOL_MAX_SIZE: {DB_CONNECTION_POOL_MAX_SIZE}")

engine = create_async_engine(url=DATABASE_URL,
                             pool_size=DB_CONNECTION_POOL_MIN_SIZE,
                             max_overflow=DB_CONNECTION_POOL_MAX_SIZE - DB_CONNECTION_POOL_MIN_SIZE,
                             echo=True)
logger.info(f"Engine created {engine}")
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine, class_=AsyncSession)
logger.info(f"Session generator created {SessionLocal}")


@asynccontextmanager
async def get_db():
    async with SessionLocal() as session:
        yield session



