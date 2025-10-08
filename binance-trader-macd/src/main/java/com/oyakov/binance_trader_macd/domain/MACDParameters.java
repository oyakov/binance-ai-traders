package com.oyakov.binance_trader_macd.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * MACD calculation parameters
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MACDParameters {
    
    private int fastPeriod;    // Fast EMA period (default: 12)
    private int slowPeriod;    // Slow EMA period (default: 26)
    private int signalPeriod;  // Signal line EMA period (default: 9)
    
    /**
     * Validate the parameters
     */
    public boolean isValid() {
        return fastPeriod > 0 && slowPeriod > 0 && signalPeriod > 0 && 
               fastPeriod < slowPeriod;
    }
    
    /**
     * Get the minimum data points required for calculation
     */
    public int getMinDataPoints() {
        return slowPeriod + signalPeriod;
    }
    
    @Override
    public String toString() {
        return String.format("MACD(%d,%d,%d)", fastPeriod, slowPeriod, signalPeriod);
    }
}
