from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.types import Message, CallbackQuery
from injector import inject

from markup.inline.keyboards.openai_keyboards import openai_action_selector
from markup.reply.main_menu_reply_keyboard import create_reply_kbd, OPENAI
from oam import log_config
from oam.environment import DELIMITER
from routers.openai_router import OpenAIStates
from service.openai.openai_api_service import OpenAIAPIService
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class OpenAiSubsystem(Subsystem):

    @inject
    def __init__(self, bot, openai_router):
        self.openai_service = None
        self.bot = bot
        self.openai_router = openai_router

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing OpenAI subsystem {self.bot}")
        try:
            self.openai_service = OpenAIAPIService()
        except Exception as e:
            logger.error(f"OpenAI subsystem failed to initialize: {e}")
            return
        logger.info(f"OpenAI subsystem is initialized")
        self.openai_router.message(Command("openai"))(self.display_select_action)
        self.openai_router.message(F.text == OPENAI)(self.display_select_action)
        self.openai_router.callback_query(OpenAIStates.openai_select_action)(self.process_function_selection)
        self.openai_router.message(OpenAIStates.openai_system_prompt)(self.process_user_input)
        self.openai_router.message(OpenAIStates.openai_get_completion)(self.process_user_input)

        self.is_initialized = True

    async def shutdown(self):
        pass

    def get_priority(self):
        return InitPriority.DATA_SOURCE

    async def get_openai_service(self):
        return self.openai_service

    async def get_openai_router(self):
        return self.openai_router

    async def display_select_action(self, message: Message, state: FSMContext):
        logger.info(f"Starting new Open AI dialog. Chat ID {message.chat.id}. Display action selection dialog.")

        await state.set_state(OpenAIStates.openai_select_action)

        inline_kb = openai_action_selector()

        await message.reply(text=f"Выберите функцию OpenAI: ", reply_markup=inline_kb)
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def process_function_selection(self, callback_query: CallbackQuery, state: FSMContext,
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

    async def process_user_input(self, message: Message, state: FSMContext, openai_service: OpenAIAPIService):
        logger.info(f"User replied with the message {message.text}")
        await state.set_state(OpenAIStates.openai_get_completion)
        user_message = {"role": "user", "content": message.text}
        data = await state.get_data()
        history = data['history']
        history.append(user_message)
        history = await openai_service.get_completion(history=history)
        await message.reply(text=history[-1]['content'], reply_markup=None)
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
