from injector import Module, singleton, provider, multiprovider

from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from routers.actuator_router import ActuatorRouter
from routers.base_router import BaseRouter
from routers.binance_router import BinanceRouter
from routers.configuration_router import ConfigurationRouter
from routers.gateway_router import GatewayRouter
from routers.new_message_router import NewMessageRouter
from routers.openai_router import OpenAIRouter
from service.crypto.binance.binance_service import BinanceService
from service.openai.openai_api_service import OpenAIAPIService


class RouterModule(Module):
    @singleton
    @provider
    def provide_actuator_router(self) -> ActuatorRouter:
        return ActuatorRouter()

    @singleton
    @provider
    def provide_binance_router(self, binance_service: BinanceService) -> BinanceRouter:
        return BinanceRouter(binance_service)

    @singleton
    @provider
    def provide_configuration_router(self, tg_group_repository: TelegramGroupRepository) -> ConfigurationRouter:
        return ConfigurationRouter(tg_group_repository)

    @singleton
    @provider
    def provide_new_message_router(self, calendar_repository: CalendarRepository,
                                   telegram_group_repository: TelegramGroupRepository) -> NewMessageRouter:
        return NewMessageRouter(calendar_repository, telegram_group_repository)

    @singleton
    @provider
    def provide_openai_router(self, openai_service: OpenAIAPIService) -> OpenAIRouter:
        return OpenAIRouter(openai_service)

    @singleton
    @multiprovider
    def provide_router_list(self,
                            actuator_router: ActuatorRouter,
                            binance_router: BinanceRouter,
                            configuration_router: ConfigurationRouter,
                            new_message_router: NewMessageRouter,
                            openai_router: OpenAIRouter) -> list[BaseRouter]:
        return [actuator_router,
                binance_router,
                configuration_router,
                new_message_router,
                openai_router]

    @singleton
    @provider
    def provide_gateway_router(self, routers: list[BaseRouter]) -> GatewayRouter:
        return GatewayRouter(routers)
