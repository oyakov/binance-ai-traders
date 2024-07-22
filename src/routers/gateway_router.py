from aiogram.fsm.state import StatesGroup, State
from injector import inject

from middleware.chat_id_middleware import ChatIDMiddleware
from middleware.propagation_middleware import PropagationMiddleware
from oam import log_config
from routers.base_router import BaseRouter

logger = log_config.get_logger(__name__)


def configure_gateway_router(routers: list[BaseRouter]):
    """ Gateway router aggregates filtering middlewares and other routers"""
    logger.debug(f"Configuring gateway router {routers}")
    gateway_router = GatewayRouter(routers)
    return gateway_router


class GatewayStates(StatesGroup):
    analyze_message = State()


class GatewayRouter(BaseRouter):
    @inject
    def __init__(self, routers: list[BaseRouter]):
        super().__init__([], [])
        for router in routers:
            self.include_router(router)
        self.message.outer_middleware(PropagationMiddleware())
        self.callback_query.outer_middleware(PropagationMiddleware())
        self.message.middleware(ChatIDMiddleware())

    def initialize(self, subsystem_manager):
        self.subsystem_manager = subsystem_manager
