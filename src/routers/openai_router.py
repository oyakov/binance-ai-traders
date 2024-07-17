from oam import log_config

from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from oam.environment import DELIMITER
from markup.inline.keyboards.openai_keyboards import openai_action_selector
from markup.reply.main_menu_reply_keyboard import OPENAI, create_reply_kbd
from routers.base_router import BaseRouter
from service.openai.openai_api_service import OpenAIAPIService

openai_router = BaseRouter(
    services=[{
        'name': 'openai_service',
        'service_class': OpenAIAPIService
    }, ],
    repositories=[],
)

logger = log_config.get_logger(__name__)


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
    await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@openai_router.callback_query(OpenAIStates.openai_select_action)
async def process_function_selection(callback_query: CallbackQuery, state: FSMContext,
                                     openai_service: OpenAIAPIService):
    code = callback_query.data
    logger.info(f"OpenAI action selected {code}")

    if code == "ai_chat":
        await state.set_state(OpenAIStates.openai_system_prompt)
        # Get the initial prompt from the assistant
        history = await openai_service.get_completion(history=None)
        await state.set_data({'history': history})
        await callback_query.message.reply(text=history[-1]['content'], reply_markup=None)
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
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
    await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
