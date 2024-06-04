import logging

from aiogram import F, Router, html
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from markup.reply.main_menu_reply_keyboard import *
from markup.inline.time_pickers import *
from markup.inline.types import *
from markup.inline.keyboards import *

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
    
    groups = static_groups_mock()
    inline_kb = group_picker(groups=groups, row_size=2)

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
    text += 'Отправим сообщение сейчас или запланируем?'
    inline_kb = now_or_later()

    await callback_query.message.answer(text=text, reply_markup=inline_kb)
    await callback_query.message.reply(text=text, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_now_or_interval)
async def process_now_or_later(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    await state.update_data(type=code)
    if code == 'now':
        text = 'Вы выбрали отправку сообщения сейчас, сообщение отправлено.'
        inline_kb = choose_what_to_do_next()
        await state.set_state(NewMessage.new_msg_now)
    elif code == 'interval':
        text = 'Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже'
        inline_kb = choose_date_type_inline()
        await state.set_state(NewMessage.new_msg_interval_choose_type)

    await callback_query.message.answer(text=text, reply_markup=inline_kb)
    await callback_query.message.reply(text=text, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_interval_choose_type)
async def process_interval_choose_type(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    data = await state.get_data()
    if code == "months_of_the_year":
        text = 'Выберите месяцы, в которые будет отправляться сообщение'
        try:
            selected_months = data['selected_moy']
        except KeyError:
            selected_months = days_of_the_week()
            await state.set_data({'selected_moy': selected_months})     
        inline_kb = date_selector_picker_inline(date_selectors=selected_months)
    elif code == "days_of_the_month":
        text = 'Выберите дни месяца, в которые будет отправляться сообщение'
        try:
            selected_days = data['selected_dom']
        except KeyError:
            selected_days = days_of_the_week()
            await state.set_data({'selected_dom': selected_days})     
        inline_kb = date_selector_picker_inline(date_selectors=selected_days)
        await state.set_state(NewMessage.new_msg_interval_type_days_in_the_month)
    elif code == "days_of_the_week":
        text = 'Выберите дни недели, в которые будет отправляться сообщение'
        try:
            selected_days = data['selected_dow']
        except KeyError:
            selected_days = days_of_the_week()
            await state.set_data({'selected_dow': selected_days})            
        inline_kb = date_selector_picker_inline(date_selectors=selected_days)
        await state.set_state(NewMessage.new_msg_interval_type_days_in_the_week)
    elif code == 'time_of_the_day':
        text = 'Выберите времена, в течение дня, в которые будет отправляться сообщение'
        try:
            selected_times = data['selected_tod']
        except KeyError:
            selected_times = times_of_the_day()
            state.set_data({'selected_tod': selected_times})
        inline_kb = date_selector_picker_inline(date_selectors=selected_times)
        await state.set_state(NewMessage.new_msg_interval_type_time_in_the_day)
    
    await callback_query.message.reply(text=text, reply_markup=inline_kb)
    await callback_query.message.answer(text=text, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessage.new_msg_interval_type_days_in_the_week)
async def process_day_of_the_week(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessage.new_msg_interval_choose_type)
        await callback_query.message.answer(text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже', 
                                            reply_markup=choose_date_type_inline())
        await callback_query.message.reply(text='==============', reply_markup=create_reply_kbd())
    else:
        data = await state.get_data()
        changed_day = callback_query.data
        logging.info(f'Changed day is {changed_day}')

        try:
            selected_days = data['selected_dow']
            logging.info('Selected days are loaded suscessfully')
        except KeyError:
            logging.warn('Error loading selected days')
            selected_days = days_of_the_week()
            await state.set_data({'selected_dow': selected_days})   

        # Toggle selection
        for day in selected_days:
            logging.info(day)
            if day.key == changed_day:
                logging.info(f'Toggle day {day.key}')
                day.enabled = not day.enabled


        # Update state
        await state.update_data(selected_days=selected_days)

        # Send updated picker
        text = 'Выберите дни недели, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_days)
        await callback_query.message.edit_reply_markup(text=text, reply_markup=inline_kb)


@new_message_router.callback_query(NewMessage.new_msg_interval_type_time_in_the_day)
async def process_times_of_the_day(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessage.new_msg_interval_choose_type)
        await callback_query.message.answer(text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже', 
                                            reply_markup=choose_date_type_inline())
        await callback_query.message.reply(text='==============', reply_markup=create_reply_kbd())
    else:
        selected_times = state.get_data("selected_tod")
        day = callback_query.data

        # Toggle selection
        selected_times[day] = not selected_times.get(day, False)

        # Update state
        await state.update_data(selected_tod=selected_times)

        # Send updated picker
        text = 'Выберите времена, в течение дня, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_times)
        await callback_query.message.edit_reply_markup(reply_markup=inline_kb)

