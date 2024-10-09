from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import Message, CallbackQuery
from injector import inject

from markup.inline.keyboards.actuator_keyboards import actuator_action_selector
from markup.reply.main_menu_reply_keyboard import create_reply_kbd, MONITORING
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter
from subsystem.subsystem_manager import SubsystemManager

logger = log_config.get_logger(__name__)


class ActuatorStates(StatesGroup):
    select_option = State()
    health_data = State()


class ActuatorRouter(BaseRouter):

    @inject
    def __init__(self):
        super().__init__([], [])
        self.subsystem_manager = SubsystemManager | None
        self.message(Command("actuator"))(self.command_start)
        self.message(F.text == MONITORING)(self.command_start)
        self.callback_query(ActuatorStates.select_option)(self.selected_option_callback)

    def initialize(self, subsystem_manager: SubsystemManager):
        self.subsystem_manager = subsystem_manager

    async def command_start(self, message: Message, state: FSMContext) -> None:
        logger.info(f"Starting new actuator dialog. Chat ID {message.chat.id}")
        await state.set_state(ActuatorStates.select_option)
        await message.reply(text="Выберите опцию: ", reply_markup=actuator_action_selector())
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def selected_option_callback(self, callback_query: CallbackQuery, state: FSMContext) -> None:
        logger.info(f"Selected option callback. Chat ID {callback_query.message.chat.id}")
        if callback_query.data == "subsystem_health":
            await state.set_state(ActuatorStates.health_data)
            # Collect health data from Subsystem manager
            health_data = self.subsystem_manager.collect_health_data()
            # TODO: Update health data in db
            await callback_query.message.reply(text="Subsystem health data collected",
                                               reply_markup=actuator_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
