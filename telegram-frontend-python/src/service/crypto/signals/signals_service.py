from oam import log_config

logger = log_config.get_logger(__name__)


class SignalsService:

    def __init__(self):
        logger.info("Signals service initialized")
        self.current_macd = None
        self.prev_macd = None


    async def calculate_macd_signals(self, macd_calculated):
        if macd_calculated is not None:
            logger.info(
                f"MACD calculated - last 4 - {macd_calculated.iloc[-4]['histogram']}, {macd_calculated.iloc[-3]['histogram']}, "
                f"{macd_calculated.iloc[-2]['histogram']}, {macd_calculated.iloc[-1]['histogram']}")
            self.prev_macd = self.current_macd
            self.current_macd = macd_calculated
        else:
            logger.error(f"MACD calculation failed")
        macd_signal_sell, macd_signal_buy = False, False
        if self.current_macd is not None:
            macd_signal_sell, macd_signal_buy = False, False
            if (self.current_macd.iloc[-1]['histogram'] > 0 and
                    (self.current_macd.iloc[-2]['histogram'] < 0 or
                     self.current_macd.iloc[-3]['histogram'] < 0)): # Add this condition for more flexibility
                macd_signal_buy = True
                logger.info("MACD is positive")
            elif (self.current_macd.iloc[-1]['histogram'] < 0 and
                  (self.current_macd.iloc[-2]['histogram'] > 0 or
                   self.current_macd.iloc[-3]['histogram'] > 0)): # Add this condition for more flexibility
                macd_signal_sell = True
                logger.info("MACD is negative")
        return macd_signal_buy, macd_signal_sell

    async def calculate_rsi_signals(self, rsi):
        logger.info(f"RSI calculated: {rsi.iloc[-1]}")
        rsi_signal_sell, rsi_signal_buy = False, False
        if rsi.iloc[-1] > 70:
            rsi_signal_sell = True
            logger.info("RSI is overbought")
        elif rsi.iloc[-1] < 30:
            rsi_signal_buy = True
            logger.info("RSI is oversold")
        return rsi_signal_buy, rsi_signal_sell