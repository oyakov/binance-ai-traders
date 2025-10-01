package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Custom MACD analyzer that accepts parameters
 */
public class CustomMACDAnalyzer {
    
    private static final int SCALE = 10;
    
    public List<MACDSignal> analyzeSignals(List<KlineEvent> klines, MACDParameters params) {
        if (klines.size() < params.getSlowPeriod() + params.getSignalPeriod()) {
            return Collections.emptyList();
        }
        
        List<KlineEvent> sorted = klines.stream()
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .collect(Collectors.toList());
        
        List<BigDecimal> closes = sorted.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());
        
        // Calculate EMAs
        BigDecimal fastMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getFastPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        BigDecimal slowMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getSlowPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        BigDecimal signalMultiplier = BigDecimal.valueOf(2)
                .divide(BigDecimal.valueOf(params.getSignalPeriod() + 1), SCALE, RoundingMode.HALF_UP);
        
        List<BigDecimal> emaFast = calculateEMA(closes, params.getFastPeriod(), fastMultiplier);
        List<BigDecimal> emaSlow = calculateEMA(closes, params.getSlowPeriod(), slowMultiplier);
        
        // Align EMAs
        int offset = emaFast.size() - emaSlow.size();
        if (offset < 0) {
            return Collections.emptyList();
        }
        
        List<BigDecimal> alignedFast = emaFast.stream()
                .skip(offset)
                .collect(Collectors.toList());
        
        // Calculate MACD line
        List<BigDecimal> macd = new ArrayList<>();
        for (int i = 0; i < emaSlow.size(); i++) {
            macd.add(alignedFast.get(i).subtract(emaSlow.get(i))
                    .setScale(SCALE, RoundingMode.HALF_UP));
        }
        
        // Calculate signal line
        List<BigDecimal> signalLine = calculateEMA(macd, params.getSignalPeriod(), signalMultiplier);
        
        // Generate signals
        List<MACDSignal> signals = new ArrayList<>();
        for (int i = 1; i < signalLine.size(); i++) {
            BigDecimal prevDiff = macd.get(i - 1).subtract(signalLine.get(i - 1));
            BigDecimal currDiff = macd.get(i).subtract(signalLine.get(i));
            
            SignalType signalType = null;
            if (prevDiff.compareTo(BigDecimal.ZERO) <= 0 && currDiff.compareTo(BigDecimal.ZERO) > 0) {
                signalType = SignalType.BUY;
            } else if (prevDiff.compareTo(BigDecimal.ZERO) >= 0 && currDiff.compareTo(BigDecimal.ZERO) < 0) {
                signalType = SignalType.SELL;
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
