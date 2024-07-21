from injector import Module, singleton, provider

from routers.actuator_router import ActuatorRouter
from routers.binance_router import BinanceRouter
from routers.configuration_router import ConfigurationRouter
from routers.new_message_router import NewMessageRouter
from routers.openai_router import OpenAIRouter
from service.elastic.elastic_service import ElasticService
from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from service.openai.openai_api_service import OpenAIAPIService


class RouterModule(Module):
    @singleton
    @provider
    def provide_actuator_router(self, elastic_service: ElasticService) -> ActuatorRouter:
        return ActuatorRouter(elastic_service)

    @singleton
    @provider
    def provide_binance_router(self, binance_service) -> BinanceRouter:
        return BinanceRouter(binance_service)

    @singleton
    @provider
    def provide_configuration_router(self, configuration_service, configuration_repository) -> ConfigurationRouter:
        return ConfigurationRouter(configuration_service, configuration_repository)

    @singleton
    @provider
    def provide_gateway_router(self, chat_id_middleware, propagation_middleware) -> GatewayRouter:
        return GatewayRouter(chat_id_middleware, propagation_middleware)

    @singleton
    @provider
    def provide_new_message_router(self, calendar_repository: CalendarRepository,
                                   telegram_group_repository: TelegramGroupRepository) -> NewMessageRouter:
        return NewMessageRouter(calendar_repository, telegram_group_repository)

    @singleton
    @provider
    def provide_openai_router(self, openai_service: OpenAIAPIService) -> OpenAIRouter:
        return OpenAIRouter(openai_service)
