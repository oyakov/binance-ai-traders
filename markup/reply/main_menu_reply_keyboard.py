from aiogram.types import (
    ReplyKeyboardMarkup,
)
from aiogram.utils.keyboard import ReplyKeyboardBuilder


def create_reply_kbd() -> ReplyKeyboardMarkup:
    markup = ReplyKeyboardBuilder()
    markup.button(text="Новое сообщение")
    markup.button(text="Контент-план")
    markup.button(text="Настройки")
    markup.button(text="Статистика")
    return markup.adjust(2).as_markup(resize_keyboard=True)