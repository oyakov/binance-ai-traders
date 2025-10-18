package com.oyakov.binance_trader_macd.backtest;

/**
 * Enumeration of different market regime types.
 * Used to classify market conditions and analyze strategy performance per regime.
 */
public enum MarketRegime {
    /**
     * Bull Trending: Price consistently rising over period
     * Criteria: Price change > +2% over 24h, sustained upward movement
     */
    BULL_TRENDING("Bull Trending", "Price consistently rising with sustained upward momentum"),
    
    /**
     * Bear Trending: Price consistently falling over period
     * Criteria: Price change < -2% over 24h, sustained downward movement
     */
    BEAR_TRENDING("Bear Trending", "Price consistently falling with sustained downward momentum"),
    
    /**
     * Ranging: Price oscillating within narrow band
     * Criteria: Price change between -2% and +2% over 24h, no clear trend
     */
    RANGING("Ranging", "Price oscillating within a narrow range without clear direction"),
    
    /**
     * Volatile: High price swings regardless of direction
     * Criteria: Intraday price moves > 5%, high volatility
     */
    VOLATILE("Volatile", "High price swings and significant intraday volatility"),
    
    /**
     * Unknown: Unable to classify or insufficient data
     */
    UNKNOWN("Unknown", "Market condition could not be determined");
    
    private final String displayName;
    private final String description;
    
    MarketRegime(String displayName, String description) {
        this.displayName = displayName;
        this.description = description;
    }
    
    public String getDisplayName() {
        return displayName;
    }
    
    public String getDescription() {
        return description;
    }
    
    /**
     * Check if this regime is a trending regime (bull or bear).
     */
    public boolean isTrending() {
        return this == BULL_TRENDING || this == BEAR_TRENDING;
    }
    
    /**
     * Check if this is a bullish regime.
     */
    public boolean isBullish() {
        return this == BULL_TRENDING;
    }
    
    /**
     * Check if this is a bearish regime.
     */
    public boolean isBearish() {
        return this == BEAR_TRENDING;
    }
    
    /**
     * Check if this is a ranging (sideways) regime.
     */
    public boolean isRanging() {
        return this == RANGING;
    }
    
    /**
     * Check if this is a volatile regime.
     */
    public boolean isVolatile() {
        return this == VOLATILE;
    }
    
    @Override
    public String toString() {
        return displayName;
    }
}

