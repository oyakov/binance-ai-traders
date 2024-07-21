from injector import Injector

from inject.module.bot_module import BotModule
from inject.module.subsystem_manager_module import SubsystemManagerModule

injector = Injector([
    SubsystemManagerModule(),
    BotModule()
])
