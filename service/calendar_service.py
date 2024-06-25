from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import sessionmaker
from sqlalchemy import update
from db.config import Base
from markup.inline.types import DateSelector
from db.model.calendar_data import CalendarData
from db.model.calendar_dom import CalendarDoM
from db.model.calendar_dow import CalendarDoW
from db.model.calendar_moy import CalendarMoY
from db.model.calendar_tod import CalendarToD
from db.config import *

import logging
logger = logging.getLogger(__name__)

class CalendarService:
    def __init__(self):
        self.session_maker = get_db

    async def create_calendar_data(self, username: str, data: str = None, dow_selectors: list[DateSelector] = None, dom_selectors: list[DateSelector] = None, moy_selectors: list[DateSelector] = None, tod_selectors: list[DateSelector] = None):
        async with self.session_maker() as session:
            logger.info(f"Session {session}")
            # Set default values if missing
            dow_id = await self._get_or_create_dow_id(session, dow_selectors)
            logger.info(f"DoW entry created, id {dow_id}")
            dom_id = await self._get_or_create_dom_id(session, dom_selectors)
            logger.info(f"DoM entry created, id {dom_id}")
            moy_id = await self._get_or_create_moy_id(session, moy_selectors)
            logger.info(f"MoY entry created, id {moy_id}")
            tod_id = await self._get_or_create_tod_id(session, tod_selectors)
            logger.info(f"ToD entry created, id {tod_id}")

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

    async def update_calendar_data(self, record_id: int, username: str = None, data: str = None, dow_selectors: list[DateSelector] = None, dom_selectors: list[DateSelector] = None, moy_selectors: list[DateSelector] = None, tod_selectors: list[DateSelector] = None):
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
                    if dow_selectors:
                        record.dow_id = await self._get_or_create_dow_id(session, dow_selectors)
                    if dom_selectors:
                        record.dom_id = await self._get_or_create_dom_id(session, dom_selectors)
                    if moy_selectors:
                        record.moy_id = await self._get_or_create_moy_id(session, moy_selectors)
                    if tod_selectors:
                        record.tod_id = await self._get_or_create_tod_id(session, tod_selectors)

                    await session.commit()

    async def _get_or_create_dow_id(self, session: AsyncSession, selectors: list[DateSelector]) -> int:
        if not selectors:
            return await self._get_default_dow_id(session)
        dow = CalendarDoW(**{selector.key: selector.enabled for selector in selectors})
        session.add(dow)
        await session.commit()
        return await dow.awaitable_attrs.id

    async def _get_or_create_dom_id(self, session: AsyncSession, selectors: list[DateSelector]) -> int:
        if not selectors:
            return await self._get_default_dom_id(session)
        dom = CalendarDoM(**{f'day_{selector.key}': selector.enabled for selector in selectors})
        session.add(dom)
        await session.commit()
        return await dom.awaitable_attrs.id

    async def _get_or_create_moy_id(self, session: AsyncSession, selectors: list[DateSelector]) -> int:
        if not selectors:
            return await self._get_default_moy_id(session)
        moy = CalendarMoY(**{selector.key: selector.enabled for selector in selectors})
        session.add(moy)
        await session.commit()
        return await moy.awaitable_attrs.id

    async def _get_or_create_tod_id(self, session: AsyncSession, selectors: list[DateSelector]) -> int:
        if not selectors:
            return await self._get_default_tod_id(session)
        tod = CalendarToD(**{f'time_{selector.key}': selector.enabled for selector in selectors})
        session.add(tod)
        await session.commit()
        return await tod.awaitable_attrs.id

    async def _get_default_dow_id(self, session: AsyncSession) -> int:
        stmt = select(CalendarDoW.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_dow = CalendarDoW(monday=True, tuesday=True, wednesday=True, thursday=True, friday=True, saturday=True, sunday=True)
            session.add(default_dow)
            await session.commit()
            return await default_dow.awaitable_attrs.id
        return default_id

    async def _get_default_dom_id(self, session: AsyncSession) -> int:
        stmt = select(CalendarDoM.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_dom = CalendarDoM(day_1=True, day_2=True, day_3=True, day_4=True, day_5=True, day_6=True, day_7=True, day_8=True, day_9=True, day_10=True,
                                      day_11=True, day_12=True, day_13=True, day_14=True, day_15=True, day_16=True, day_17=True, day_18=True, day_19=True, day_20=True,
                                      day_21=True, day_22=True, day_23=True, day_24=True, day_25=True, day_26=True, day_27=True, day_28=True, day_29=True, day_30=True, day_31=True)
            session.add(default_dom)
            await session.commit()
            return await default_dom.awaitable_attrs.id
        return default_id

    async def _get_default_moy_id(self, session: AsyncSession) -> int:
        stmt = select(CalendarMoY.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_moy = CalendarMoY(january=True, february=True, march=True, april=True, may=True, june=True, july=True, august=True, september=True, october=True, november=True, december=True)
            session.add(default_moy)
            await session.commit()
            return await default_moy.awaitable_attrs.id
        return default_id

    async def _get_default_tod_id(self, session: AsyncSession) -> int:
        stmt = select(CalendarToD.id).limit(1)
        result = await session.execute(stmt)
        default_id = result.scalar_one_or_none()
        if default_id is None:
            default_tod = CalendarToD(time_10_00=True, time_12_00=True, time_14_00=True, time_16_00=True, time_18_00=True, time_20_00=True)
            session.add(default_tod)
            await session.commit()
            return await default_tod.awaitable_attrs.id
        return default_id
