package com.oyakov.binance_trader_macd.backtest;

import java.math.BigDecimal;

/**
 * Simple metrics class for real data analysis
 */
public class SimpleBacktestMetrics {
    private final BigDecimal netProfitPercent;
    private final BigDecimal sharpeRatio;
    private final BigDecimal winRate;
    private final BigDecimal maxDrawdownPercent;
    private final int totalTrades;
    
    public SimpleBacktestMetrics(BigDecimal netProfitPercent, BigDecimal sharpeRatio, 
                                BigDecimal winRate, BigDecimal maxDrawdownPercent, int totalTrades) {
        this.netProfitPercent = netProfitPercent;
        this.sharpeRatio = sharpeRatio;
        this.winRate = winRate;
        this.maxDrawdownPercent = maxDrawdownPercent;
        this.totalTrades = totalTrades;
    }
    
    public BigDecimal getNetProfitPercent() { return netProfitPercent; }
    public BigDecimal getSharpeRatio() { return sharpeRatio; }
    public BigDecimal getWinRate() { return winRate; }
    public BigDecimal getMaxDrawdownPercent() { return maxDrawdownPercent; }
    public int getTotalTrades() { return totalTrades; }
}
