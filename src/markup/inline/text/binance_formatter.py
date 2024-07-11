from typing import Dict, Any


def format_account_info(account_info: Dict[str, Any]) -> str:
    """Format account information to a human-readable string"""
    account_info_str = f"*Account Information:*\n"
    for balance in account_info['balances']:
        if float(balance['free']) > 0 or float(balance['locked']) > 0:
            account_info_str += f"**{balance['asset']}:**\n"
            account_info_str += f" Free: {balance['free']}\n"
            account_info_str += f" Locked: {balance['locked']}\n"
    return account_info_str


def format_ticker(ticker: Dict[str, Any]) -> str:
    """Format ticker information to a human-readable string"""
    ticker_str = f"*Ticker Information:*\n"
    for key, value in ticker.items():
        ticker_str += f"**{key}:** {value}\n"
    return ticker_str


def format_klines(klines: Dict[str, Any]) -> str:
    """Format klines information to a human-readable string"""
    klines_str = f"*Klines Information:*\n"
    for key, value in klines.items():
        klines_str += f"**{key}:** {value}\n"
    return klines_str
