package com.oyakov.binance_trader_macd.testnet;

import com.oyakov.binance_trader_macd.domain.TradeSignal;
import com.oyakov.binance_trader_macd.rest.dto.BinanceOrderResponse;
import lombok.Builder;
import lombok.Value;

import java.math.BigDecimal;
import java.time.Instant;

@Value
@Builder
public class TestnetTrade {
    String instanceId;
    String symbol;
    BigDecimal profit;
    boolean win;
    Instant executedAt;
    TradeSignal signal;
    BinanceOrderResponse orderResponse;
    Instant timestamp;
}
