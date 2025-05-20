package com.oyakov.binance_trader_macd.domain;

import com.oyakov.binance_shared_model.avro.KlineEvent;

import java.util.Optional;

public class MacdCalculator {
    private final double alphaShort = 2.0 / (12 + 1);
    private final double alphaLong = 2.0 / (26 + 1);
    private final double alphaSignal = 2.0 / (9 + 1);

    private double emaShort = 0;
    private double emaLong = 0;
    private double macd = 0;
    private double signal = 0;

    public Optional<TradeSignal> update(KlineEvent kline) {
        emaShort = alphaShort * kline.getClose() + (1 - alphaShort) * emaShort;
        emaLong = alphaLong * kline.getClose() + (1 - alphaLong) * emaLong;
        double newMacd = emaShort - emaLong;
        signal = alphaSignal * newMacd + (1 - alphaSignal) * signal;

        TradeSignal decision = null;
        if (macd < signal && newMacd > signal) decision = TradeSignal.BUY;
        else if (macd > signal && newMacd < signal) decision = TradeSignal.SELL;

        macd = newMacd;
        return Optional.ofNullable(decision);
    }
}

