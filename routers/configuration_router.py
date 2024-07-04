import logging

from aiogram import F, Router
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from markup.reply.main_menu_reply_keyboard import SETTINGS, create_reply_kbd

configuration_router = Router()


logger = logging.getLogger(__name__)


class ConfigurationStates(StatesGroup):
    select_configuration = State()


@configuration_router.message(Command("new_message"))
@configuration_router.message(F.text == SETTINGS)
async def command_start(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new configuration dialog. Chat ID {message.chat.id}")

    await state.set_state(ConfigurationStates.select_configuration)

    await message.answer(
        "Under construction",
        reply_markup=create_reply_kbd()
    )
