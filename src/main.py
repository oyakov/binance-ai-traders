import asyncio

from aiogram import Bot
from injector import Injector, Module, singleton, provider

from oam import log_config
# Subsystems
from oam.environment import MASTER_BOT_TOKEN, COROUTINE_DEBUG
from oam.log_config import LoggerSubsystem
from routers.actuator_router import actuator_router
from routers.binance_router import binance_router
from routers.configuration_router import configuration_router
from routers.new_message_router import new_message_router
from routers.openai_router import openai_router
from subsystem.actuator_subsystem import ActuatorSubsystem
from subsystem.binance_data_offload_subsystem import BinanceDataOffloadSubsystem
from subsystem.binance_subsystem import BinanceSubsystem
from subsystem.configuration_subsystem import ConfigurationSubsystem
from subsystem.database_subsystem import DatabaseSubsystem
from subsystem.openai_subsystem import OpenAiSubsystem
from subsystem.scheduler_subsystem import SchedulerSubsystem
from subsystem.slave_bot_subsystem import SlaveBotSubsystem
from subsystem.subsystem_manager import subsystem_manager, SubsystemManager

############################################################################
# logging - Logger subsystem is initialized first
logger = log_config.get_logger(__name__)


############################################################################


async def main(bot: Bot) -> None:
    """Initialize application subsystems concurrently"""
    subsystems = [
        LoggerSubsystem(),
        ActuatorSubsystem(bot, actuator_router, subsystem_manager),
        DatabaseSubsystem(),
        SchedulerSubsystem(bot, 1, new_message_router),
        OpenAiSubsystem(bot, openai_router),
        BinanceSubsystem(bot, binance_router),
        BinanceDataOffloadSubsystem(bot, configuration_router),
        ConfigurationSubsystem(bot, configuration_router)
    ]
    await subsystem_manager.initialize_subsystems(subsystems)

    # Start polling Telegram API
    bot_sub = SlaveBotSubsystem(bot, routers=[configuration_router, binance_router, new_message_router, openai_router])
    await subsystem_manager.initialize_subsystems([bot_sub])


class SubsystemManagerModule(Module):
    @singleton
    @provider
    def provide_subsystem_manager(self) -> SubsystemManager:
        return subsystem_manager


# Run the application
if __name__ == '__main__':
    logger.info(f"Debug coroutines: {COROUTINE_DEBUG}")
    injector = Injector([SubsystemManagerModule()])
    sub_manager = injector.get(SubsystemManager)
    master_bot_instance = Bot(token=MASTER_BOT_TOKEN)
    logger.info(f"Master Bot instantiated, running the main loop...")
    try:
        asyncio.run(
            main(bot=master_bot_instance),
            debug=COROUTINE_DEBUG)
    except(SystemExit, KeyboardInterrupt) as ex:
        logger.warning(f"Bot stopped with interrupt {ex}")
    except() as err:
        logger.error(f"Bot stopped with error {err}")
