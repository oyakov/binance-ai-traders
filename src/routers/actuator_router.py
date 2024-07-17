from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.types import Message, CallbackQuery

from markup.inline.keyboards.actuator_keyboards import actuator_action_selector
from markup.reply.main_menu_reply_keyboard import create_reply_kbd, NEW_MESSAGE
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter
from service.elastic.elastic_service import ElasticService

logger = log_config.get_logger(__name__)

actuator_router = BaseRouter(services=[
    {
        'name': 'elastic',
        'service_class': ElasticService
    },
], repositories=[])


class ActuatorStates:
    select_option = "select_option"
    health_data = "health_data"

@actuator_router.message(Command("actuator"))
@actuator_router.message(F.text == NEW_MESSAGE)
async def command_start(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new actuator dialog. Chat ID {message.chat.id}")
    await state.set_state(ActuatorStates.select_option)
    await message.reply(text="Выберите опцию: ", reply_markup=actuator_action_selector())
    await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@actuator_router.callback_query(ActuatorStates.select_option)
async def selected_option_callback(callback_query: CallbackQuery, state: FSMContext, elastic: ElasticService) -> None:
    logger.info(f"Selected option callback. Chat ID {callback_query.message.chat.id}")
    if callback_query.data == "subsystem_health":
        await state.set_state(ActuatorStates.health_data)
        await elastic.collect_health_data()
        await callback_query.message.reply(text="Subsystem health data collected", reply_markup=actuator_action_selector())
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
