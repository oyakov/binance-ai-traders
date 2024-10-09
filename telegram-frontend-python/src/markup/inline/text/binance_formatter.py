from typing import Dict, Any


def format_account_info(account_info: Dict[str, Any]) -> str:
    """Format account information to a human-readable string"""
    account_info_str = f"*Account Information:*\n"
    for balance in account_info['balances']:
        if float(balance['free']) > 0 or float(balance['locked']) > 0:
            account_info_str += f"**{balance['asset']}:**\n"
            account_info_str += f" Free: {balance['free']}\n"
            account_info_str += f" Locked: {balance['locked']}\n"
    return crop_telegram_message(account_info_str)


def format_ticker(ticker: Dict[str, Any]) -> str:
    """Format ticker information to a human-readable string"""
    ticker_str = f"*Ticker Information:*\n"
    for key, value in ticker.items():
        ticker_str += f"**{key}:** {value}\n"
    return crop_telegram_message(ticker_str)


def format_klines(klines: Dict[str, Any]) -> str:
    """Format klines information to a human-readable string"""
    klines_str = f"*Klines Information:*\n"
    for key, value in klines.items():
        klines_str += f"**{key}:** {value}\n"
    return crop_telegram_message(klines_str)


def format_order_book(order_book: Dict[str, Any]) -> str:
    """Format order book information to a human-readable string"""
    order_book_str = f"*Order Book Information:*\n"
    for key, value in order_book.items():
        order_book_str += f"**{key}:** {value}\n"
    return crop_telegram_message(order_book_str)


def crop_telegram_message(text, max_length=4096):
    """Crop large message to fit Telegram message"""
    if len(text) > max_length:
        idx = text.rfind('\n', 0, max_length)
        if idx == -1:
            idx = max_length
        return text[:idx]
    return text


def send_large_message(bot, chat_id, text, parse_mode=None):
    while len(text) > 0:
        if len(text) > 4096:
            idx = text.rfind('\n', 0, 4096)
            if idx == -1:
                idx = 4096
            part = text[:idx]
            text = text[idx:]
        else:
            part = text
            text = ""
        bot.send_message(chat_id, part, parse_mode=parse_mode)
