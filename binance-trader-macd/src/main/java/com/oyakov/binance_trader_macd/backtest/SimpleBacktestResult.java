package com.oyakov.binance_trader_macd.backtest;

/**
 * Simple result class for real data analysis
 */
public class SimpleBacktestResult {
    private final String symbol;
    private final String interval;
    private final int days;
    private final MACDParameters parameters;
    private final SimpleBacktestMetrics metrics;
    private final String status;
    
    public SimpleBacktestResult(String symbol, String interval, int days, MACDParameters parameters, 
                               SimpleBacktestMetrics metrics, String status) {
        this.symbol = symbol;
        this.interval = interval;
        this.days = days;
        this.parameters = parameters;
        this.metrics = metrics;
        this.status = status;
    }
    
    public String getSymbol() { return symbol; }
    public String getInterval() { return interval; }
    public int getDays() { return days; }
    public MACDParameters getParameters() { return parameters; }
    public SimpleBacktestMetrics getMetrics() { return metrics; }
    public String getStatus() { return status; }
}
