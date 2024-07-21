from injector import Module, singleton, provider

from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository


class RepositoryModule(Module):
    @singleton
    @provider
    def provide_calendar_repository(self) -> CalendarRepository:
        return CalendarRepository()

    @singleton
    @provider
    def provide_telegram_group_repository(self) -> TelegramGroupRepository:
        return TelegramGroupRepository()
