import asyncio
import json

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
from service.messaging.kafka_service import KafkaMessagingService, TradingCommand
from subsystem.subsystem_manager import SubsystemManager

logger = log_config.get_logger(__name__)


class ActuatorStates(StatesGroup):
    select_option = State()
    health_data = State()


class ActuatorRouter(BaseRouter):

    @inject
    def __init__(self, kafka_service: KafkaMessagingService):
        super().__init__([
            {"name": "kafka_service", "service_instance": kafka_service},
        ], [])
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

    async def selected_option_callback(
        self,
        callback_query: CallbackQuery,
        state: FSMContext,
        kafka_service: KafkaMessagingService,
    ) -> None:
        logger.info(f"Selected option callback. Chat ID {callback_query.message.chat.id}")
        if callback_query.data == "subsystem_health":
            await state.set_state(ActuatorStates.health_data)
            # Collect health data from Subsystem manager
            health_data = self.subsystem_manager.collect_health_data()
            # TODO: Update health data in db
            await callback_query.message.reply(text="Subsystem health data collected",
                                               reply_markup=actuator_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "start_trading":
            correlation_id = await kafka_service.send_command(TradingCommand(action="START_TRADING"))
            await callback_query.message.reply(
                text=(
                    "Команда на запуск торговли отправлена.\n"
                    f"Correlation ID: `{correlation_id}`"
                ),
                parse_mode="Markdown",
                reply_markup=actuator_action_selector(),
            )
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "stop_trading":
            correlation_id = await kafka_service.send_command(TradingCommand(action="STOP_TRADING"))
            await callback_query.message.reply(
                text=(
                    "Команда на остановку торговли отправлена.\n"
                    f"Correlation ID: `{correlation_id}`"
                ),
                parse_mode="Markdown",
                reply_markup=actuator_action_selector(),
            )
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "request_status":
            try:
                response = await kafka_service.request_status("TRADING_STATUS", timeout=15.0)
                try:
                    payload_preview = json.dumps(response.payload, indent=2, ensure_ascii=False)
                except (TypeError, ValueError):
                    payload_preview = str(response.payload)
                message_text = (
                    "Текущее состояние торговой системы:\n"
                    f"*Status*: `{response.status}`\n"
                    f"*Correlation ID*: `{response.correlation_id}`\n"
                    f"*Payload*:```json\n{payload_preview}\n```"
                )
            except asyncio.TimeoutError:
                message_text = (
                    "Не удалось получить статус торговой системы вовремя.\n"
                    "Попробуйте повторить запрос позже."
                )
            await callback_query.message.reply(
                text=message_text,
                parse_mode="Markdown",
                reply_markup=actuator_action_selector(),
            )
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
