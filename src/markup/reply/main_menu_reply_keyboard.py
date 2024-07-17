from aiogram.types import (
    ReplyKeyboardMarkup,
)
from aiogram.utils.keyboard import ReplyKeyboardBuilder

NEW_MESSAGE = "Content Plan"  # TODO: remake to the content plan
BINANCE = "Binance"
OPENAI = "Open AI"
MONITORING = "Monitoring"
SETTINGS = "Настройки"


def create_reply_kbd() -> ReplyKeyboardMarkup:
    markup = ReplyKeyboardBuilder()
    markup.button(text=NEW_MESSAGE)
    markup.button(text=BINANCE)
    markup.button(text=OPENAI)
    markup.button(text=MONITORING)
    markup.button(text=SETTINGS)
    return markup.adjust(2).as_markup(resize_keyboard=True)
