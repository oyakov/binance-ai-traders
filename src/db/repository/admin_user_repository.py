from sqlalchemy.orm import Session

from src.db.model.admin_user import AdminUser


class AdminUserRepository:
    def __init__(self, session: Session):
        self.session = session

    def get_by_id(self, id: int) -> AdminUser:
        return self.session.query(AdminUser).filter(AdminUser.id == id).first()

    def get_by_tg(self, tg: str) -> AdminUser:
        return self.session.query(AdminUser).filter(AdminUser.telegram_username == tg).first()

    def create(self, admin_user: AdminUser) -> AdminUser:
        self.session.add(admin_user)
        self.session.commit()
        return admin_user

    def update(self, admin_user: AdminUser) -> AdminUser:
        self.session.commit()
        return admin_user

    def delete(self, admin_user: AdminUser) -> None:
        self.session.delete(admin_user)
        self.session.commit()
