from injector import Module, singleton, provider

from db.repository.calendar_repository import CalendarRepository
from db.repository.klines_repository import KlinesRepository
from db.repository.macd_repository import MACDRepository
from db.repository.order_book_repository import OrderBookRepository
from db.repository.order_repository import OrderRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from db.repository.ticker_repository import TickerRepository


class RepositoryModule(Module):
    @singleton
    @provider
    def provide_calendar_repository(self) -> CalendarRepository:
        return CalendarRepository()

    @singleton
    @provider
    def provide_telegram_group_repository(self) -> TelegramGroupRepository:
        return TelegramGroupRepository()

    @singleton
    @provider
    def provide_ticker_repository(self) -> TickerRepository:
        return TickerRepository()

    @singleton
    @provider
    def provide_order_book_repository(self) -> OrderBookRepository:
        return OrderBookRepository()

    @singleton
    @provider
    def provide_klines_repository(self) -> KlinesRepository:
        return KlinesRepository()

    @singleton
    @provider
    def provide_macd_repository(self) -> MACDRepository:
        return MACDRepository()

    @singleton
    @provider
    def provide_order_repository(self) -> OrderRepository:
        return OrderRepository()
