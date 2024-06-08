from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import sessionmaker
from sqlalchemy import update
from db.config import Base
from db.model import CalendarData, CalendarDoW, CalendarDoM, CalendarMoY, CalendarToD

class MessageService:
    def __init__(self, session_maker: sessionmaker):
        self.session_maker = session_maker

    async def create_calendar_data(self, username: str, data: str = None, dow_id: int = None, dom_id: int = None, moy_id: int = None, tod_id: int = None):
        async with self.session_maker() as session:
            # Set default values if missing
            dow_id = dow_id or await self._get_default_dow_id(session)
            dom_id = dom_id or await self._get_default_dom_id(session)
            moy_id = moy_id or await self._get_default_moy_id(session)
            tod_id = tod_id or await self._get_default_tod_id(session)

            new_record = CalendarData(
                username=username,
                data=data,
                dow_id=dow_id,
                dom_id=dom_id,
                moy_id=moy_id,
                tod_id=tod_id
            )

            session.add(new_record)
            await session.commit()

    async def update_calendar_data(self, record_id: int, username: str = None, data: str = None, dow_id: int = None, dom_id: int = None, moy_id: int = None, tod_id: int = None):
        async with self.session_maker() as session:
            async with session.begin():
                stmt = select(CalendarData).where(CalendarData.id == record_id)
                result = await session.execute(stmt)
                record = result.scalar_one_or_none()

                if record:
                    if username:
                        record.username = username
                    if data:
                        record.data = data
                    if dow_id:
                        record.dow_id = dow_id
                    if dom_id:
                        record.dom_id = dom_id
                    if moy_id:
                        record.moy_id = moy_id
                    if tod_id:
                        record.tod_id = tod_id

                    await session.commit()

    async def _get_default_dow_id(self, session: AsyncSession) -> int:
        # Implement the logic to get or create a default CalendarDoW record
        stmt = select(CalendarDoW.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_dow = CalendarDoW(monday=True, tuesday=True, wednesday=True, thursday=True, friday=True, saturday=True, sunday=True)
            session.add(default_dow)
            await session.commit()
            return default_dow.id
        return default_id

    async def _get_default_dom_id(self, session: AsyncSession) -> int:
        # Implement the logic to get or create a default CalendarDoM record
        stmt = select(CalendarDoM.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_dom = CalendarDoM(day_1=True, day_2=True, day_3=True, day_4=True, day_5=True, day_6=True, day_7=True, day_8=True, day_9=True, day_10=True,
                                      day_11=True, day_12=True, day_13=True, day_14=True, day_15=True, day_16=True, day_17=True, day_18=True, day_19=True, day_20=True,
                                      day_21=True, day_22=True, day_23=True, day_24=True, day_25=True, day_26=True, day_27=True, day_28=True, day_29=True, day_30=True, day_31=True)
            session.add(default_dom)
            await session.commit()
            return default_dom.id
        return default_id

    async def _get_default_moy_id(self, session: AsyncSession) -> int:
        # Implement the logic to get or create a default CalendarMoY record
        stmt = select(CalendarMoY.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_moy = CalendarMoY(january=True, february=True, march=True, april=True, may=True, june=True, july=True, august=True, september=True, october=True, november=True, december=True)
            session.add(default_moy)
            await session.commit()
            return default_moy.id
        return default_id

    async def _get_default_tod_id(self, session: AsyncSession) -> int:
        # Implement the logic to get or create a default CalendarToD record
        stmt = select(CalendarToD.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_tod = CalendarToD(time_10_00=True, time_12_00=True, time_14_00=True, time_16_00=True, time_18_00=True, time_20_00=True)
            session.add(default_tod)
            await session.commit()
            return default_tod.id
        return default_id
