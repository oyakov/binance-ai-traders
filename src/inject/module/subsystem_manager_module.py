from aiogram import Bot
from injector import Module, singleton, provider

from service.elastic.elastic_service import ElasticService
from subsystem.configuration_subsystem import ConfigurationSubsystem
from subsystem.openai_subsystem import OpenAiSubsystem
from subsystem.subsystem_manager import SubsystemManager


class SubsystemManagerModule(Module):

    @singleton
    @provider
    def provide_openai_subsystem(self, bot) -> OpenAiSubsystem:
        return OpenAiSubsystem(bot)

    @singleton
    @provider
    def provide_subsystem_manager(self, elastic_service: ElasticService) -> SubsystemManager:
        return SubsystemManager(elastic_service)

    @singleton
    @provider
    def provide_config_subsystem(self, bot: Bot, configuration_router) -> ConfigurationSubsystem:
        return ConfigurationSubsystem(bot, configuration_router)
