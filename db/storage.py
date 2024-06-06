from db.config import *
from aiogram.fsm.storage.base import BaseStorage, StorageKey, StateType, StateData
from sqlalchemy.future import select


class SQLAlchemyStorage(BaseStorage):

    def __init__(self, session_maker):
        self.session_maker = session_maker

    async def set_state(self, key: StorageKey, state: StateType = None):
        async with self.session_maker() as session:
            async with session.begin():
                stmt = select(FSMState).where(FSMState.user_id == key.user_id)
                result = await session.execute(stmt)
                fsm_state = result.scalar_one_or_none()
                if fsm_state:
                    fsm_state.state = state
                else:
                    new_state = FSMState(user_id=key.user_id, state=state)
                    session.add(new_state)
                await session.commit()

    async def get_state(self, key: StorageKey):
        async with self.session_maker() as session:
            stmt = select(FSMState.state).where(FSMState.user_id == key.user_id)
            result = await session.execute(stmt)
            state = result.scalar_one_or_none()
            return state

    async def set_data(self, key: StorageKey, data: StateData):
        async with self.session_maker() as session:
            async with session.begin():
                stmt = select(FSMState).where(FSMState.user_id == key.user_id)
                result = await session.execute(stmt)
                fsm_state = result.scalar_one_or_none()
                if fsm_state:
                    fsm_state.data = data
                else:
                    new_state = FSMState(user_id=key.user_id, data=data)
                    session.add(new_state)
                await session.commit()

    async def get_data(self, key: StorageKey):
        async with self.session_maker() as session:
            stmt = select(FSMState.data).where(FSMState.user_id == key.user_id)
            result = await session.execute(stmt)
            data = result.scalar_one_or_none()
            return data

    async def clear_state(self, key: StorageKey):
        async with self.session_maker() as session:
            async with session.begin():
                stmt = select(FSMState).where(FSMState.user_id == key.user_id)
                result = await session.execute(stmt)
                fsm_state = result.scalar_one_or_none()
                if fsm_state:
                    await session.delete(fsm_state)
                    await session.commit()
