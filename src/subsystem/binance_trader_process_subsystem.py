from datetime import datetime

from aiogram import Bot
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from binance import Client
from injector import inject

from db.repository.klines_repository import KlinesRepository
from db.repository.macd_repository import MACDRepository
from db.repository.macd_trend_repository import MACDTrendRepository
from db.repository.order_book_repository import OrderBookRepository
from db.repository.order_repository import OrderRepository
from db.repository.ticker_repository import TickerRepository
from oam import log_config
from service.crypto.binance.binance_service import BinanceService
from service.crypto.indicator_service import IndicatorService, UPWARD, DOWNWARD
from service.os.filesystem_service import FilesystemService
from service.telegram_service import TelegramService
from subsystem.subsystem import Subsystem, InitPriority

logger = log_config.get_logger(__name__)


class BinanceTraderProcessSubsystem(Subsystem):

    @inject
    def __init__(self,
                 bot: Bot,
                 binance_service: BinanceService,
                 indicator_service: IndicatorService,
                 telegram_service : TelegramService,
                 filesystem_service: FilesystemService,
                 order_repository: OrderRepository,
                 klines_repository: KlinesRepository,
                 macd_repository: MACDRepository,
                 macd_trend_repository: MACDTrendRepository,
                 order_book_repository: OrderBookRepository,
                 ticker_repository: TickerRepository):
        self.router = None
        self.bot = bot
        self.binance_service = binance_service
        self.indicator_service = indicator_service
        self.order_repository = order_repository
        self.klines_repository = klines_repository
        self.macd_repository = macd_repository
        self.macd_trend_repository = macd_trend_repository
        self.order_book_repository = order_book_repository
        self.ticker_repository = ticker_repository
        self.long_interval = Client.KLINE_INTERVAL_1HOUR
        self.short_interval = Client.KLINE_INTERVAL_30MINUTE
        self.long_window = 2
        self.short_window = 2
        self.slope_threshold_buy = 1.0
        self.slope_threshold_sell = 0.2
        self.notional = 0.00034
        self.mode = Client.SIDE_BUY
        self.is_initialized = False
        self.current_macd = None
        self.prev_macd = None

    async def initialize(self, subsystem_manager):
        logger.info(f"Initializing Binance Trader Process subsystem {self.bot}")
        scheduler = AsyncIOScheduler()
        await self.trade_cycle("BTCUSDT")
        scheduler.add_job(self.trade_cycle, 'interval', args=["BTCUSDT"], minutes=1)
        scheduler.start()
        logger.info("Advertiser is initialized")
        self.is_initialized = True
        logger.info(f"Binance Trader Process subsystem is initialized")

    async def trade_cycle(self, symbol: str):
        try:
            logger.info(f"Trade cycle engaged")
            # Get our current orders
            open_orders = await self.binance_service.get_open_orders(symbol)

            # Cancel all open (primarily MARKET if any) orders for safety for now
            for order in open_orders:
                logger.info(f"Order exists: {order}")
                try:
                    cancel_result = await self.binance_service.cancel_order(symbol, order['orderId'])
                    logger.info(f"Order cancelled: {cancel_result}")
                except Exception as e:
                    logger.error(f"Error cancelling order", exc_info=e)
            logger.info(f"Open orders: {open_orders}")

            # ==========================================================================================================
            # Read the current state of the market from the database, collected by the data offload subsystem
            # Read the latest MACD data from the database
            # Short term trend analysis
            # ==========================================================================================================

            # Get the latest klines
            klines_15m = await self.klines_repository.get_all_klines(symbol, self.short_interval)
            last_kline = klines_15m.iloc[-1]

            # Calculate MACD
            macd_calculated = await self.indicator_service.calculate_macd(klines_15m, 12, 26, 9)
            if macd_calculated is not None:
                logger.info(f"MACD calculated - last 4 - {macd_calculated.iloc[-4]['histogram']}, {macd_calculated.iloc[-3]['histogram']}, "
                            f"{macd_calculated.iloc[-2]['histogram']}, {macd_calculated.iloc[-1]['histogram']}")
                self.prev_macd = self.current_macd
                self.current_macd = macd_calculated
            else:
                logger.error(f"MACD calculation failed")

            macd_signal_sell, macd_signal_buy = False, False
            if self.current_macd is not None:
                macd_signal_sell, macd_signal_buy = False, False
                if self.current_macd.iloc[-1]['histogram'] > 0 > self.current_macd.iloc[-2]['histogram']:
                    macd_signal_buy = True
                    logger.info("MACD is positive")
                elif self.current_macd.iloc[-1]['histogram'] < 0 < self.current_macd.iloc[-2]['histogram']:
                    macd_signal_sell = True
                    logger.info("MACD is negative")

            # Calculate RSI
            rsi = self.indicator_service.calculate_rsi(klines_15m['close'], 14)
            logger.info(f"RSI calculated: {rsi.iloc[-1]}")
            rsi_signal_sell, rsi_signal_buy = False
            if rsi.iloc[-1] > 70:
                rsi_signal_sell = True
                logger.info("RSI is overbought")
            elif rsi.iloc[-1] < 30:
                rsi_signal_buy = True
                logger.info("RSI is oversold")

            logger.info(f"MACD signals: buy - {macd_signal_buy}, sell - {macd_signal_sell}")
            logger.info(f"RSI signals: buy - {rsi_signal_buy}, sell - {rsi_signal_sell}")
            logger.info(f"Combined signals - buy - {macd_signal_buy and rsi_signal_buy}, "
                        f"sell - {macd_signal_sell and rsi_signal_sell}")

            # Calculate Bollinger bands
            bollinger_bands = self.indicator_service.calculate_bollinger_bands(klines_15m['close'], 20)
            logger.info(f"Bollinger bands calculated: last kline - {klines_15m['close'].iloc[-1]} - upper bb - {bollinger_bands[0].iloc[-1]} "
                        f"- lower bb - {bollinger_bands[1].iloc[-1]}")

            if klines_15m['close'].iloc[-1] > bollinger_bands[0].iloc[-1]:
                logger.info("Price is above the upper Bollinger band")
            elif klines_15m['close'].iloc[-1] < bollinger_bands[1].iloc[-1]:
                logger.info("Price is below the lower Bollinger band")

            # Calculate ATR
            atr = self.indicator_service.calculate_atr(klines_15m['high'], klines_15m['low'], klines_15m['close'], 14)
            logger.info(f"ATR calculated: {atr.iloc[-1]}")

            if atr.iloc[-1] > 0.01:
                logger.info("ATR is above 0.01")
            elif atr.iloc[-1] < 0.01:
                logger.info("ATR is below 0.01")

            macd_histogram = await self.macd_repository.get_latest_macd(symbol, self.short_interval)
            macd_signals = self.indicator_service.generate_signals(macd_histogram)
            macd_lin_regression_2, trend_2 = self.indicator_service.trend_regression(macd_histogram['histogram'], 2)
            macd_lin_regression_3, trend_3 = self.indicator_service.trend_regression(macd_histogram['histogram'], 3)
            logger.info(f"MACD trend: {trend_2} - {macd_lin_regression_2}, {trend_3} - {macd_lin_regression_3}")
            logger.info(f"MACD signals: {macd_signals.iloc[-4]} - {macd_signals.iloc[-3]} "
                        f"- {macd_signals.iloc[-2]} - {macd_signals.iloc[-1]}")

            # Check if the last two values are greater than zero
            if macd_signal_buy and rsi_signal_buy:
                logger.info("Buy condition is satisfied, placing order")
                # Place a buy order
                order = None
                try:
                    order = await self.binance_service.create_order(symbol, Client.SIDE_BUY, Client.ORDER_TYPE_MARKET, self.notional)
                    logger.info(f"Order placed: {order}")
                except Exception as e:
                    logger.error(f"Error placing order", exc_info=e)

                # Save the order to the database
                try:
                    await self.order_repository.write_order(symbol, order)
                except Exception as e:
                    logger.error(f"Error saving order to the database", exc_info=e)
                self.mode = Client.SIDE_SELL
            elif macd_signal_sell and rsi_signal_sell:
                logger.info("Sell condition is statisfied, placing order")
                # Place a sell order
                order = None
                try:
                    order = await self.binance_service.create_order(symbol, Client.SIDE_SELL, Client.ORDER_TYPE_MARKET, self.notional)
                    logger.info(f"Order placed: {order}")
                except Exception as e:
                    logger.error(f"Error placing order", exc_info=e)

                # Save the order to the database
                try:
                    await self.order_repository.write_order(symbol, order)
                except Exception as e:
                    logger.error(f"Error saving order to the database", exc_info=e)
                self.mode = Client.SIDE_BUY
        except Exception as e:
            logger.error(f"Error in trade cycle", exc_info=e)

    def buy_condition_histogram(self, macd_histogram):
        return (self.mode == Client.SIDE_BUY and
                macd_histogram.iloc[-1]['histogram'] > 0 > macd_histogram.iloc[-2]['histogram'])

    def sell_condition_histogram(self, macd_histogram):
        # Fake sell when no buy was committed, need to add a mode table to check if a buy was committed
        return (self.mode == Client.SIDE_SELL and
                macd_histogram.iloc[-1]['histogram'] < 0 < macd_histogram.iloc[-2]['histogram'])

    async def calculate_dynamic_trade_size(self, entry_price: float) -> float:
        """Calculate trade size dynamically based on account equity and/or market conditions."""
        account_info = await self.binance_service.get_account_info()
        account_equity = float(account_info['totalNetAssetOfBtc'])  # Assuming BTC as base currency

        # Example: Risk 1% of account equity per trade
        risk_per_trade = account_equity * 0.01  # 1% risk

        # Calculate quantity based on risk and entry price
        quantity = risk_per_trade / entry_price

        # Additional sizing logic could consider market volatility (ATR)
        return quantity

    async def shutdown(self):
        logger.info(f"Shutting down Binance Trader Process subsystem")

    def get_router(self):
        return self.router

    def get_priority(self):
        return InitPriority.DATA_CONSUMPTION
