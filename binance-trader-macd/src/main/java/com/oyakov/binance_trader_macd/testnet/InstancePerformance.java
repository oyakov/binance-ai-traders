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
public class InstancePerformance {

    private String instanceId;
    private String strategyName;
    private String symbol;
    private String timeframe;
    private int totalTrades;
    private int winningTrades;
    private BigDecimal winRate;
    private BigDecimal totalProfit;
    private BigDecimal maxDrawdown;
    private BigDecimal sharpeRatio;
    private BigDecimal currentBalance;
    private boolean active;
    private Instant lastUpdated;
}
