from src import log_config

from aiogram import F, Router
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from src.markup.inline.keyboards.configuration_keyboards import config_action_selector, config_group_action_selector, \
    config_misc_action_selector
from src.markup.reply.main_menu_reply_keyboard import SETTINGS, create_reply_kbd

configuration_router = Router()


logger = log_config.get_logger(__name__)

delimiter: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'


class ConfigurationStates(StatesGroup):
    select_configuration = State()
    config_groups = State()
    config_misc = State()


@configuration_router.message(Command("config"))
@configuration_router.message(F.text == SETTINGS)
async def command_start(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new configuration dialog. Chat ID {message.chat.id}")

    await state.set_state(ConfigurationStates.select_configuration)

    inline_kb = config_action_selector()
    await message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
    await message.answer(text=delimiter, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.select_configuration)
async def process_configuration_selection(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Configuration option selected {code}")

    if code == "config_groups":
        await state.set_state(ConfigurationStates.config_groups)
        inline_kb = config_group_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку групп: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=delimiter, reply_markup=create_reply_kbd())
    elif code == "config_misc":
        await state.set_state(ConfigurationStates.config_misc)
        inline_kb = config_misc_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=delimiter, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.config_groups)
async def process_configuration_selection(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Configuration option selected {code}")

    if code == "config_groups_add":
        await state.set_state(ConfigurationStates.config_groups)
        inline_kb = config_group_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку групп: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=delimiter, reply_markup=create_reply_kbd())
    elif code == "config_groups_list":
        await state.set_state(ConfigurationStates.config_misc)
        inline_kb = config_misc_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=delimiter, reply_markup=create_reply_kbd())