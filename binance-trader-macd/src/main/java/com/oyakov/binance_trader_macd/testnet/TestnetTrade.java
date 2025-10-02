package com.oyakov.binance_trader_macd.testnet;

import lombok.Builder;
import lombok.Value;

import java.math.BigDecimal;
import java.time.Instant;

@Value
@Builder
public class TestnetTrade {
    String symbol;
    BigDecimal profit;
    boolean win;
    Instant executedAt;
}
