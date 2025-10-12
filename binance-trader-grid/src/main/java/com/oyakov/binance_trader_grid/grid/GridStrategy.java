package com.oyakov.binance_trader_grid.grid;

/**
 * Minimal grid strategy immutable configuration.
 */
public final class GridStrategy {
    private final String id;
    private final String symbol;
    private final String interval;
    private final GridPlan plan;
    private final RiskLimits risk;

    public GridStrategy(String id, String symbol, String interval, GridPlan plan, RiskLimits risk) {
        this.id = id;
        this.symbol = symbol;
        this.interval = interval;
        this.plan = plan;
        this.risk = risk;
    }

    public String id() { return id; }
    public String symbol() { return symbol; }
    public String interval() { return interval; }
    public GridPlan plan() { return plan; }
    public RiskLimits risk() { return risk; }
}


