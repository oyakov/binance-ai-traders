package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.Builder;
import lombok.Data;

import java.util.List;

/**
 * Comprehensive result of a backtesting run, containing all metrics, analysis, and trade details.
 */
@Data
@Builder
public class BacktestResult {
    private BacktestDataset dataset;
    private BacktestMetrics metrics;
    private BacktestAnalysis analysis;
    private List<SimulatedTrade> trades;
    private boolean success;
}
