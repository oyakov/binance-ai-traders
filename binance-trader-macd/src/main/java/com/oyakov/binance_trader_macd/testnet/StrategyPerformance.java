package com.oyakov.binance_trader_macd.testnet;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StrategyPerformance {
    private String strategyName;
    private BigDecimal averageProfit;
    private BigDecimal averageSharpeRatio;
    private BigDecimal averageWinRate;
    private BigDecimal consistency;
}
