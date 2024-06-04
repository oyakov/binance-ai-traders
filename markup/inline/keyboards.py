from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)

def choose_date_type_inline():
    inline_btn_1 = InlineKeyboardButton(text='Месяцы', callback_data='months_of_the_year')
    inline_btn_2 = InlineKeyboardButton(text='Дни месяца', callback_data='days_of_the_month')
    inline_btn_3 = InlineKeyboardButton(text='Дни недели', callback_data='days_of_the_week')
    inline_btn_4 = InlineKeyboardButton(text='Время', callback_data='time_of_the_day')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2, inline_btn_3, inline_btn_4]])