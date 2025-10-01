package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class BacktestMetrics {
    private String datasetName;
    private int totalTrades;
    private int winningTrades;
    private int losingTrades;
    private int breakEvenTrades;
    private BigDecimal netProfit;
    private BigDecimal averageReturn;
    private BigDecimal winRate;
    private BigDecimal maxDrawdown;
    private BigDecimal maxDrawdownPercent;
    private BigDecimal bestTrade;
    private BigDecimal worstTrade;
}
