from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from db.repository.telegram_group_repository import TelegramGroupRepository
from markup.inline.keyboards.configuration_keyboards import config_action_selector, config_group_action_selector, \
    config_misc_action_selector, config_back
from markup.reply.main_menu_reply_keyboard import SETTINGS, create_reply_kbd
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter

configuration_router = BaseRouter(
    services=[{
        'name': 'tg_group_repository',
        'service_class': TelegramGroupRepository
    }, ],
    repositories=[],
)
logger = log_config.get_logger(__name__)


class ConfigurationStates(StatesGroup):
    config_groups_list = State()
    select_configuration = State()
    config_groups = State()
    config_misc = State()
    detect_chat_id = State()


@configuration_router.message(Command("config"))
@configuration_router.message(F.text == SETTINGS)
async def command_start(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new configuration dialog. Chat ID {message.chat.id}")

    await state.set_state(ConfigurationStates.select_configuration)

    inline_kb = config_action_selector()
    await message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
    await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.select_configuration)
async def process_configuration_selection(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Configuration option selected {code}")

    if code == "config_groups":
        await state.set_state(ConfigurationStates.config_groups)
        inline_kb = config_group_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку групп: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    elif code == "config_misc":
        await state.set_state(ConfigurationStates.config_misc)
        inline_kb = config_misc_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.config_groups)
async def process_configuration_groups(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Configuration option selected {code}")

    if code == "config_groups_add":
        await state.set_state(ConfigurationStates.detect_chat_id)
        inline_kb = config_back()
        await callback_query.message.reply(text=f"Перешлите любое сообщение из вашего канала в этот диалог: ",
                                           reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    elif code == "config_groups_list":
        await state.set_state(ConfigurationStates.config_groups_list)
        inline_kb = config_back()
        await callback_query.message.reply(text=f"Список групп: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    elif code == "config_back":
        await state.set_state(ConfigurationStates.select_configuration)
        inline_kb = config_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@configuration_router.message(ConfigurationStates.detect_chat_id)
async def process_chat_id_detection(message: Message, state: FSMContext,
                                    tg_group_repository: TelegramGroupRepository) -> None:
    # Check if the message is forwarded
    if message.forward_from_chat:
        # Get the chat id of the original chat
        chat_id = message.forward_from_chat.id
        logger.info(f"The message was forwarded from the chat with id: {chat_id}")
        await state.set_state(ConfigurationStates.config_groups)
        # Add the chat id to the database
        await tg_group_repository.create_telegram_group(
            str(chat_id),                # Chat ID
            message.from_user.username,  # User who forwarded the message is the initial owner
            message.chat.username,       # Display name of the chat
            message.chat.username)       # T.me URL of the chat

        inline_kb = config_group_action_selector()
        await message.reply(text=f"Группа успешно добавлена. Выберите настройку групп ", reply_markup=inline_kb)
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    else:
        inline_kb = config_back()
        await message.reply(text=f"""Не получилось добавить группу. Добавьте бота в канал администратором и перешлите"""
                                 """любое сообщение из вашего канала в этот диалог: """,
                            reply_markup=inline_kb)
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.detect_chat_id)
async def process_chat_id_detection_cq(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Option selected {code}")
    if code == "config_back":
        await state.set_state(ConfigurationStates.config_groups)
        inline_kb = config_group_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку групп: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@configuration_router.callback_query(ConfigurationStates.config_misc)
async def process_configuration_misc(callback_query: CallbackQuery, state: FSMContext) -> None:
    code = callback_query.data
    logger.info(f"Configuration option selected {code}")

    if code == "config_back":
        await state.set_state(ConfigurationStates.select_configuration)
        inline_kb = config_action_selector()
        await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=inline_kb)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
