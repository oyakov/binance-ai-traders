from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)

from db.model.telegram.telegram_group import TelegramGroup


def choose_date_type_inline():
    inline_btn_1 = InlineKeyboardButton(text='Месяцы', callback_data='months_of_the_year')
    inline_btn_2 = InlineKeyboardButton(text='Дни месяца', callback_data='days_of_the_month')
    inline_btn_3 = InlineKeyboardButton(text='Дни недели', callback_data='days_of_the_week')
    inline_btn_4 = InlineKeyboardButton(text='Время', callback_data='time_of_the_day')
    inline_btn_5 = InlineKeyboardButton(text='Назад 🔙', callback_data='back')
    inline_btn_6 = InlineKeyboardButton(text='Готово ✅', callback_data='confirm')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2, inline_btn_3, inline_btn_4], [inline_btn_5, inline_btn_6]])


def choose_what_to_do_next():
    inline_btn_1 = InlineKeyboardButton(text='Создать новое сообщение', callback_data='new_message')
    inline_btn_2 = InlineKeyboardButton(text='Посмотреть контент-план', callback_data='content_plan')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])


def now_or_later():
    inline_btn_1 = InlineKeyboardButton(text='Сейчас', callback_data='now')
    inline_btn_2 = InlineKeyboardButton(text='Запланируем', callback_data='interval')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])


def group_picker(groups: list[TelegramGroup], row_size: int):
    buttons = []
    for group in groups:
        buttons.append(InlineKeyboardButton(text=group.display_name, callback_data=f'{group.chat_id}'))
    # Split buttons into rows of size row_size
    buttons_layout: list[list[InlineKeyboardButton]] = [buttons[i:i + row_size] for i in range(0, len(buttons), row_size)]
    return InlineKeyboardMarkup(inline_keyboard=buttons_layout)
