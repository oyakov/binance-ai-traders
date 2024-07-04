import logging

from aiogram import F, Router
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from markup.inline.keyboards.openai_keyboards import *
from markup.inline.time_pickers import *
from markup.inline.types import *
from markup.reply.main_menu_reply_keyboard import *
from middleware.service_middleware import ServiceMiddleware
from routers.main_menu import MainMenuStates
from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from service.openai.openai_api_service import OpenAIAPIService

openai_router = Router()
openai_router.message.middleware(ServiceMiddleware('openai_service', OpenAIAPIService()))
openai_router.callback_query.middleware(ServiceMiddleware('openai_service', OpenAIAPIService()))

delimiter: str = '🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊🌊'

logger = logging.getLogger(__name__)


class OpenAIStates(StatesGroup):
    openai_select_action = State()
    openai_system_prompt = State()
    openai_get_completion = State()
    openai_create_image = State()


@openai_router.message(Command("openai"))
@openai_router.message(F.text == OPENAI)
async def display_select_action(message: Message, state: FSMContext):
    logger.info(f"Starting new Open AI dialog. Chat ID {message.chat.id}. Display action selection dialog.")

    await state.set_state(OpenAIStates.openai_select_action)

    inline_kb = openai_action_selector()

    await message.reply(text=f"Выберите функцию OpenAI: ", reply_markup=inline_kb)
    await message.answer(text=delimiter, reply_markup=create_reply_kbd())


@openai_router.callback_query(OpenAIStates.openai_select_action)
async def process_function_selection(callback_query: CallbackQuery, state: FSMContext, openai_service: OpenAIAPIService):
    code = callback_query.data

    logger.info(f"OpenAI action selected {code}")

    if code == "ai_chat":
        await state.set_state(OpenAIStates.openai_system_prompt)
        # Get the initial prompt from the assistant
        history = await openai_service.get_completion(history=None)
        await state.set_data({'history': history})
        await callback_query.message.reply(text=history[-1]['content'], reply_markup=None)
        await callback_query.message.answer(text=delimiter, reply_markup=create_reply_kbd())
    elif code == "ai_create_image":
        await state.set_state(OpenAIStates.openai_create_image)


@openai_router.message(OpenAIStates.openai_system_prompt)
@openai_router.message(OpenAIStates.openai_get_completion)
async def process_user_input(message: Message, state: FSMContext, openai_service: OpenAIAPIService):
    logger.info(f"User replied with the message {message.text}")
    await state.set_state(OpenAIStates.openai_get_completion)
    user_message = {"role": "user", "content": message.text}
    data = await state.get_data()
    history = data['history']
    history.append(user_message)
    history = await openai_service.get_completion(history=history)
    await message.reply(text=history[-1]['content'], reply_markup=None)
    await message.answer(text=delimiter, reply_markup=create_reply_kbd())
