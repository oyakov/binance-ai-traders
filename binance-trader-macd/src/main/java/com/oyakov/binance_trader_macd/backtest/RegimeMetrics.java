package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Metrics for strategy performance within a specific market regime.
 * Tracks profitability, trade statistics, and market characteristics during the regime period.
 */
@Data
@Builder
public class RegimeMetrics {
    // Regime identification
    private MarketRegime regimeType;
    private Instant regimeStartTime;
    private Instant regimeEndTime;
    private BigDecimal regimeDurationHours;
    
    // Trade statistics
    private int tradesCount;
    private int winningTrades;
    private int losingTrades;
    private BigDecimal winRate;
    
    // Profitability metrics
    private BigDecimal netProfit;
    private BigDecimal netProfitPercent;
    private BigDecimal avgProfitPerTrade;
    private BigDecimal maxProfit;
    private BigDecimal maxLoss;
    
    // Risk metrics
    private BigDecimal sharpeRatio;
    private BigDecimal sortinoRatio;
    private BigDecimal maxDrawdown;
    
    // Market characteristics
    private BigDecimal marketReturn;  // Buy-and-hold return during regime
    private BigDecimal strategyVsMarket;  // Strategy outperformance
    private BigDecimal volatilityPercent;
    private BigDecimal priceRangePercent;
    
    // Trade efficiency
    private BigDecimal avgTradeDurationHours;
    private BigDecimal profitFactor;
    
    /**
     * Check if this regime was profitable for the strategy.
     */
    public boolean isProfitable() {
        return netProfit != null && netProfit.compareTo(BigDecimal.ZERO) > 0;
    }
    
    /**
     * Check if the strategy outperformed buy-and-hold in this regime.
     */
    public boolean outperformedMarket() {
        return strategyVsMarket != null && strategyVsMarket.compareTo(BigDecimal.ZERO) > 0;
    }
    
    /**
     * Get a summary description of this regime's performance.
     */
    public String getSummary() {
        return String.format("%s regime (%s hours): %d trades, %.2f%% win rate, %.2f%% profit",
                regimeType.getDisplayName(),
                regimeDurationHours,
                tradesCount,
                winRate.multiply(BigDecimal.valueOf(100)),
                netProfitPercent);
    }
}

