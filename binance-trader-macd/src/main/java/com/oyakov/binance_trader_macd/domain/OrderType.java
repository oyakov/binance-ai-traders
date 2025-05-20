package com.oyakov.binance_trader_macd.domain;

import lombok.Getter;

@Getter
public enum OrderType {
    LIMIT("LIMIT"),
    MARKET("MARKET"),
    STOP_LOSS("STOP_LOSS"),
    STOP_LOSS_LIMIT("STOP_LOSS_LIMIT"),
    TAKE_PROFIT("TAKE_PROFIT"),
    TAKE_PROFIT_LIMIT("TAKE_PROFIT_LIMIT"),
    LIMIT_MAKER("LIMIT_MAKER");

    private final String value;

    OrderType(String value) {
        this.value = value;
    }
}
