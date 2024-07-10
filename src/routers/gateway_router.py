from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import StatesGroup, State
from aiogram.types import Message

from src import log_config
from src.middleware.propagation_middleware import PropagationMiddleware
from src.routers.base_router import BaseRouter
from src.routers.configuration_router import configuration_router
from src.routers.new_message_router import new_message_router
from src.routers.openai_router import openai_router

gateway_router = BaseRouter()
gateway_router.include_router(new_message_router)
gateway_router.include_router(configuration_router)
gateway_router.include_router(openai_router)
gateway_router.message.outer_middleware(PropagationMiddleware())
gateway_router.callback_query.outer_middleware(PropagationMiddleware())
logger = log_config.get_logger(__name__)


class GatewayStates(StatesGroup):
    analyze_memssage = State()
    bypass_message = State()
    report_message = State()


@gateway_router.message()
async def analyze_message(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new message analysis. Chat ID {message.chat.id}")
    await state.set_state(GatewayStates.analyze_memssage)
    new_message_router.dispatch(message)

