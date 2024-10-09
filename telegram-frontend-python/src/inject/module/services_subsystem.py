from injector import Module, singleton, provider

from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService
from service.elastic.elastic_service import ElasticService
from service.openai.openai_api_service import OpenAIAPIService
from service.os.filesystem_service import FilesystemService
from service.telegram_service import TelegramService


class ServiceProviderModule(Module):
    @singleton
    @provider
    def provide_binance_service(self) -> BinanceService:
        return BinanceService()

    @singleton
    @provider
    def provide_elastic_service(self) -> ElasticService:
        return ElasticService()

    @singleton
    @provider
    def provide_openai_service(self) -> OpenAIAPIService:
        return OpenAIAPIService()

    @singleton
    @provider
    def provide_telegram_service(self) -> TelegramService:
        return TelegramService()

    @singleton
    @provider
    def provide_indicator_service(self) -> IndicatorService:
        return IndicatorService()

    @singleton
    @provider
    def provide_filesystem_service(self) -> FilesystemService:
        return FilesystemService()