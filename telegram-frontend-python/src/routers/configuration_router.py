from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)
from injector import inject

from db.repository.telegram_group_repository import TelegramGroupRepository
from markup.inline.keyboards.configuration_keyboards import config_action_selector, config_group_action_selector, \
    config_misc_action_selector, config_back
from markup.reply.main_menu_reply_keyboard import SETTINGS, create_reply_kbd
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter

logger = log_config.get_logger(__name__)


class ConfigurationStates(StatesGroup):
    config_groups_list = State()
    select_configuration = State()
    config_groups = State()
    config_misc = State()
    detect_chat_id = State()


class ConfigurationRouter(BaseRouter):

    @inject
    def __init__(self, tg_group_repository: TelegramGroupRepository):
        super().__init__([], [])
        self.tg_group_repository = tg_group_repository
        self.message(Command("config"))(self.command_start)
        self.message(F.text == SETTINGS)(self.command_start)
        self.callback_query(ConfigurationStates.select_configuration)(self.process_configuration_selection)
        self.callback_query(ConfigurationStates.config_groups)(self.process_configuration_groups)
        self.callback_query(ConfigurationStates.config_misc)(self.process_configuration_misc)
        self.callback_query(ConfigurationStates.config_groups)(self.process_configuration_groups)
        self.message(ConfigurationStates.detect_chat_id)(self.process_chat_id_detection)
        self.callback_query(ConfigurationStates.detect_chat_id)(self.process_chat_id_detection_cq)

    def initialize(self, subsystem_manager):
        self.subsystem_manager = subsystem_manager

    async def command_start(self, message: Message, state: FSMContext) -> None:
        logger.info(f"Starting new configuration dialog. Chat ID {message.chat.id}")

        await state.set_state(ConfigurationStates.select_configuration)
        await message.reply(text=f"Выберите настройку: ",
                            reply_markup=config_action_selector())
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_configuration_selection(self, callback_query: CallbackQuery, state: FSMContext) -> None:
        code = callback_query.data
        logger.info(f"Configuration option selected {code}")

        if code == "config_groups":
            await state.set_state(ConfigurationStates.config_groups)
            await callback_query.message.reply(text=f"Выберите настройку групп: ",
                                               reply_markup=config_group_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif code == "config_misc":
            await state.set_state(ConfigurationStates.config_misc)
            await callback_query.message.reply(text=f"Выберите настройку: ",
                                               reply_markup=config_misc_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_configuration_groups(self, callback_query: CallbackQuery, state: FSMContext) -> None:
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
            await callback_query.message.reply(text=f"Список групп: ",
                                               reply_markup=inline_kb)
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif code == "config_back":
            await state.set_state(ConfigurationStates.select_configuration)
            inline_kb = config_action_selector()
            await callback_query.message.reply(text=f"Выберите настройку: ",
                                               reply_markup=inline_kb)
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_chat_id_detection(self,
                                        message: Message,
                                        state: FSMContext) -> None:
        # Check if the message is forwarded
        if message.forward_from_chat:
            # Get the chat id of the original chat
            chat_id = message.forward_from_chat.id
            logger.info(f"The message was forwarded from the chat with id: {chat_id}")
            await state.set_state(ConfigurationStates.config_groups)
            # Add the chat id to the database
            await self.tg_group_repository.create_telegram_group(
                str(chat_id),  # Chat ID
                message.from_user.username,  # User who forwarded the message is the initial owner
                message.chat.username,  # Display name of the chat
                message.chat.username)  # T.me URL of the chat
            await message.reply(text=f"Группа успешно добавлена. Выберите настройку групп ",
                                reply_markup=config_group_action_selector())
            await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        else:
            await message.reply(
                text=f"""Не получилось добавить группу. Добавьте бота в канал администратором и перешлите"""
                     """любое сообщение из вашего канала в этот диалог: """,
                reply_markup=config_back())
            await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_chat_id_detection_cq(self, callback_query: CallbackQuery, state: FSMContext) -> None:
        logger.info(f"Option selected {callback_query.data}")
        if callback_query.data == "config_back":
            await state.set_state(ConfigurationStates.config_groups)
            await callback_query.message.reply(text=f"Выберите настройку групп: ",
                                               reply_markup=config_group_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_configuration_misc(self, callback_query: CallbackQuery, state: FSMContext) -> None:
        logger.info(f"Configuration option selected {callback_query.data}")
        if callback_query.data == "config_back":
            await state.set_state(ConfigurationStates.select_configuration)
            await callback_query.message.reply(text=f"Выберите настройку: ", reply_markup=config_action_selector())
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
