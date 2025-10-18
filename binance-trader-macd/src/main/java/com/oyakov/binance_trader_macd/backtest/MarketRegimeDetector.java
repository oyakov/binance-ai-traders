package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Detects and classifies market regimes from kline data.
 * 
 * Market Regime Classification Criteria:
 * - BULL_TRENDING: Price change > +2% over lookback period, sustained upward movement
 * - BEAR_TRENDING: Price change < -2% over lookback period, sustained downward movement
 * - RANGING: Price change between -2% and +2%, no clear trend
 * - VOLATILE: Intraday price swings > volatilityThreshold (default 5%)
 */
@Component
@Log4j2
public class MarketRegimeDetector {
    
    // Configuration parameters
    private static final int DEFAULT_LOOKBACK_HOURS = 24;
    private static final BigDecimal TREND_THRESHOLD = new BigDecimal("0.02");  // 2%
    private static final BigDecimal VOLATILITY_THRESHOLD = new BigDecimal("0.05");  // 5%
    private static final int MIN_KLINES_FOR_DETECTION = 10;
    
    /**
     * Detects market regimes across a series of klines.
     * Returns a list of regime periods with their classifications.
     */
    public List<RegimePeriod> detectRegimes(List<KlineEvent> klines, int lookbackHours) {
        List<RegimePeriod> regimes = new ArrayList<>();
        
        if (klines == null || klines.size() < MIN_KLINES_FOR_DETECTION) {
            log.warn("Insufficient klines for regime detection (need at least {})", MIN_KLINES_FOR_DETECTION);
            return regimes;
        }
        
        // Calculate the number of klines per lookback period based on interval
        String interval = klines.get(0).getInterval();
        int klinesPerPeriod = calculateKlinesPerPeriod(interval, lookbackHours);
        
        RegimePeriod currentRegime = null;
        
        for (int i = klinesPerPeriod; i < klines.size(); i++) {
            List<KlineEvent> window = klines.subList(i - klinesPerPeriod, i + 1);
            MarketRegime regime = classifyRegime(window);
            
            Instant periodStart = Instant.ofEpochMilli(window.get(0).getOpenTime());
            Instant periodEnd = Instant.ofEpochMilli(window.get(window.size() - 1).getCloseTime());
            
            // If regime changes or this is the first detection, create new period
            if (currentRegime == null || currentRegime.getRegime() != regime) {
                if (currentRegime != null) {
                    regimes.add(currentRegime);
                }
                currentRegime = RegimePeriod.builder()
                        .regime(regime)
                        .startTime(periodStart)
                        .endTime(periodEnd)
                        .startPrice(window.get(0).getOpen())
                        .endPrice(window.get(window.size() - 1).getClose())
                        .build();
            } else {
                // Extend current regime period
                currentRegime.setEndTime(periodEnd);
                currentRegime.setEndPrice(window.get(window.size() - 1).getClose());
            }
        }
        
        // Add final regime
        if (currentRegime != null) {
            regimes.add(currentRegime);
        }
        
        log.info("Detected {} regime periods across {} klines", regimes.size(), klines.size());
        return regimes;
    }
    
    /**
     * Detects regimes using default lookback period (24 hours).
     */
    public List<RegimePeriod> detectRegimes(List<KlineEvent> klines) {
        return detectRegimes(klines, DEFAULT_LOOKBACK_HOURS);
    }
    
    /**
     * Classifies the market regime for a given window of klines.
     */
    private MarketRegime classifyRegime(List<KlineEvent> window) {
        if (window == null || window.isEmpty()) {
            return MarketRegime.UNKNOWN;
        }
        
        BigDecimal startPrice = window.get(0).getOpen();
        BigDecimal endPrice = window.get(window.size() - 1).getClose();
        
        // Calculate price change percentage
        BigDecimal priceChange = endPrice.subtract(startPrice)
                .divide(startPrice, 6, RoundingMode.HALF_UP);
        
        // Calculate volatility (max intraday range)
        BigDecimal maxVolatility = calculateMaxIntradayVolatility(window);
        
        // Classification logic
        if (maxVolatility.compareTo(VOLATILITY_THRESHOLD) > 0) {
            return MarketRegime.VOLATILE;
        } else if (priceChange.compareTo(TREND_THRESHOLD) > 0) {
            return MarketRegime.BULL_TRENDING;
        } else if (priceChange.compareTo(TREND_THRESHOLD.negate()) < 0) {
            return MarketRegime.BEAR_TRENDING;
        } else {
            return MarketRegime.RANGING;
        }
    }
    
    /**
     * Calculates the maximum intraday volatility in the window.
     */
    private BigDecimal calculateMaxIntradayVolatility(List<KlineEvent> window) {
        BigDecimal maxVolatility = BigDecimal.ZERO;
        
        for (KlineEvent kline : window) {
            BigDecimal high = kline.getHigh();
            BigDecimal low = kline.getLow();
            BigDecimal open = kline.getOpen();
            
            if (open.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal range = high.subtract(low);
                BigDecimal volatility = range.divide(open, 6, RoundingMode.HALF_UP);
                
                if (volatility.compareTo(maxVolatility) > 0) {
                    maxVolatility = volatility;
                }
            }
        }
        
        return maxVolatility;
    }
    
    /**
     * Calculates how many klines are in the lookback period based on interval.
     */
    private int calculateKlinesPerPeriod(String interval, int lookbackHours) {
        int minutesPerKline = switch (interval) {
            case "1m" -> 1;
            case "3m" -> 3;
            case "5m" -> 5;
            case "15m" -> 15;
            case "30m" -> 30;
            case "1h" -> 60;
            case "2h" -> 120;
            case "4h" -> 240;
            case "6h" -> 360;
            case "8h" -> 480;
            case "12h" -> 720;
            case "1d" -> 1440;
            default -> 60;  // default to 1h
        };
        
        int lookbackMinutes = lookbackHours * 60;
        return Math.max(MIN_KLINES_FOR_DETECTION, lookbackMinutes / minutesPerKline);
    }
    
    /**
     * Represents a period of time with a consistent market regime.
     */
    @lombok.Data
    @lombok.Builder
    public static class RegimePeriod {
        private MarketRegime regime;
        private Instant startTime;
        private Instant endTime;
        private BigDecimal startPrice;
        private BigDecimal endPrice;
        
        /**
         * Get the duration of this regime period in hours.
         */
        public BigDecimal getDurationHours() {
            Duration duration = Duration.between(startTime, endTime);
            return BigDecimal.valueOf(duration.toHours())
                    .add(BigDecimal.valueOf(duration.toMinutesPart())
                            .divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP));
        }
        
        /**
         * Get the price change percentage during this regime.
         */
        public BigDecimal getPriceChangePercent() {
            if (startPrice == null || endPrice == null || startPrice.compareTo(BigDecimal.ZERO) == 0) {
                return BigDecimal.ZERO;
            }
            return endPrice.subtract(startPrice)
                    .divide(startPrice, 4, RoundingMode.HALF_UP)
                    .multiply(BigDecimal.valueOf(100));
        }
    }
}

