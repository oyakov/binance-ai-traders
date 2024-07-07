from aiogram.fsm.storage.base import BaseStorage, StorageKey, StateType
from sqlalchemy.future import select

from src import log_config
from src.db.config import get_db
from src.db.model.fsm_state import FSMState

logger = log_config.get_logger(__name__)


class SQLAlchemyStorage(BaseStorage):

    def __init__(self):
        self.session_maker = get_db

    async def _get_fsm_state(self, key: StorageKey):
        async with self.session_maker() as session:
            stmt = select(FSMState).where(FSMState.user_id == key.user_id)
            result = await session.execute(stmt)
            return result.scalar_one_or_none()

    async def set_state(self, key: StorageKey, state: StateType = None) -> None:
        async with self.session_maker() as session:
            async with session.begin():
                fsm_state = await self._get_fsm_state(key)
                if fsm_state:
                    fsm_state.state = state
                else:
                    session.add(FSMState(user_id=key.user_id, state=state))
                await session.commit()

    async def get_state(self, key: StorageKey) -> str | None:
        fsm_state = await self._get_fsm_state(key)
        return fsm_state.state if fsm_state else None

    async def set_data(self, key: StorageKey, data: dict[str, any]) -> None:
        async with self.session_maker() as session:
            async with session.begin():
                fsm_state = await self._get_fsm_state(key)
                if fsm_state:
                    fsm_state.data = data
                else:
                    session.add(FSMState(user_id=key.user_id, data=data))
                await session.commit()

    async def get_data(self, key: StorageKey) -> dict[str, any]:
        fsm_state = await self._get_fsm_state(key)
        return fsm_state.data if fsm_state else None

    async def clear_state(self, key: StorageKey):
        async with self.session_maker() as session:
            async with session.begin():
                fsm_state = await self._get_fsm_state(key)
                if fsm_state:
                    await session.delete(fsm_state)
                    await session.commit()

    async def close(self) -> None:
        await self.session_maker.close_all()
