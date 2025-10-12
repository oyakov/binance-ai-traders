package com.oyakov.binance_trader_grid.grid;

/**
 * Immutable price band defining the lower/upper bounds of a grid.
 */
public final class PriceRange {
    private final double lower;
    private final double upper;

    public PriceRange(double lower, double upper) {
        if (lower <= 0 || upper <= 0) {
            throw new IllegalArgumentException("Prices must be positive");
        }
        if (upper <= lower) {
            throw new IllegalArgumentException("upper must be > lower");
        }
        this.lower = lower;
        this.upper = upper;
    }

    public double lower() { return lower; }
    public double upper() { return upper; }
    public double width() { return upper - lower; }
}


