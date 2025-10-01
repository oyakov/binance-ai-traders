package com.oyakov.binance_trader_macd.backtest;

import lombok.Builder;
import lombok.Data;

/**
 * Result wrapper for a single backtest scope (interval + range).
 * Stores the raw {@link BacktestResult} together with contextual metadata
 * that is useful when assembling multi-scope reports.
 */
@Data
@Builder
public class BacktestScopeResult {
    private String interval;
    private int days;
    private BacktestResult result;
    private String headline;
}
