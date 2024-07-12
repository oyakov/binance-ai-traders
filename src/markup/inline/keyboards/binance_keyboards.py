from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)


def binance_action_selector():
    inline_btn_1 = InlineKeyboardButton(text='Account Info', callback_data='account_info')
    inline_btn_2 = InlineKeyboardButton(text='Ticker', callback_data='ticker')
    inline_btn_3 = InlineKeyboardButton(text='Klines', callback_data='klines')
    inline_btn_4 = InlineKeyboardButton(text='Order book', callback_data='order_book')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2, inline_btn_3, inline_btn_4]])
