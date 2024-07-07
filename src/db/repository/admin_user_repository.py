from src.db.config import get_db
from src.db.model.admin_user import AdminUser


class AdminUserRepository:
    def __init__(self):
        self.session_maker = get_db()

    async def get_by_id(self, id_no: int) -> AdminUser:
        async with self.session_maker() as session:
            return session.query(AdminUser).filter(AdminUser.id == id_no).first()

    async def get_by_tg(self, tg: str) -> AdminUser:
        async with self.session_maker() as session:
            return session.query(AdminUser).filter(AdminUser.telegram_username == tg).first()

    async def create(self, admin_user: AdminUser) -> AdminUser:
        async with self.session_maker() as session:
            session.add(admin_user)
            session.commit()
            return admin_user

    async def update(self, admin_user: AdminUser) -> AdminUser:
        async with self.session_maker() as session:
            session.add(admin_user)
            session.commit()
            return admin_user

    async def delete(self, admin_user: AdminUser) -> None:
        async with self.session_maker() as session:
            session.delete(admin_user)
            session.commit()
            return None
