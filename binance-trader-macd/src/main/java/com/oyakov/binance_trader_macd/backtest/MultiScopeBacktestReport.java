package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

/**
 * Aggregated report that captures the outcome of evaluating multiple
 * backtest scopes (interval/day combinations) in a single execution.
 */
@Data
@Builder
public class MultiScopeBacktestReport {
    private String symbol;
    private BigDecimal initialCapital;
    private List<BacktestScopeResult> scopeResults;
    private String overallSummary;
    private List<String> keyFindings;
    private List<String> riskWarnings;
    private List<String> nextSteps;
}
