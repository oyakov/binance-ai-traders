from aiogram.types import (
    InlineKeyboardMarkup,
    InlineKeyboardButton,
)

def day_of_the_week_picker_inline(week_status):
        buttons = []
        for day, selected in week_status:
                text = f"{day} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{day}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def day_of_the_month_picker_inline(month_status):        
        buttons = []
        for day, selected in month_status:
                text = f"{day} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{day}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def month_of_the_year_picker_inline(year_status):        
        buttons = []
        for month, selected in year_status:
                text = f"{month} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{month}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])

def time_of_the_day_picker_inline(day_status):
        buttons = []
        for time, selected in day_status:
                text = f"{time} {'✅' if selected else '❌'}"
                callback_data = f"toggle_{time}"
                buttons.append(InlineKeyboardButton(text=text, callback_data=callback_data))
        return InlineKeyboardMarkup(inline_keyboard=[buttons])