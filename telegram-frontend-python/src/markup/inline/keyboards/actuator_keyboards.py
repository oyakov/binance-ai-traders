from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton


def actuator_action_selector():
    """Create actuator action selector keyboard"""
    btn1 = InlineKeyboardButton(text="Subsystem health", callback_data="subsystem_health")
    btn2 = InlineKeyboardButton(text="Start trading", callback_data="start_trading")
    btn3 = InlineKeyboardButton(text="Stop trading", callback_data="stop_trading")
    btn4 = InlineKeyboardButton(text="Trading status", callback_data="request_status")
    return InlineKeyboardMarkup(inline_keyboard=[[btn1], [btn2], [btn3], [btn4]])
