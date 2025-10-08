package com.oyakov.binance_trader_macd.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;

/**
 * Represents a MACD indicator calculation result
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MACDIndicator {
    
    private String symbol;
    private String interval;
    private long timestamp;
    private BigDecimal price;
    private BigDecimal macdLine;
    private BigDecimal signalLine;
    private BigDecimal histogram;
    private String signal; // BUY, SELL, NEUTRAL, ERROR
    private MACDParameters parameters;
    private int dataPoints;
    private Instant calculatedAt;
    private String error; // Error message if calculation failed
    
    /**
     * Get the signal strength based on histogram value
     */
    public SignalStrength getSignalStrength() {
        if (histogram == null) {
            return SignalStrength.NONE;
        }
        
        double absHistogram = histogram.abs().doubleValue();
        
        if (absHistogram > 100) {
            return SignalStrength.STRONG;
        } else if (absHistogram > 50) {
            return SignalStrength.MODERATE;
        } else if (absHistogram > 10) {
            return SignalStrength.WEAK;
        } else {
            return SignalStrength.NONE;
        }
    }
    
    /**
     * Check if this is a valid calculation (no errors)
     */
    public boolean isValid() {
        return error == null || error.isEmpty();
    }
    
    /**
     * Get a summary string for logging
     */
    public String getSummary() {
        return String.format("%s %s: Price=%.2f, MACD=%.4f, Signal=%.4f, Histogram=%.4f, Signal=%s", 
            symbol, interval, price.doubleValue(), macdLine.doubleValue(), 
            signalLine.doubleValue(), histogram.doubleValue(), signal);
    }
    
    public enum SignalStrength {
        NONE, WEAK, MODERATE, STRONG
    }
}
