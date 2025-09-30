package com.oyakov.binance_trader_macd.domain;

public enum OrderState {
    NEW, PENDING, ACTIVE, CLOSED_SL, CLOSED_TP, CLOSED_CANCELED, CLOSED_INVERTED_SIGNAL;

    public static OrderState ofBinanceState(String binanceState) {
        if (binanceState == null) {
            throw new IllegalArgumentException("Binance state cannot be null");
        }

        return switch (binanceState.toUpperCase()) {
            case "NEW" -> NEW;
            case "PARTIALLY_FILLED", "ACTIVE" -> ACTIVE;
            case "PENDING_NEW", "PENDING_CANCEL" -> PENDING;
            case "FILLED" -> CLOSED_TP;
            case "CANCELED" -> CLOSED_CANCELED;
            case "REJECTED", "EXPIRED", "EXPIRED_IN_MATCH" -> CLOSED_CANCELED;
            default -> throw new IllegalArgumentException("Unsupported Binance order state: " + binanceState);
        };
    }
}
