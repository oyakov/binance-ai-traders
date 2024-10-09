from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton


def actuator_action_selector():
    """Create actuator action selector keyboard"""
    btn1 = InlineKeyboardButton(text="Subsystem health", callback_data="subsystem_health")
    return InlineKeyboardMarkup(inline_keyboard=[[btn1]])
