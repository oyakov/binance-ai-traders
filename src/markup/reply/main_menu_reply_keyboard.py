from aiogram.types import (
    ReplyKeyboardMarkup,
)
from aiogram.utils.keyboard import ReplyKeyboardBuilder

NEW_MESSAGE = "Новое сообщение"
CONTENT_PLAN = "Контент-план"
SETTINGS = "Настройки"
OPENAI = "Open AI"


def create_reply_kbd() -> ReplyKeyboardMarkup:
    markup = ReplyKeyboardBuilder()
    markup.button(text=NEW_MESSAGE)
    markup.button(text=CONTENT_PLAN)
    markup.button(text=SETTINGS)
    markup.button(text=OPENAI)
    return markup.adjust(2).as_markup(resize_keyboard=True)
