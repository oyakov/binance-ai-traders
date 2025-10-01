package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;

interface BacktestOrderContext {

    void onKline(KlineEvent klineEvent);
}
