package com.oyakov.binance_trader_macd.domain;

public enum OrderState {
    NEW, PENDING, ACTIVE, CLOSED_SL, CLOSED_TP, CLOSED_CANCELED, CLOSED_INVERTED_SIGNAL;

    public static OrderState ofBinanceState(String binanceState) {
        switch (binanceState) {
            case "ACTIVE":
                return ACTIVE;
        }
        return null;
    }
}
