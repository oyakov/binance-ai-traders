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

from markup.main_menu_reply_keyboard import create_reply_kbd
from markup.inline.time_pickers import day_of_the_month_picker_inline, day_of_the_week_picker_inline, month_of_the_year_picker_inline, time_of_the_day_picker_inline

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
@new_message_router.message(F.text.casefold() == "Новое сообщение")
async def command_start(message: Message, state: FSMContext) -> None:
    await state.set_state(NewMessage.new_msg_input_text)
    await message.answer(
        "Введите текст сообщения:",
        reply_markup=create_reply_kbd()
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
        reply_markup=create_reply_kbd(),
    )


@new_message_router.message(NewMessage.new_msg_input_text)
async def process_text(message: Message, state: FSMContext) -> None:
    await state.update_data(text=message.text)
    await state.set_state(NewMessage.new_msg_select_group)
    
#    inline_kb = InlineKeyboardMarkup(row_width=2)
    inline_btn_1 = InlineKeyboardButton(text='Группа 1', callback_data='group1')
    inline_btn_2 = InlineKeyboardButton(text='Группа 2', callback_data='group2')
    inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])

    await message.reply(text=f"Выберите целевые группы:", reply_markup=inline_kb)
    await message.answer(text="placeholder", reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_select_group)
async def process_group(callback_query: CallbackQuery, state: FSMContext):
    
    code = callback_query.data
    await state.update_data(group=code)
    if code == 'group1':
        text = 'Вы выбрали Группу 1\n'
    elif code == 'group2':
        text = 'Вы выбрали Группу 2\n'
    
    await state.set_state(NewMessage.new_msg_now_or_interval)

    text += ' Отправим сообщение сейчас или запланируем?'
    inline_btn_1 = InlineKeyboardButton(text='Сейчас', callback_data='now')
    inline_btn_2 = InlineKeyboardButton(text='Запланируем', callback_data='interval')
    inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])
    await callback_query.message.answer(text=text, reply_markup=inline_kb)
    await callback_query.message.reply(text=text, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_now_or_interval)
async def process_now_or_later(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    await state.update_data(type=code)
    if code == 'now':
        text = 'Вы выбрали отправку сообщения сейчас, сообщение отправлено.'
        inline_btn_1 = InlineKeyboardButton(text='Создать новое сообщение', callback_data='new_message')
        inline_btn_2 = InlineKeyboardButton(text='Посмотреть контент-план', callback_data='content_plan')
        inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])
        await state.set_state(NewMessage.new_msg_now)
    elif code == 'interval':
        text = 'Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже'
        inline_btn_1 = InlineKeyboardButton(text='Месяцы', callback_data='months_of_the_year')
        inline_btn_2 = InlineKeyboardButton(text='Дни месяца', callback_data='days_of_the_month')
        inline_btn_3 = InlineKeyboardButton(text='Дни недели', callback_data='days_of_the_week')
        inline_btn_4 = InlineKeyboardButton(text='Время', callback_data='time_of_the_day')
        inline_kb = InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2, inline_btn_3, inline_btn_4]])
        await state.set_state(NewMessage.new_msg_interval_choose_type)

    await callback_query.message.answer(text=text, reply_markup=inline_kb)
    await callback_query.message.reply(text=text, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_interval_choose_type)
async def process_interval_choose_type(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    if code == "months_of_the_year":
        text = 'Выберите месяцы, в которые будет отправляться сообщение'
        inline_kb = month_of_the_year_picker_inline(NewMessage.new_msg_interval_type_months_in_the_year)
    elif code == "days_of_the_month":
        text = 'Выберите дни месяца, в которые будет отправляться сообщение'
        inline_kb = day_of_the_month_picker_inline()
        await state.set_state(NewMessage.new_msg_interval_type_days_in_the_month)
    elif code == "days_of_the_week":
        text = 'Выберите дни недели, в которые будет отправляться сообщение'
        data = await state.get_data()
        selected_days = data['selected_dow']
        if not selected_days:
            selected_days = {
                'monday': False,
                'tuesday': False,
                'wednesday': False,
                'thursday': False,
                'friday': False,
                'saturday': False,
                'sunday': False
            }
            state.set_data(selected_dow=selected_days)
        inline_kb = day_of_the_week_picker_inline(selected_days=selected_days)
        await state.set_state(NewMessage.new_msg_interval_type_days_in_the_week)
    elif code == 'time_of_the_day':
        text = 'Выберите времена, в течение дня, в которые будет отправляться сообщение'
        selected_times = await state.get_data('selected_tod')
        if not selected_times:
            selected_times = {
                '10:00': False,
                '12:00': False,
                '14:00': False,
                '16:00': False,
                '18:00': False,
                '20:00': False,
                '22:00': False
            }
            state.set_data(selected_tod=selected_times)
        inline_kb = time_of_the_day_picker_inline(selected_times)
        await state.set_state(NewMessage.new_msg_interval_type_time_in_the_day)
    
    await callback_query.message.reply(text=text, reply_markup=inline_kb)
    await callback_query.message.answer(text=text, reply_markup=create_reply_kbd())

@new_message_router.callback_query(NewMessage.new_msg_interval_type_days_in_the_week)
async def process_day_of_the_week(callback_query: CallbackQuery, state: FSMContext):
    selected_days = await state.get_data("selected_dow")
    day = callback_query.data

    # Toggle selection
    selected_days[day] = not selected_days.get(day, False)

    # Update state
    await state.update_data(selected_days=selected_days)

    # Send updated picker
    text = 'Выберите дни недели, в которые будет отправляться сообщение'
    inline_kb = day_of_the_week_picker_inline(selected_days)
    await callback_query.message.edit_reply_markup(reply_markup=inline_kb)

@new_message_router.callback_query(NewMessage.new_msg_interval_type_time_in_the_day)
async def process_times_of_the_day(callback_query: CallbackQuery, state: FSMContext):
    selected_times = state.get_data("selected_tod")
    day = callback_query.data

    # Toggle selection
    selected_times[day] = not selected_times.get(day, False)

    # Update state
    await state.update_data(selected_tod=selected_times)

    # Send updated picker
    text = 'Выберите времена, в течение дня, в которые будет отправляться сообщение'
    inline_kb = day_of_the_week_picker_inline(selected_times)
    await callback_query.message.edit_reply_markup(reply_markup=inline_kb)