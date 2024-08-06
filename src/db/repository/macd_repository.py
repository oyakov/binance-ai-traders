from datetime import datetime

from pandas import DataFrame
from sqlalchemy import select, delete

from db.config import get_db
from db.model.macd import MACD
from oam import log_config

logger = log_config.get_logger(__name__)


class MACDRepository:
    def __init__(self):
        self.session_maker = get_db

    async def write_macd(self, symbol: str, interval: str, macd: DataFrame) -> None:
        logger.debug(f"Writing MACD for {symbol}")

        # Add the current collection time to the DataFrame
        macd['collection_time'] = datetime.now()

        # Convert the DataFrame to a list of dictionaries
        macd_records = macd.to_dict(orient='records')

        async with self.session_maker() as session:
            async with session.begin():
                # Step 1: Delete existing MACD entries for the specified symbol and interval
                await session.execute(
                    delete(MACD).filter(MACD.symbol == symbol, MACD.interval == interval)
                )

                # Step 2: Insert new MACD entries
                for record in macd_records:
                    session.add(MACD(symbol=symbol, interval=interval, **record))

            # Commit the transaction
            await session.commit()

        logger.debug(f"MACD for {symbol} have been written")

    async def get_latest_macd(self, symbol: str, interval: str) -> DataFrame:
        logger.debug(f"Reading latest MACD for symbol {symbol}")

        async with self.session_maker() as session:
            # Step 1: Get the latest timestamp for the given symbol and interval
            subquery = (
                select(MACD.collection_time)
                .filter(MACD.symbol == symbol, MACD.interval == interval)
                .order_by(MACD.collection_time.desc())
                .limit(1)
            )
            result = await session.execute(subquery)
            latest_timestamp = result.scalar()

            if latest_timestamp is None:
                return DataFrame()

            # Step 2: Retrieve all MACD entries with that latest timestamp
            stmt = select(MACD).filter(
                MACD.symbol == symbol,
                MACD.interval == interval,
                MACD.collection_timestamp == latest_timestamp
            )
            result = await session.execute(stmt)
            macd_records = result.scalars().all()

        if not macd_records:
            return DataFrame()

        # Convert the MACD records to a DataFrame
        macd = DataFrame([record.__dict__ for record in macd_records])

        logger.debug(f"Latest MACD for {symbol} is retrieved")
        return macd
