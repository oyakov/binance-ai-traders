package com.oyakov.binance_trader_grid.api.dto;

public class GridStrategyDto {
    public String id;            // optional on create
    public String symbol;
    public String interval;
    public double lower;
    public double upper;
    public int levels;
    public double baseOrderSize;
    public double dailyLossLimitPct;
    public double maxPositionSizeQuote;
    public boolean active;
}


