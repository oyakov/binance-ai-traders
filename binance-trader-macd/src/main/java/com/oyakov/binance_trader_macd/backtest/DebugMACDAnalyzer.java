package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Debug version of MACD analyzer with detailed logging
 */
public class DebugMACDAnalyzer {
    
    private static final int SCALE = 10;
    
    public List<MACDSignal> analyzeSignals(List<KlineEvent> klines, MACDParameters params) {
        System.out.println("=== DEBUG MACD ANALYSIS ===");
        System.out.println("Input data: " + klines.size() + " klines");
        System.out.println("Parameters: " + params.toString());
        
        if (klines.size() < params.getSlowPeriod() + params.getSignalPeriod()) {
            System.out.println("ERROR: Insufficient data. Need " + (params.getSlowPeriod() + params.getSignalPeriod()) + 
                             " klines, got " + klines.size());
            return Collections.emptyList();
        }
        
        List<KlineEvent> sorted = klines.stream()
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .collect(Collectors.toList());
        
        List<BigDecimal> closes = sorted.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());
        
        System.out.println("Price range: " + closes.get(0) + " to " + closes.get(closes.size() - 1));
        
        // Calculate EMAs
        BigDecimal fastMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getFastPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        BigDecimal slowMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getSlowPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        BigDecimal signalMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getSignalPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        
        System.out.println("Multipliers - Fast: " + fastMultiplier + ", Slow: " + slowMultiplier + ", Signal: " + signalMultiplier);
        
        List<BigDecimal> emaFast = calculateEMA(closes, params.getFastPeriod(), fastMultiplier);
        List<BigDecimal> emaSlow = calculateEMA(closes, params.getSlowPeriod(), slowMultiplier);
        
        System.out.println("EMA Fast size: " + emaFast.size() + ", EMA Slow size: " + emaSlow.size());
        if (!emaFast.isEmpty()) {
            System.out.println("EMA Fast range: " + emaFast.get(0) + " to " + emaFast.get(emaFast.size() - 1));
        }
        if (!emaSlow.isEmpty()) {
            System.out.println("EMA Slow range: " + emaSlow.get(0) + " to " + emaSlow.get(emaSlow.size() - 1));
        }
        
        // Align EMAs
        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) {
            System.out.println("ERROR: EMA alignment failed. Fast: " + emaFast.size() + ", Slow: " + emaSlow.size());
            return Collections.emptyList();
        }
        
        System.out.println("EMA offset: " + offset);
        
        List<BigDecimal> alignedFast = emaFast.stream()
                .skip(offset)
                .collect(Collectors.toList());
        
        System.out.println("Aligned Fast size: " + alignedFast.size());
        
        // Calculate MACD line
        List<BigDecimal> macd = new ArrayList<>();
        for (int i = 0; i < emaSlow.size(); i++) {
            BigDecimal macdValue = alignedFast.get(i).subtract(emaSlow.get(i))
                    .setScale(SCALE, RoundingMode.HALF_UP);
            macd.add(macdValue);
        }
        
        System.out.println("MACD line size: " + macd.size());
        if (!macd.isEmpty()) {
            System.out.println("MACD range: " + macd.get(0) + " to " + macd.get(macd.size() - 1));
        }
        
        // Calculate signal line
        List<BigDecimal> signalLine = calculateEMA(macd, params.getSignalPeriod(), signalMultiplier);
        
        System.out.println("Signal line size: " + signalLine.size());
        if (!signalLine.isEmpty()) {
            System.out.println("Signal line range: " + signalLine.get(0) + " to " + signalLine.get(signalLine.size() - 1));
        }
        
        // Generate signals
        List<MACDSignal> signals = new ArrayList<>();
        System.out.println("Checking for signal crossovers...");
        
        for (int i = 1; i < signalLine.size(); i++) {
            BigDecimal prevDiff = macd.get(i - 1).subtract(signalLine.get(i - 1));
            BigDecimal currDiff = macd.get(i).subtract(signalLine.get(i));
            
            if (i <= 5 || i >= signalLine.size() - 5) { // Log first and last few iterations
                System.out.println("  Iteration " + i + ": prevDiff=" + prevDiff + ", currDiff=" + currDiff);
            }
            
            SignalType signalType = null;
            if (prevDiff.compareTo(BigDecimal.ZERO) <= 0 && currDiff.compareTo(BigDecimal.ZERO) > 0) {
                signalType = SignalType.BUY;
                System.out.println("  BUY signal at iteration " + i + ": prevDiff=" + prevDiff + ", currDiff=" + currDiff);
            } else if (prevDiff.compareTo(BigDecimal.ZERO) >= 0 && currDiff.compareTo(BigDecimal.ZERO) < 0) {
                signalType = SignalType.SELL;
                System.out.println("  SELL signal at iteration " + i + ": prevDiff=" + prevDiff + ", currDiff=" + currDiff);
            }
            
            if (signalType != null) {
                // Find corresponding kline
                int klineIndex = offset + i;
                if (klineIndex < sorted.size()) {
                    KlineEvent kline = sorted.get(klineIndex);
                    signals.add(new MACDSignal(
                        kline.getCloseTime(),
                        kline.getClose(),
                        signalType
                    ));
                }
            }
        }
        
        System.out.println("Generated " + signals.size() + " signals");
        System.out.println("=== END DEBUG MACD ANALYSIS ===\n");
        
        return signals;
    }
    
    private List<BigDecimal> calculateEMA(List<BigDecimal> values, int period, BigDecimal multiplier) {
        if (values.size() < period) return Collections.emptyList();
        
        BigDecimal initialAvg = values.stream()
                .limit(period)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .divide(BigDecimal.valueOf(period), SCALE, RoundingMode.HALF_UP);
        
        List<BigDecimal> ema = new ArrayList<>(values.size() - period + 1);
        ema.add(initialAvg);
        
        values.stream()
                .skip(period)
                .forEach(value -> {
                    BigDecimal prev = ema.get(ema.size() - 1);
                    BigDecimal next = value.subtract(prev)
                            .multiply(multiplier)
                            .add(prev)
                            .setScale(SCALE, RoundingMode.HALF_UP);
                    ema.add(next);
                });
        
        return ema;
    }
    
    public static class MACDSignal {
        private final long timestamp;
        private final BigDecimal price;
        private final SignalType signal;
        
        public MACDSignal(long timestamp, BigDecimal price, SignalType signal) {
            this.timestamp = timestamp;
            this.price = price;
            this.signal = signal;
        }
        
        public long getTimestamp() { return timestamp; }
        public BigDecimal getPrice() { return price; }
        public SignalType getSignal() { return signal; }
    }
    
    public enum SignalType {
        BUY, SELL
    }
}
