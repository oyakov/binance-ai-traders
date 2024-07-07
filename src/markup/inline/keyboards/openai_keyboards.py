from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)


def openai_action_selector():
    inline_btn_1 = InlineKeyboardButton(text='Чат с AI Ассистентом', callback_data='ai_chat')
    inline_btn_2 = InlineKeyboardButton(text='Создать изображение', callback_data='ai_create_image')
    return InlineKeyboardMarkup(inline_keyboard=[[inline_btn_1, inline_btn_2]])
