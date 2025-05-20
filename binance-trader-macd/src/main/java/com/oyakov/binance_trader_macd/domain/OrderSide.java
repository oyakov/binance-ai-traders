package com.oyakov.binance_trader_macd.domain;

import lombok.Getter;

@Getter
public enum OrderSide {

    BUY("BUY"), SELL("SELL");

    private final String value;

    OrderSide(String value) {
        this.value = value;
    }

    public OrderSide oppositeSide() {
        return (this == OrderSide.BUY) ? OrderSide.SELL : OrderSide.BUY;
    }
}
