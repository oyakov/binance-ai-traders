import logging

from aiogram import Bot, Dispatcher, F, Router, html
from aiogram.enums import ParseMode
from aiogram.filters import Command, CommandStart
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    KeyboardButton,
    Message,
    ReplyKeyboardMarkup,
    ReplyKeyboardRemove,
    InlineKeyboardMarkup,
    InlineKeyboardButton,
    CallbackQuery,
)

new_message_router = Router()

class NewMessage(StatesGroup):
    new_msg_input_text = State()
    new_msg_select_group = State()
    new_msg_now_or_interval = State()
    new_msg_interval_choose_type = State()
    new_msg_now = State()
    new_msg_interval_type_months_in_the_year = State()
    new_msg_interval_type_days_in_the_month = State()
    new_msg_interval_type_days_in_the_week = State()
    new_msg_interval_type_time_in_the_day = State()

@new_message_router.message(Command("new_message"))
async def command_start(message: Message, state: FSMContext) -> None:
    await state.set_state(NewMessage.new_msg_input_text)
    await message.answer(
        "Введите текст сообщения:",
        reply_markup=ReplyKeyboardRemove()
    )

@new_message_router.message(Command("cancel"))
@new_message_router.message(F.text.casefold() == "cancel")
async def cancel_handler(message: Message, state: FSMContext) -> None:
    """
    Allow user to cancel any action
    """
    current_state = await state.get_state()
    if current_state is None:
        return

    logging.info("Cancelling state %r", current_state)
    await state.clear()
    await message.answer(
        "Отмена",
        reply_markup=ReplyKeyboardRemove(),
    )

@new_message_router.message(NewMessage.new_msg_input_text)
async def process_text(message: Message, state: FSMContext) -> None:
    await state.update_data(text=message.text)
    await state.set_state(NewMessage.new_msg_select_group)
    
#    inline_kb = InlineKeyboardMarkup(row_width=2)
    inline_btn_1 = InlineKeyboardButton(text='Группа 1', callback_data='group1')
    inline_btn_2 = InlineKeyboardButton(text='Группа 2', callback_data='group2')
    inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])

    await message.reply(f"Выберите целевые группы:", reply_markup=inline_kb)

@new_message_router.callback_query(NewMessage.new_msg_select_group)
async def process_group(callback_query: CallbackQuery, state: FSMContext):
    
    code = callback_query.data
    await state.update_data(group=code)
    if code == 'group1':
        text = 'Вы выбрали Группу 1'
    elif code == 'group2':
        text = 'Вы выбрали Группу 2'
    
    await state.set_state(NewMessage.new_msg_now_or_interval)

    text += ' Отправим сообщение сейчас или запланируем?'
    inline_btn_1 = InlineKeyboardButton(text='Сейчас', callback_data='now')
    inline_btn_2 = InlineKeyboardButton(text='Запланируем', callback_data='interval')
    inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])
    await callback_query.message.answer(text, reply_markup=inline_kb)

@new_message_router.callback_query(NewMessage.new_msg_now_or_interval)
async def process_now_or_later(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    await state.update_data(type=code)
    if code == 'now':
        text = ''
        await state.set_state(NewMessage.new_msg_now)
    elif code == 'interval':
        text = 'Вы выбрали отправку по расписанию'
        await state.set_state(NewMessage.new_msg_interval_choose_type)