package com.oyakov.binance_trader_macd.domain.signal;

import com.oyakov.binance_trader_macd.domain.TradeSignal;

import java.util.Optional;

public interface SignalAnalyzer<T> {
    Optional<TradeSignal> tryExtractSignal(Iterable<T> data);
}
