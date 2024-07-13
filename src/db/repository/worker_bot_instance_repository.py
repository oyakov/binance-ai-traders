from db.config import get_db
from db.model.worker_bot_instance import WorkerBotInstance


class WorkerBotInstanceRepository:

    def __init__(self):
        self.session_maker = get_db()

    async def create(self, worker_bot_instance: WorkerBotInstance):
        async with self.session_maker() as session:
            session.add(worker_bot_instance)
            session.commit()
            return worker_bot_instance

    async def get_by_id(self, id: int):
        async with self.session_maker() as session:
            return session.query(WorkerBotInstance).filter(WorkerBotInstance.id == id).first()

    async def update(self, worker_bot_instance: WorkerBotInstance):
        async with self.session_maker() as session:
            session.add(worker_bot_instance)
            session.commit()
            return worker_bot_instance

    async def delete(self, id: int):
        async with self.session_maker() as session:
            worker_bot_instance = session.query(WorkerBotInstance).filter(WorkerBotInstance.id == id).first()
            if worker_bot_instance:
                session.delete(worker_bot_instance)
                session.commit()
                return worker_bot_instance
            return None
