from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)

from markup.inline.types import DateSelector


def date_selector_picker_inline(date_selectors: list[DateSelector], row_size: int):        
        buttons = []

        # Build buttons
        for selector in date_selectors:
                text = f"{selector.text} {'✅' if selector.enabled else '❌'}"
                callback_data = f"{selector.key}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))

        # Split buttons into rows of size row_size
        buttons_layout: list[list[InlineKeyboardButton]] = [buttons[i:i + row_size] for i in range(0, len(buttons), row_size)]
        
        # Add the "Back" button in a new row
        buttons_layout.append([InlineKeyboardButton(text="Назад 🔙", callback_data='back')])
        return InlineKeyboardMarkup(inline_keyboard=buttons_layout)