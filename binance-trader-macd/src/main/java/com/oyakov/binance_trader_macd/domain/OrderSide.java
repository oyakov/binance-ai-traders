package com.oyakov.binance_trader_macd.domain;

import lombok.Getter;

@Getter
public enum OrderSide {

    BUY("BUY"), SELL("SELL");

    private final String value;

    OrderSide(String value) {
        this.value = value;
    }

    public static OrderSide of(TradeSignal signal) {
        return switch (signal) {
            case TradeSignal.BUY -> BUY;
            case TradeSignal.SELL -> SELL;
            default -> throw new IllegalArgumentException("Couldn't process Trade Signal");
        };
    }

    public OrderSide oppositeSide() {
        return (this == OrderSide.BUY) ? OrderSide.SELL : OrderSide.BUY;
    }
}
