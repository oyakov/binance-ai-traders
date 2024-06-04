from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)

from markup.inline.types import DateSelector


def date_selector_picker_inline(date_selectors: list[DateSelector]):
        buttons = []
        for selector in date_selectors:
                text = f"{selector.text} {'✅' if selector.enabled else '❌'}"
                callback_data = f"toggle_{selector.key}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        buttons.append(InlineKeyboardButton(text="Назад 🔙", callback_data='back'))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])