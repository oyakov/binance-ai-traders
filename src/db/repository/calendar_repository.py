from sqlalchemy import text, select as sel
from sqlalchemy.future import select

from db.config import *
from db.model.calendars import CalendarData, CalendarDoM, CalendarDoW, CalendarMoY, CalendarToD
from markup.inline.types import DateSelector

logger = log_config.get_logger(__name__)


class CalendarRepository:
    def __init__(self):
        self.session_maker = get_db

    async def create_calendar_data(self,
                                   chat_id: str,
                                   username: str,
                                   data: str = None,
                                   dow_selectors: list[DateSelector] = None,
                                   dom_selectors: list[DateSelector] = None,
                                   moy_selectors: list[DateSelector] = None,
                                   tod_selectors: list[DateSelector] = None):
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
                chat_id=chat_id,
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

    async def load_calendar_data_all(self) -> list:
        """
        Load all periodic message schedules from the database
        """
        async with self.session_maker() as session:
            async with session.begin():
                stmt = text('''
                SELECT 
                    cd.username as username,
                    cd.data as data,
                    cd.chat_id as chat_id,                  
                    cd.dow_id as dow_id,
                    cd.dom_id as dom_id,
                    cd.moy_id as moy_id,
                    cd.tod_id as tod_id
                from calendar_data cd''')
                calendar_entries = await session.execute(stmt)
                return calendar_entries.fetchall()

    async def load_calendars(self, dow_id: int, dom_id: int, moy_id: int, tod_id: int):
        """
        Load all the calendars related to the periodic message by ids
        """
        async with self.session_maker() as session:
            async with session.begin():
                logger.info("load calendars")
                stmt = sel(CalendarDoW).where(CalendarDoW.id == dow_id)
                calendar_dow_entries = await session.execute(stmt)
                calendar_dow_entries = calendar_dow_entries.fetchall()

                stmt = sel(CalendarDoM).where(CalendarDoM.id == dom_id)
                calendar_dom_entries = await session.execute(stmt)
                calendar_dom_entries = calendar_dom_entries.fetchall()

                stmt = sel(CalendarMoY).where(CalendarMoY.id == moy_id)
                calendar_moy_entries = await session.execute(stmt)
                calendar_moy_entries = calendar_moy_entries.fetchall()

                stmt = sel(CalendarToD).where(CalendarToD.id == tod_id)
                calendar_tod_entries = await session.execute(stmt)
                calendar_tod_entries = calendar_tod_entries.fetchall()

                return calendar_dow_entries, calendar_dom_entries, calendar_moy_entries, calendar_tod_entries


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
