from injector import Injector

from inject.module.bot_module import BotModule
from inject.module.repository_module import RepositoryModule
from inject.module.router_module import RouterModule
from inject.module.services_subsystem import ServiceProviderModule
from inject.module.subsystem_manager_module import SubsystemManagerModule

injector = Injector([
    SubsystemManagerModule(),
    BotModule(),
    RepositoryModule(),
    ServiceProviderModule(),
    RouterModule(),
])
