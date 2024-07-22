from aiogram import Bot
from injector import Module, provider, singleton, multiprovider

from routers.actuator_router import ActuatorRouter
from routers.base_router import BaseRouter
from routers.binance_router import BinanceRouter
from routers.configuration_router import ConfigurationRouter
from routers.new_message_router import NewMessageRouter
from routers.openai_router import OpenAIRouter
from service.elastic.elastic_service import ElasticService
from subsystem.subsystem import Subsystem
from subsystem.subsystem_manager import SubsystemManager
from subsystem.actuator_subsystem import ActuatorSubsystem
from subsystem.database_subsystem import DatabaseSubsystem
from subsystem.configuration_subsystem import ConfigurationSubsystem
from subsystem.logger_subsystem import LoggerSubsystem
from subsystem.scheduler_subsystem import SchedulerSubsystem
from subsystem.openai_subsystem import OpenAiSubsystem
from subsystem.binance_subsystem import BinanceSubsystem
from subsystem.binance_data_offload_subsystem import BinanceDataOffloadSubsystem
from subsystem.slave_bot_subsystem import SlaveBotSubsystem


class SubsystemManagerModule(Module):

    @singleton
    @provider
    def provide_actuator_subsystem(self,
                                   bot: Bot,
                                   actuator_router: ActuatorRouter) -> ActuatorSubsystem:
        return ActuatorSubsystem(bot, actuator_router)

    @singleton
    @provider
    def provide_database_subsystem(self) -> DatabaseSubsystem:
        return DatabaseSubsystem()

    @singleton
    @provider
    def provide_configuration_subsystem(self,
                                        bot: Bot,
                                        configuration_router: ConfigurationRouter) -> ConfigurationSubsystem:
        return ConfigurationSubsystem(bot, configuration_router)

    @singleton
    @provider
    def provide_logger_subsystem(self) -> LoggerSubsystem:
        return LoggerSubsystem()

    @singleton
    @provider
    def provide_scheduler_subsystem(self, bot: Bot, new_message_router: NewMessageRouter) -> SchedulerSubsystem:
        return SchedulerSubsystem(bot, 1, new_message_router)

    @singleton
    @provider
    def provide_openai_subsystem(self, bot: Bot, openai_router: OpenAIRouter) -> OpenAiSubsystem:
        return OpenAiSubsystem(bot, openai_router)

    @singleton
    @provider
    def provide_binance_subsystem(self, bot: Bot, binance_router: BinanceRouter) -> BinanceSubsystem:
        return BinanceSubsystem(bot, binance_router)

    @singleton
    @provider
    def provide_binance_data_offload_subsystem(self, bot: Bot) -> BinanceDataOffloadSubsystem:
        return BinanceDataOffloadSubsystem(bot)

    @singleton
    @provider
    def provide_slave_bot_subsystem(self,
                                    bot: Bot,
                                    routers: list[BaseRouter]
                                    ) -> SlaveBotSubsystem:
        return SlaveBotSubsystem(bot, routers=routers)

    @singleton
    @multiprovider
    def provide_subsystem_list(self,
                               actuator_subsystem: ActuatorSubsystem,
                               database_subsystem: DatabaseSubsystem,
                               configuration_subsystem: ConfigurationSubsystem,
                               logger_subsystem: LoggerSubsystem,
                               scheduler_subsystem: SchedulerSubsystem,
                               openai_subsystem: OpenAiSubsystem,
                               binance_subsystem: BinanceSubsystem,
                               binance_data_offload_subsystem: BinanceDataOffloadSubsystem,
                               ) -> list[Subsystem]:
        return [
            actuator_subsystem,
            database_subsystem,
            configuration_subsystem,
            logger_subsystem,
            scheduler_subsystem,
            openai_subsystem,
            binance_subsystem,
            binance_data_offload_subsystem,
        ]

    @singleton
    @provider
    def provide_subsystem_manager(
            self,
            elastic_service: ElasticService,
    ) -> SubsystemManager:
        # Inject a list of subsystems
        return SubsystemManager(elastic_service)
