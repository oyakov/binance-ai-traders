from aiogram import F
from aiogram.filters import Command
from aiogram.fsm.context import FSMContext
from aiogram.fsm.state import State, StatesGroup
from aiogram.types import Message, CallbackQuery
from injector import inject

from markup.inline.keyboards.binance_keyboards import binance_action_selector
from markup.inline.text.binance_formatter import format_account_info, format_ticker, format_klines, \
    format_order_book
from markup.reply.main_menu_reply_keyboard import create_reply_kbd, BINANCE
from oam import log_config
from oam.environment import DELIMITER
from routers.base_router import BaseRouter
from service.crypto.binance.binance_service import BinanceService

logger = log_config.get_logger(__name__)


class BinanceStates(StatesGroup):
    select_option = State()
    account_info = State()
    collect_symbol_read_ticker = State()
    collect_symbol_klines = State()
    collect_symbol_order_book = State()


class BinanceRouter(BaseRouter):

    @inject
    def __init__(self, binance: BinanceService):
        self.binance = binance
        self.message(Command("binance"))(self.command_start)
        self.message(F.text == BINANCE)(self.command_start)
        self.callback_query(BinanceStates.select_option)(self.selected_option_callback)
        self.message(BinanceStates.collect_symbol_read_ticker)(self.collect_symbol_read_ticker)
        self.message(BinanceStates.collect_symbol_klines)(self.collect_symbol_klines)
        self.message(BinanceStates.collect_symbol_order_book)(self.collect_symbol_order_book)
        super().__init__([], [])

    def initialize(self, subsystem_manager):
        pass

    async def command_start(self, message: Message, state: FSMContext) -> None:
        logger.info(f"Starting new binance dialog. Chat ID {message.chat.id}")
        await state.set_state(BinanceStates.select_option)
        await message.reply(text=f"Выберите опцию: ", reply_markup=binance_action_selector())
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def selected_option_callback(self, callback_query: CallbackQuery, state: FSMContext,
                                       binance: BinanceService) -> None:
        logger.info(f"Selected option callback. Chat ID {callback_query.message.chat.id}")
        if callback_query.data == "account_info":
            await state.set_state(BinanceStates.select_option)
            account_info = await binance.get_account_info()
            await callback_query.message.reply(text=format_account_info(account_info),
                                               reply_markup=binance_action_selector(),
                                               parse_mode="Markdown")
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "ticker":
            logger.info(f"Ticker callback. Chat ID {callback_query.message.chat.id}")
            await state.set_state(BinanceStates.collect_symbol_read_ticker)
            await callback_query.message.reply(text="Введите символ (например BTCUSDT):")
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "klines":
            logger.info(f"Klines callback. Chat ID {callback_query.message.chat.id}")
            await state.set_state(BinanceStates.collect_symbol_klines)
            await callback_query.message.reply(text="Введите символ (например BTCUSDT):")
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
        elif callback_query.data == "order_book":
            logger.info(f"Order book callback. Chat ID {callback_query.message.chat.id}")
            await state.set_state(BinanceStates.collect_symbol_order_book)
            await callback_query.message.reply(text="Введите символ (например BTCUSDT):")
            await callback_query.message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def collect_symbol_read_ticker(self, message: Message, state: FSMContext, binance: BinanceService) -> None:
        logger.info(f"Collecting symbol for read ticker. Chat ID {message.chat.id}")
        symbol = message.text
        ticker = await binance.get_ticker(symbol)
        await state.set_state(BinanceStates.select_option)
        await message.reply(text=format_ticker(ticker),
                            reply_markup=binance_action_selector(),
                            parse_mode="Markdown")
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def collect_symbol_klines(self, message: Message, state: FSMContext, binance: BinanceService) -> None:
        logger.info(f"Collecting symbol for klines. Chat ID {message.chat.id}")
        symbol = message.text
        klines = await binance.get_klines(symbol)
        await state.set_state(BinanceStates.select_option)
        await message.reply(text=format_klines(klines),
                            reply_markup=binance_action_selector(),
                            parse_mode="Markdown")
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())

    async def collect_symbol_order_book(self, message: Message, state: FSMContext, binance: BinanceService) -> None:
        logger.info(f"Collecting symbol for order book. Chat ID {message.chat.id}")
        symbol = message.text
        order_book = await binance.get_order_book(symbol)
        await state.set_state(BinanceStates.select_option)
        await message.reply(text=format_order_book(order_book),
                            reply_markup=binance_action_selector(),
                            parse_mode="Markdown")
        await message.answer(text=DELIMITER, reply_markup=create_reply_kbd())
