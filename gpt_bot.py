import logging
from aiogram import Bot, Dispatcher, types
from aiogram.types import InlineKeyboardButton, InlineKeyboardMarkup, CallbackQuery
from aiogram.fsm.context import FSMContext
from aiogram.fsm.middleware.logging import LoggingMiddleware
from aiogram.fsm.storage.memory import MemoryStorage
from aiogram.dispatcher.filters.state import StatesGroup, State
from aiogram.utils import executor

API_TOKEN = 'YOUR_BOT_TOKEN'

logging.basicConfig(level=logging.INFO)

bot = Bot(token=API_TOKEN)
storage = MemoryStorage()
dp = Dispatcher(bot, storage=storage)
dp.middleware.setup(LoggingMiddleware())

class ConfigState(StatesGroup):
    choosing_channel = State()
    choosing_interval_type = State()
    choosing_days = State()
    choosing_hours = State()

config = {
    'channel': None,
    'days': [],
    'hours': [],
}

@dp.message_handler(commands='start', state='*')
async def start(message: types.Message):
    keyboard = [
        [InlineKeyboardButton("Channel 1", callback_data='channel_1')],
        [InlineKeyboardButton("Channel 2", callback_data='channel_2')],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await message.answer("Please choose the channel:", reply_markup=reply_markup)
    await ConfigState.choosing_channel.set()

@dp.callback_query_handler(state=ConfigState.choosing_channel)
async def choosing_channel(call: CallbackQuery, state: FSMContext):
    config['channel'] = call.data
    keyboard = [
        [InlineKeyboardButton("Days of the month", callback_data='days')],
        [InlineKeyboardButton("Hours of the day", callback_data='hours')],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await call.message.edit_text(f"Channel {call.data} selected. Please choose the interval type:", reply_markup=reply_markup)
    await ConfigState.choosing_interval_type.set()

@dp.callback_query_handler(state=ConfigState.choosing_interval_type)
async def choosing_interval_type(call: CallbackQuery, state: FSMContext):
    if call.data == 'days':
        await choosing_days(call, state)
    elif call.data == 'hours':
        await choosing_hours(call, state)

async def choosing_days(call: CallbackQuery, state: FSMContext):
    keyboard = [
        [InlineKeyboardButton(f"{i}", callback_data=f"day_{i}") for i in range(1, 32)],
        [InlineKeyboardButton("Switch to hours", callback_data='switch_hours')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await call.message.edit_text("Please choose the days of the month:", reply_markup=reply_markup)
    await ConfigState.choosing_days.set()

async def choosing_hours(call: CallbackQuery, state: FSMContext):
    keyboard = [
        [InlineKeyboardButton(f"{i}:00", callback_data=f"hour_{i}") for i in range(24)],
        [InlineKeyboardButton("Switch to days", callback_data='switch_days')]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    await call.message.edit_text("Please choose the hours of the day:", reply_markup=reply_markup)
    await ConfigState.choosing_hours.set()

@dp.callback_query_handler(lambda call: call.data.startswith('day_'), state=ConfigState.choosing_days)
async def handle_days(call: CallbackQuery, state: FSMContext):
    day = int(call.data.split('_')[1])
    if day in config['days']:
        config['days'].remove(day)
    else:
        config['days'].append(day)
    await choosing_days(call, state)

@dp.callback_query_handler(lambda call: call.data.startswith('hour_'), state=ConfigState.choosing_hours)
async def handle_hours(call: CallbackQuery, state: FSMContext):
    hour = int(call.data.split('_')[1])
    if hour in config['hours']:
        config['hours'].remove(hour)
    else:
        config['hours'].append(hour)
    await choosing_hours(call, state)

@dp.callback_query_handler(lambda call: call.data == 'switch_days', state=ConfigState.choosing_hours)
async def switch_to_days(call: CallbackQuery, state: FSMContext):
    await choosing_days(call, state)

@dp.callback_query_handler(lambda call: call.data == 'switch_hours', state=ConfigState.choosing_days)
async def switch_to_hours(call: CallbackQuery, state: FSMContext):
    await choosing_hours(call, state)

@dp.message_handler(commands='cancel', state='*')
async def cancel(message: types.Message, state: FSMContext):
    await state.finish()
    await message.reply('Configuration canceled.')

if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)
