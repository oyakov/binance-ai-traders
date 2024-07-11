from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import StatesGroup, State
from aiogram.types import Message

from src import log_config
from src.middleware.chat_id_middleware import ChatIDMiddleware
from src.middleware.propagation_middleware import PropagationMiddleware
from src.routers.base_router import BaseRouter
from src.routers.binance_router import binance_router
from src.routers.configuration_router import configuration_router
from src.routers.new_message_router import new_message_router
from src.routers.openai_router import openai_router

# Gateway router aggregates filtering middlewares and other routers
gateway_router = BaseRouter()
gateway_router.include_router(new_message_router)
gateway_router.include_router(configuration_router)
gateway_router.include_router(openai_router)
gateway_router.include_router(binance_router)
gateway_router.message.outer_middleware(PropagationMiddleware())
gateway_router.callback_query.outer_middleware(PropagationMiddleware())
gateway_router.message.middleware(ChatIDMiddleware())
logger = log_config.get_logger(__name__)


class GatewayStates(StatesGroup):
    analyze_message = State()

