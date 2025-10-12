package com.oyakov.binance_trader_grid.grid;

/**
 * Simple container for grid risk limits.
 */
public final class RiskLimits {
    private final double dailyLossLimitPct;
    private final double maxPositionSizeQuote;

    public RiskLimits(double dailyLossLimitPct, double maxPositionSizeQuote) {
        if (dailyLossLimitPct < 0 || maxPositionSizeQuote < 0) {
            throw new IllegalArgumentException("limits must be non-negative");
        }
        this.dailyLossLimitPct = dailyLossLimitPct;
        this.maxPositionSizeQuote = maxPositionSizeQuote;
    }

    public double dailyLossLimitPct() { return dailyLossLimitPct; }
    public double maxPositionSizeQuote() { return maxPositionSizeQuote; }
}


