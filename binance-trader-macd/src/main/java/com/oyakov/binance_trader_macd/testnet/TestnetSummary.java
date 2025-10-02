package com.oyakov.binance_trader_macd.testnet;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TestnetSummary {
    private int totalInstances;
    private int activeInstances;
    private String bestPerformer;
    private BigDecimal totalProfit;
    private Instant generatedAt;
}
