package com.oyakov.binance_trader_macd.backtest;

import java.util.Objects;

/**
 * Simple class to hold MACD parameters
 */
public class MACDParameters {
    private final int fastPeriod;
    private final int slowPeriod;
    private final int signalPeriod;
    
    public MACDParameters(int fastPeriod, int slowPeriod, int signalPeriod) {
        this.fastPeriod = fastPeriod;
        this.slowPeriod = slowPeriod;
        this.signalPeriod = signalPeriod;
    }
    
    public int getFastPeriod() { return fastPeriod; }
    public int getSlowPeriod() { return slowPeriod; }
    public int getSignalPeriod() { return signalPeriod; }
    
    @Override
    public String toString() {
        return String.format("MACD(%d,%d,%d)", fastPeriod, slowPeriod, signalPeriod);
    }
    
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (obj == null || getClass() != obj.getClass()) return false;
        MACDParameters that = (MACDParameters) obj;
        return fastPeriod == that.fastPeriod && 
               slowPeriod == that.slowPeriod && 
               signalPeriod == that.signalPeriod;
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(fastPeriod, slowPeriod, signalPeriod);
    }
}
