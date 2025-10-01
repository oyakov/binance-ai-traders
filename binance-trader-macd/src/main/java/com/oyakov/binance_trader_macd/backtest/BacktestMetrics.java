package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.Instant;

@Data
@Builder
public class BacktestMetrics {
    // Basic metrics
    private String datasetName;
    private String symbol;
    private String interval;
    private Instant startTime;
    private Instant endTime;
    private Duration duration;
    
    // Trade statistics
    private int totalTrades;
    private int winningTrades;
    private int losingTrades;
    private int breakEvenTrades;
    
    // Profitability metrics
    private BigDecimal netProfit;
    private BigDecimal netProfitPercent;
    private BigDecimal averageReturn;
    private BigDecimal winRate;
    private BigDecimal lossRate;
    
    // Risk metrics
    private BigDecimal maxDrawdown;
    private BigDecimal maxDrawdownPercent;
    private BigDecimal sharpeRatio;
    private BigDecimal sortinoRatio;
    private BigDecimal profitFactor;
    
    // Trade analysis
    private BigDecimal bestTrade;
    private BigDecimal worstTrade;
    private BigDecimal averageWin;
    private BigDecimal averageLoss;
    private BigDecimal largestWin;
    private BigDecimal largestLoss;
    
    // Consecutive trades
    private int maxConsecutiveWins;
    private int maxConsecutiveLosses;
    private int currentConsecutiveWins;
    private int currentConsecutiveLosses;
    
    // Time analysis
    private BigDecimal averageTradeDurationHours;
    private BigDecimal totalTradingTimeHours;
    private BigDecimal tradingFrequency; // trades per day
    
    // Market analysis
    private BigDecimal initialPrice;
    private BigDecimal finalPrice;
    private BigDecimal marketReturn;
    private BigDecimal strategyOutperformance;
    
    // Additional metrics
    private BigDecimal recoveryFactor;
    private BigDecimal calmarRatio;
    private BigDecimal expectancy;
    private BigDecimal kellyPercentage;
}
