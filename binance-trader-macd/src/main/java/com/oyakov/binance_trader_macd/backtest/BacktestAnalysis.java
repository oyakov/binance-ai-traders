package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Detailed analysis and recommendations based on backtest results.
 */
@Data
@Builder
public class BacktestAnalysis {
    private String summary;
    private List<String> recommendations;
    private String riskAssessment;
}
