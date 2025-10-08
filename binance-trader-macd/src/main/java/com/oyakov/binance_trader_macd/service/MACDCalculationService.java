package com.oyakov.binance_trader_macd.service;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.domain.MACDIndicator;
import com.oyakov.binance_trader_macd.domain.MACDParameters;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Service for calculating MACD indicators from kline data.
 * Provides real-time MACD calculations and exposes them through metrics and APIs.
 */
@Service
@RequiredArgsConstructor
@Log4j2
public class MACDCalculationService {

    private final KlineDataAccessService klineDataAccessService;
    
    private static final int SCALE = 10;
    private static final MACDParameters DEFAULT_PARAMS = new MACDParameters(12, 26, 9);

    /**
     * Calculate MACD indicators for a specific symbol and interval
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "5m", "1h", "1d")
     * @param params MACD calculation parameters
     * @return MACDIndicator containing all calculated values
     */
    public MACDIndicator calculateMACD(String symbol, String interval, MACDParameters params) {
        log.debug("Calculating MACD for {} {} with params: {}", symbol, interval, params);
        
        try {
            // Fetch recent klines from database
            List<KlineEvent> klines = klineDataAccessService.getRecentKlines(symbol, interval, 100);
            
            if (klines.size() < params.getSlowPeriod() + params.getSignalPeriod()) {
                log.warn("Insufficient data for MACD calculation: {} klines available, need at least {}", 
                    klines.size(), params.getSlowPeriod() + params.getSignalPeriod());
                return createEmptyIndicator(symbol, interval, "Insufficient data");
            }
            
            // Sort klines by close time
            List<KlineEvent> sortedKlines = klines.stream()
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .collect(Collectors.toList());
            
            // Extract close prices
            List<BigDecimal> closes = sortedKlines.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());
            
            // Calculate EMAs
            BigDecimal fastMultiplier = calculateEMAMultiplier(params.getFastPeriod());
            BigDecimal slowMultiplier = calculateEMAMultiplier(params.getSlowPeriod());
            BigDecimal signalMultiplier = calculateEMAMultiplier(params.getSignalPeriod());
            
            List<BigDecimal> emaFast = calculateEMA(closes, params.getFastPeriod(), fastMultiplier);
            List<BigDecimal> emaSlow = calculateEMA(closes, params.getSlowPeriod(), slowMultiplier);
            
            // Align EMAs
            int offset = emaFast.size() - emaSlow.size();
            if (offset < 0) {
                log.error("EMA alignment error: fast={}, slow={}", emaFast.size(), emaSlow.size());
                return createEmptyIndicator(symbol, interval, "EMA alignment error");
            }
            
            List<BigDecimal> alignedFast = emaFast.stream()
                .skip(offset)
                .collect(Collectors.toList());
            
            // Calculate MACD line
            List<BigDecimal> macdLine = new ArrayList<>();
            for (int i = 0; i < emaSlow.size(); i++) {
                macdLine.add(alignedFast.get(i).subtract(emaSlow.get(i))
                    .setScale(SCALE, RoundingMode.HALF_UP));
            }
            
            // Calculate signal line
            List<BigDecimal> signalLine = calculateEMA(macdLine, params.getSignalPeriod(), signalMultiplier);
            
            // Calculate histogram
            List<BigDecimal> histogram = new ArrayList<>();
            int histogramOffset = macdLine.size() - signalLine.size();
            for (int i = 0; i < signalLine.size(); i++) {
                int macdIndex = histogramOffset + i;
                if (macdIndex < macdLine.size()) {
                    histogram.add(macdLine.get(macdIndex).subtract(signalLine.get(i))
                        .setScale(SCALE, RoundingMode.HALF_UP));
                }
            }
            
            // Get latest values
            BigDecimal latestMACD = macdLine.isEmpty() ? BigDecimal.ZERO : macdLine.get(macdLine.size() - 1);
            BigDecimal latestSignal = signalLine.isEmpty() ? BigDecimal.ZERO : signalLine.get(signalLine.size() - 1);
            BigDecimal latestHistogram = histogram.isEmpty() ? BigDecimal.ZERO : histogram.get(histogram.size() - 1);
            BigDecimal latestPrice = closes.isEmpty() ? BigDecimal.ZERO : closes.get(closes.size() - 1);
            
            // Determine signal
            String signal = determineSignal(macdLine, signalLine);
            
            // Get corresponding timestamps
            long latestTimestamp = sortedKlines.isEmpty() ? System.currentTimeMillis() : 
                sortedKlines.get(sortedKlines.size() - 1).getCloseTime();
            
            log.info("MACD calculated for {} {}: MACD={}, Signal={}, Histogram={}, SignalType={}", 
                symbol, interval, latestMACD, latestSignal, latestHistogram, signal);
            
            return MACDIndicator.builder()
                .symbol(symbol)
                .interval(interval)
                .timestamp(latestTimestamp)
                .price(latestPrice)
                .macdLine(latestMACD)
                .signalLine(latestSignal)
                .histogram(latestHistogram)
                .signal(signal)
                .parameters(params)
                .dataPoints(klines.size())
                .calculatedAt(Instant.now())
                .build();
                
        } catch (Exception e) {
            log.error("Error calculating MACD for {} {}", symbol, interval, e);
            return createEmptyIndicator(symbol, interval, "Calculation error: " + e.getMessage());
        }
    }
    
    /**
     * Calculate MACD with default parameters
     */
    public MACDIndicator calculateMACD(String symbol, String interval) {
        return calculateMACD(symbol, interval, DEFAULT_PARAMS);
    }
    
    /**
     * Calculate MACD for multiple symbols
     */
    public List<MACDIndicator> calculateMACDForSymbols(List<String> symbols, String interval, MACDParameters params) {
        return symbols.parallelStream()
            .map(symbol -> calculateMACD(symbol, interval, params))
            .collect(Collectors.toList());
    }
    
    /**
     * Calculate MACD for multiple symbols with default parameters
     */
    public List<MACDIndicator> calculateMACDForSymbols(List<String> symbols, String interval) {
        return calculateMACDForSymbols(symbols, interval, DEFAULT_PARAMS);
    }
    
    /**
     * Get historical MACD data for a symbol
     */
    public List<MACDIndicator> getHistoricalMACD(String symbol, String interval, int limit, MACDParameters params) {
        log.debug("Getting historical MACD for {} {} with limit {}", symbol, interval, limit);
        
        try {
            List<KlineEvent> klines = klineDataAccessService.getRecentKlines(symbol, interval, limit);
            
            if (klines.size() < params.getSlowPeriod() + params.getSignalPeriod()) {
                return Collections.emptyList();
            }
            
            List<KlineEvent> sortedKlines = klines.stream()
                .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                .collect(Collectors.toList());
            
            List<BigDecimal> closes = sortedKlines.stream()
                .map(KlineEvent::getClose)
                .collect(Collectors.toList());
            
            // Calculate all indicators
            BigDecimal fastMultiplier = calculateEMAMultiplier(params.getFastPeriod());
            BigDecimal slowMultiplier = calculateEMAMultiplier(params.getSlowPeriod());
            BigDecimal signalMultiplier = calculateEMAMultiplier(params.getSignalPeriod());
            
            List<BigDecimal> emaFast = calculateEMA(closes, params.getFastPeriod(), fastMultiplier);
            List<BigDecimal> emaSlow = calculateEMA(closes, params.getSlowPeriod(), slowMultiplier);
            
            int offset = emaFast.size() - emaSlow.size();
            if (offset < 0) {
                return Collections.emptyList();
            }
            
            List<BigDecimal> alignedFast = emaFast.stream()
                .skip(offset)
                .collect(Collectors.toList());
            
            List<BigDecimal> macdLine = new ArrayList<>();
            for (int i = 0; i < emaSlow.size(); i++) {
                macdLine.add(alignedFast.get(i).subtract(emaSlow.get(i))
                    .setScale(SCALE, RoundingMode.HALF_UP));
            }
            
            List<BigDecimal> signalLine = calculateEMA(macdLine, params.getSignalPeriod(), signalMultiplier);
            
            // Build historical indicators
            List<MACDIndicator> indicators = new ArrayList<>();
            int signalOffset = macdLine.size() - signalLine.size();
            
            for (int i = 0; i < signalLine.size(); i++) {
                int macdIndex = signalOffset + i;
                int klineIndex = offset + macdIndex;
                
                if (macdIndex < macdLine.size() && klineIndex < sortedKlines.size()) {
                    KlineEvent kline = sortedKlines.get(klineIndex);
                    BigDecimal macd = macdLine.get(macdIndex);
                    BigDecimal signal = signalLine.get(i);
                    BigDecimal histogram = macd.subtract(signal).setScale(SCALE, RoundingMode.HALF_UP);
                    
                    indicators.add(MACDIndicator.builder()
                        .symbol(symbol)
                        .interval(interval)
                        .timestamp(kline.getCloseTime())
                        .price(kline.getClose())
                        .macdLine(macd)
                        .signalLine(signal)
                        .histogram(histogram)
                        .signal(determineSignalAt(macdLine, signalLine, i))
                        .parameters(params)
                        .dataPoints(klines.size())
                        .calculatedAt(Instant.now())
                        .build());
                }
            }
            
            return indicators;
            
        } catch (Exception e) {
            log.error("Error getting historical MACD for {} {}", symbol, interval, e);
            return Collections.emptyList();
        }
    }
    
    private BigDecimal calculateEMAMultiplier(int period) {
        return BigDecimal.valueOf(2)
            .divide(BigDecimal.valueOf(period + 1), SCALE, RoundingMode.HALF_UP);
    }
    
    private List<BigDecimal> calculateEMA(List<BigDecimal> prices, int period, BigDecimal multiplier) {
        List<BigDecimal> ema = new ArrayList<>();
        
        if (prices.isEmpty()) {
            return ema;
        }
        
        // Start with SMA for the first period
        BigDecimal sum = BigDecimal.ZERO;
        for (int i = 0; i < Math.min(period, prices.size()); i++) {
            sum = sum.add(prices.get(i));
        }
        BigDecimal sma = sum.divide(BigDecimal.valueOf(Math.min(period, prices.size())), SCALE, RoundingMode.HALF_UP);
        ema.add(sma);
        
        // Calculate EMA for remaining values
        for (int i = period; i < prices.size(); i++) {
            BigDecimal currentPrice = prices.get(i);
            BigDecimal previousEMA = ema.get(ema.size() - 1);
            BigDecimal currentEMA = currentPrice.multiply(multiplier)
                .add(previousEMA.multiply(BigDecimal.ONE.subtract(multiplier)))
                .setScale(SCALE, RoundingMode.HALF_UP);
            ema.add(currentEMA);
        }
        
        return ema;
    }
    
    private String determineSignal(List<BigDecimal> macdLine, List<BigDecimal> signalLine) {
        if (macdLine.size() < 2 || signalLine.size() < 2) {
            return "NEUTRAL";
        }
        
        int macdOffset = macdLine.size() - signalLine.size();
        int lastIndex = signalLine.size() - 1;
        
        if (lastIndex < 1 || macdOffset + lastIndex - 1 < 0) {
            return "NEUTRAL";
        }
        
        BigDecimal prevMACD = macdLine.get(macdOffset + lastIndex - 1);
        BigDecimal currMACD = macdLine.get(macdOffset + lastIndex);
        BigDecimal prevSignal = signalLine.get(lastIndex - 1);
        BigDecimal currSignal = signalLine.get(lastIndex);
        
        BigDecimal prevDiff = prevMACD.subtract(prevSignal);
        BigDecimal currDiff = currMACD.subtract(currSignal);
        
        if (prevDiff.compareTo(BigDecimal.ZERO) <= 0 && currDiff.compareTo(BigDecimal.ZERO) > 0) {
            return "BUY";
        } else if (prevDiff.compareTo(BigDecimal.ZERO) >= 0 && currDiff.compareTo(BigDecimal.ZERO) < 0) {
            return "SELL";
        } else {
            return "NEUTRAL";
        }
    }
    
    private String determineSignalAt(List<BigDecimal> macdLine, List<BigDecimal> signalLine, int index) {
        if (index < 1) {
            return "NEUTRAL";
        }
        
        int macdOffset = macdLine.size() - signalLine.size();
        int macdIndex = macdOffset + index;
        
        if (macdIndex < 1 || macdIndex >= macdLine.size()) {
            return "NEUTRAL";
        }
        
        BigDecimal prevMACD = macdLine.get(macdIndex - 1);
        BigDecimal currMACD = macdLine.get(macdIndex);
        BigDecimal prevSignal = signalLine.get(index - 1);
        BigDecimal currSignal = signalLine.get(index);
        
        BigDecimal prevDiff = prevMACD.subtract(prevSignal);
        BigDecimal currDiff = currMACD.subtract(currSignal);
        
        if (prevDiff.compareTo(BigDecimal.ZERO) <= 0 && currDiff.compareTo(BigDecimal.ZERO) > 0) {
            return "BUY";
        } else if (prevDiff.compareTo(BigDecimal.ZERO) >= 0 && currDiff.compareTo(BigDecimal.ZERO) < 0) {
            return "SELL";
        } else {
            return "NEUTRAL";
        }
    }
    
    private MACDIndicator createEmptyIndicator(String symbol, String interval, String error) {
        return MACDIndicator.builder()
            .symbol(symbol)
            .interval(interval)
            .timestamp(System.currentTimeMillis())
            .price(BigDecimal.ZERO)
            .macdLine(BigDecimal.ZERO)
            .signalLine(BigDecimal.ZERO)
            .histogram(BigDecimal.ZERO)
            .signal("ERROR")
            .parameters(DEFAULT_PARAMS)
            .dataPoints(0)
            .calculatedAt(Instant.now())
            .error(error)
            .build();
    }
}
