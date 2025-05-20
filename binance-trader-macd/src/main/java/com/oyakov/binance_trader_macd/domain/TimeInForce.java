package com.oyakov.binance_trader_macd.domain;

import lombok.Getter;

@Getter
public enum TimeInForce {
    GTC("GTC");

    private final String value;

    TimeInForce(String value) {
        this.value = value;
    }
}
