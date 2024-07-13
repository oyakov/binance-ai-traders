from aiogram.fsm.state import StatesGroup, State

from oam import log_config
from middleware.chat_id_middleware import ChatIDMiddleware
from middleware.propagation_middleware import PropagationMiddleware
from routers.base_router import BaseRouter
from routers.binance_router import binance_router
from routers.configuration_router import configuration_router
from routers.new_message_router import new_message_router
from routers.openai_router import openai_router

logger = log_config.get_logger(__name__)


def configure_gateway_router(routers: list[BaseRouter]):
    """ Gateway router aggregates filtering middlewares and other routers"""
    logger.debug(f"Configuring gateway router {routers}")
    gateway_router = BaseRouter(
        services=[],
        repositories=[],
    )
    for router in routers:
        gateway_router.include_router(router)
    gateway_router.message.outer_middleware(PropagationMiddleware())
    gateway_router.callback_query.outer_middleware(PropagationMiddleware())
    gateway_router.message.middleware(ChatIDMiddleware())
    return gateway_router


class GatewayStates(StatesGroup):
    analyze_message = State()
