from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import (
    Message,
    CallbackQuery,
)

from db.repository.calendar_repository import CalendarRepository
from db.repository.telegram_group_repository import TelegramGroupRepository
from markup.inline.keyboards.new_message_keyboards import group_picker, now_or_later, choose_what_to_do_next, \
    choose_date_type_inline
from markup.inline.time_pickers import date_selector_picker_inline
from markup.inline.types import times_of_the_day, days_of_the_week, months_of_the_year, days_of_the_month, \
    DateSelector
from markup.reply.main_menu_reply_keyboard import NEW_MESSAGE, create_reply_kbd
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter
from routers.main_menu import MainMenuStates

new_message_router = BaseRouter(
    services=[],
    repositories=[
        {
            'name': 'tg_group_repository',
            'service_class': TelegramGroupRepository
        },
        {
            'name': 'calendar_repository',
            'service_class': CalendarRepository
        },
    ],
)

logger = log_config.get_logger(__name__)


class NewMessageStates(StatesGroup):
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
@new_message_router.message(F.text == NEW_MESSAGE)
async def command_start(message: Message, state: FSMContext) -> None:
    logger.info(f"Starting new periodic message dialog. Chat ID {message.chat.id}")

    await state.set_state(NewMessageStates.new_msg_input_text)

    # Inititalize default calenndar objects for the new message
    await state.set_data({'selected_tod': times_of_the_day(), 
                          'selected_dow': days_of_the_week(),
                          'selected_moy': months_of_the_year(),
                          'selected_dom': days_of_the_month()})

    await message.answer(
        "Введите текст сообщения:",
        reply_markup=create_reply_kbd()
    )


@new_message_router.message(Command("cancel"))
@new_message_router.message(F.text == "cancel")
async def cancel_handler(message: Message, state: FSMContext) -> None:
    """
    Allow user to cancel any action
    """
    current_state = await state.get_state()
    if current_state is None:
        return

    logger.info("Cancelling state %r", current_state)
    await state.clear()
    await message.answer(
        "Отмена",
        reply_markup=create_reply_kbd(),
    )


@new_message_router.message(NewMessageStates.new_msg_input_text)
async def process_text(message: Message,
                       state: FSMContext,
                       tg_group_repository: TelegramGroupRepository) -> None:
    await state.update_data(text=message.text)
    await state.set_state(NewMessageStates.new_msg_select_group)

    # Load the Telegram groups that are attached for this user
    groups = await tg_group_repository.load_telegram_groups_by_username(message.from_user.username)
    inline_kb = group_picker(groups=groups, row_size=2)

    await message.reply(text=f"Выберите целевые группы: ", reply_markup=inline_kb)
    await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessageStates.new_msg_select_group)
async def process_group(callback_query: CallbackQuery, state: FSMContext):    
    code = callback_query.data
    await state.update_data(group=code)
    await state.set_state(NewMessageStates.new_msg_now_or_interval)

    text = f'Вы выбрали группу с chat id {code}\n'    
    text += 'Отправим сообщение сейчас или запланируем?'
    inline_kb = now_or_later()

    await callback_query.message.reply(text=text, reply_markup=inline_kb)
    await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessageStates.new_msg_now_or_interval)
async def process_now_or_later(callback_query: CallbackQuery, state: FSMContext):
    code = callback_query.data
    await state.update_data(type=code)
    if code == 'now':
        text = 'Вы выбрали отправку сообщения сейчас, сообщение отправлено.'
        inline_kb = choose_what_to_do_next()
        await state.set_state(MainMenuStates.main_menu_awaiting_input)
    elif code == 'interval':
        text = 'Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже'
        inline_kb = choose_date_type_inline()
        await state.set_state(NewMessageStates.new_msg_interval_choose_type)

    await callback_query.message.reply(text=text, reply_markup=inline_kb)
    await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessageStates.new_msg_interval_choose_type)
async def process_interval_choose_type(callback_query: CallbackQuery,
                                       state: FSMContext,
                                       calendar_repository: CalendarRepository):
    code = callback_query.data
    data = await state.get_data()
    logger.info(calendar_repository)
    if code == "months_of_the_year":
        text = 'Выберите месяцы, в которые будет отправляться сообщение'
        try:
            selected_months = data['selected_moy']
        except KeyError:
            selected_months = months_of_the_year()
            await state.update_data({'selected_moy': selected_months})     
        inline_kb = date_selector_picker_inline(date_selectors=selected_months, row_size=4)
        await state.set_state(NewMessageStates.new_msg_interval_type_months_in_the_year)
    elif code == "days_of_the_month":
        text = 'Выберите дни месяца, в которые будет отправляться сообщение'
        try:
            selected_days = data['selected_dom']
        except KeyError:
            selected_days = days_of_the_month()
            await state.update_data({'selected_dom': selected_days})     
        inline_kb = date_selector_picker_inline(date_selectors=selected_days, row_size=4)
        await state.set_state(NewMessageStates.new_msg_interval_type_days_in_the_month)
    elif code == "days_of_the_week":
        text = 'Выберите дни недели, в которые будет отправляться сообщение'
        try:
            selected_days = data['selected_dow']
        except KeyError:
            selected_days = days_of_the_week()
            await state.update_data({'selected_dow': selected_days})            
        inline_kb = date_selector_picker_inline(date_selectors=selected_days, row_size=4)
        await state.set_state(NewMessageStates.new_msg_interval_type_days_in_the_week)
    elif code == 'time_of_the_day':
        text = 'Выберите времена, в течение дня, в которые будет отправляться сообщение'
        try:
            selected_times = data['selected_tod']
        except KeyError:
            selected_times = times_of_the_day()
            await state.update_data({'selected_tod': selected_times})
        inline_kb = date_selector_picker_inline(date_selectors=selected_times, row_size=4)
        await state.set_state(NewMessageStates.new_msg_interval_type_time_in_the_day)
    elif code == 'confirm':
        text = 'Данные приняты, сообщение настроено на периодическое отправление'
        try:
            logger.info('Selected months:\n')
            selected_months: list[DateSelector] = data['selected_moy']
            logger.info(f'{selected_months}\n')
        except KeyError:
            logger.error("Unknown error loading moy data")
        try:
            logger.info('Selected days in the month:\n')
            selected_dom: list[DateSelector] = data['selected_dom']
            logger.info(f'{selected_dom}\n')
        except KeyError:
            logger.error("Unknown error loading dom data")
        try:
            logger.info('Selected days of the week:\n')
            selected_dow: list[DateSelector] = data['selected_dow']
            logger.info(f'{selected_dow}\n')
        except KeyError:
            logger.error("Unknown error loading dow data")
        try:
            logger.info('Selected times of the day:\n')
            selected_times: list[DateSelector] = data['selected_tod']
            logger.info(f'{selected_times}')
        except KeyError:
            logger.error("Unknown error loading tod data")
        inline_kb = choose_what_to_do_next()
        chat_id = data['group']
        text_to_send = data['text']
        # Write collected calendar data to the database
        await calendar_repository.create_calendar_data(
            chat_id,
            'username',
            text_to_send,
            selected_dow,
            selected_dom,
            selected_months,
            selected_times)
        await state.set_state(MainMenuStates.main_menu_awaiting_input)
    
    await callback_query.message.reply(text=text, reply_markup=inline_kb)
    await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())


@new_message_router.callback_query(NewMessageStates.new_msg_interval_type_days_in_the_week)
async def process_day_of_the_week(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessageStates.new_msg_interval_choose_type)
        await callback_query.message.answer(
            text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже',
            reply_markup=choose_date_type_inline())
        await callback_query.message.reply(text=DELIMITER, reply_markup=create_reply_kbd())
    else:
        data = await state.get_data()
        changed_day = callback_query.data
        logger.info(f'Changed day is {changed_day}')

        try:
            selected_days = data['selected_dow']
            logger.info('Selected days are loaded successfully')
        except KeyError:
            logger.warning('Error loading selected days')
            selected_days = days_of_the_week()
            await state.update_data({'selected_dow': selected_days})   

        # Toggle selection
        for day in selected_days:
            logger.info(day)
            if day.key == changed_day:
                logger.info(f'Toggle day {day.key}')
                day.enabled = not day.enabled

        # Update state
        await state.update_data(selected_days=selected_days)

        # Send updated picker
        text = 'Выберите дни недели, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_days, row_size=4)
        await callback_query.message.edit_reply_markup(text=text, reply_markup=inline_kb)


@new_message_router.callback_query(NewMessageStates.new_msg_interval_type_time_in_the_day)
async def process_times_of_the_day(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessageStates.new_msg_interval_choose_type)
        await callback_query.message.answer(
            text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже',
            reply_markup=choose_date_type_inline())
        await callback_query.message.reply(text=DELIMITER, reply_markup=create_reply_kbd())
    else:
        data = await state.get_data()
        changed_time = callback_query.data
        logger.info(f'Changed time is {changed_time}')

        try:
            selected_times = data['selected_tod']
            logger.info('Selected times are loaded successfully')
        except KeyError:
            logger.warning('Error loading selected times')
            selected_times = times_of_the_day()
            await state.update_data({'selected_tod': selected_times})   

        # Toggle selection
        for time in selected_times:
            logger.info(time)
            if time.key == changed_time:
                logger.info(f'Toggle time {time.key}')
                time.enabled = not time.enabled

        # Update state
        await state.update_data(selected_times=selected_times)

        # Send updated picker
        text = 'Выберите времена дня, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_times, row_size=4)
        await callback_query.message.edit_reply_markup(text=text, reply_markup=inline_kb)


@new_message_router.callback_query(NewMessageStates.new_msg_interval_type_months_in_the_year)
async def process_month_of_the_year(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessageStates.new_msg_interval_choose_type)
        await callback_query.message.reply(
            text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже',
            reply_markup=choose_date_type_inline())
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    else:
        data = await state.get_data()
        changed_month = callback_query.data
        logger.info(f'Changed month is {changed_month}')

        try:
            selected_months = data['selected_moy']
            logger.info('Selected months are loaded successfully')
        except KeyError:
            logger.warning('Error loading selected months')
            selected_months = months_of_the_year()
            await state.update_data({'selected_moy': selected_months})   

        # Toggle selection
        for month in selected_months:
            logger.info(month)
            if month.key == changed_month:
                logger.info(f'Toggle month {month.key}')
                month.enabled = not month.enabled

        # Update state
        await state.update_data(selected_months=selected_months)

        # Send updated picker
        text = 'Выберите месяца, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_months, row_size=4)
        await callback_query.message.edit_reply_markup(text=text, reply_markup=inline_kb)


@new_message_router.callback_query(NewMessageStates.new_msg_interval_type_days_in_the_month)
async def process_days_in_the_month(callback_query: CallbackQuery, state: FSMContext):
    if callback_query.data == 'back':
        await state.set_state(NewMessageStates.new_msg_interval_choose_type)
        await callback_query.message.reply(
            text='Вы выбрали отправку по расписанию, настройте расписание при помощи инструментов ниже',
            reply_markup=choose_date_type_inline())
        await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
    else:
        data = await state.get_data()
        changed_day = callback_query.data
        logger.info(f'Changed day is {changed_day}')
        try:
            selected_days = data['selected_dom']
            logger.info('Selected days are loaded successfully')
        except KeyError:
            logger.warning('Error loading selected days')
            selected_days = days_of_the_month()
            await state.update_data({'selected_dom': selected_days})   

        # Toggle selection
        for day in selected_days:
            logger.info(day)
            if day.key == changed_day:
                logger.info(f'Toggle day {day.key}')
                day.enabled = not day.enabled

        # Update state
        await state.update_data(selected_days=selected_days)

        # Send updated picker
        text = 'Выберите дни месяца, в которые будет отправляться сообщение'
        inline_kb = date_selector_picker_inline(selected_days, row_size=4)
        await callback_query.message.edit_reply_markup(text=text, reply_markup=inline_kb)
