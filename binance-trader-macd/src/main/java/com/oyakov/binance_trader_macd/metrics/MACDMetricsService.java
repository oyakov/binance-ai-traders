package com.oyakov.binance_trader_macd.metrics;

import com.oyakov.binance_trader_macd.domain.MACDIndicator;
import com.oyakov.binance_trader_macd.domain.MACDParameters;
import com.oyakov.binance_trader_macd.service.MACDCalculationService;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;

/**
 * Service for exposing MACD indicators as Prometheus metrics
 */
@Service
@RequiredArgsConstructor
@Log4j2
public class MACDMetricsService {

    private final MACDCalculationService macdCalculationService;
    private final MeterRegistry meterRegistry;
    
    // Cache for latest MACD indicators
    private final Map<String, AtomicReference<MACDIndicator>> indicatorCache = new ConcurrentHashMap<>();
    
    // Default symbols and intervals to monitor
    private final List<String> defaultSymbols = List.of("BTCUSDT", "ETHUSDT", "BNBUSDT");
    private final List<String> defaultIntervals = List.of("5m", "15m", "1h");
    
    private Timer macdCalculationTimer;
    
    @PostConstruct
    void initializeMetrics() {
        log.info("Initializing MACD metrics service");
        
        // Create timer for MACD calculation performance
        macdCalculationTimer = Timer.builder("binance.macd.calculation.duration")
            .description("Time taken to calculate MACD indicators")
            .register(meterRegistry);
        
        // Initialize gauge metrics for each symbol/interval combination
        initializeGaugeMetrics();
        
        // Start background calculation
        startBackgroundCalculation();
    }
    
    private void initializeGaugeMetrics() {
        for (String symbol : defaultSymbols) {
            for (String interval : defaultIntervals) {
                String key = symbol + "_" + interval;
                indicatorCache.put(key, new AtomicReference<>());
                
                // MACD Line gauge
                Gauge.builder("binance.macd.line", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null ? indicator.getMacdLine().doubleValue() : 0.0;
                    })
                    .description("MACD line value")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Signal Line gauge
                Gauge.builder("binance.macd.signal.line", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null ? indicator.getSignalLine().doubleValue() : 0.0;
                    })
                    .description("MACD signal line value")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Histogram gauge
                Gauge.builder("binance.macd.histogram", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null ? indicator.getHistogram().doubleValue() : 0.0;
                    })
                    .description("MACD histogram value")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Price gauge
                Gauge.builder("binance.macd.price", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null ? indicator.getPrice().doubleValue() : 0.0;
                    })
                    .description("Current price for MACD calculation")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Signal strength gauge (0=NONE, 1=WEAK, 2=MODERATE, 3=STRONG)
                Gauge.builder("binance.macd.signal.strength", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        if (indicator == null) return 0.0;
                        
                        return switch (indicator.getSignalStrength()) {
                            case NONE -> 0.0;
                            case WEAK -> 1.0;
                            case MODERATE -> 2.0;
                            case STRONG -> 3.0;
                        };
                    })
                    .description("MACD signal strength")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Data points gauge
                Gauge.builder("binance.macd.data.points", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null ? (double) indicator.getDataPoints() : 0.0;
                    })
                    .description("Number of data points used for MACD calculation")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
                
                // Valid calculation gauge (1=valid, 0=invalid)
                Gauge.builder("binance.macd.valid", this, service -> {
                        MACDIndicator indicator = indicatorCache.get(key).get();
                        return indicator != null && indicator.isValid() ? 1.0 : 0.0;
                    })
                    .description("Whether MACD calculation is valid")
                    .tag("symbol", symbol)
                    .tag("interval", interval)
                    .register(meterRegistry);
            }
        }
        
        log.info("Initialized {} MACD gauge metrics", indicatorCache.size() * 7);
    }
    
    private void startBackgroundCalculation() {
        // This would typically be done in a scheduled task
        // For now, we'll calculate on demand
        log.info("MACD metrics service initialized - calculations will be performed on demand");
    }
    
    /**
     * Update MACD indicators for all monitored symbols and intervals
     */
    public void updateAllIndicators() {
        log.debug("Updating all MACD indicators");
        
        for (String symbol : defaultSymbols) {
            for (String interval : defaultIntervals) {
                updateIndicator(symbol, interval);
            }
        }
    }
    
    /**
     * Update MACD indicator for a specific symbol and interval
     */
    public void updateIndicator(String symbol, String interval) {
        String key = symbol + "_" + interval;
        
        try {
            Timer.Sample sample = Timer.start(meterRegistry);
            
            MACDIndicator indicator = macdCalculationService.calculateMACD(symbol, interval);
            indicatorCache.get(key).set(indicator);
            
            sample.stop(macdCalculationTimer);
            
            log.debug("Updated MACD indicator for {} {}: {}", symbol, interval, indicator.getSummary());
            
        } catch (Exception e) {
            log.error("Error updating MACD indicator for {} {}", symbol, interval, e);
        }
    }
    
    /**
     * Get the latest MACD indicator for a symbol and interval
     */
    public MACDIndicator getLatestIndicator(String symbol, String interval) {
        String key = symbol + "_" + interval;
        return indicatorCache.get(key).get();
    }
    
    /**
     * Get all cached indicators
     */
    public Map<String, MACDIndicator> getAllIndicators() {
        Map<String, MACDIndicator> result = new ConcurrentHashMap<>();
        indicatorCache.forEach((key, ref) -> {
            MACDIndicator indicator = ref.get();
            if (indicator != null) {
                result.put(key, indicator);
            }
        });
        return result;
    }
    
    /**
     * Calculate and cache MACD for a custom symbol/interval combination
     */
    public MACDIndicator calculateAndCache(String symbol, String interval, MACDParameters params) {
        try {
            Timer.Sample sample = Timer.start(meterRegistry);
            
            MACDIndicator indicator = macdCalculationService.calculateMACD(symbol, interval, params);
            
            sample.stop(macdCalculationTimer);
            
            log.debug("Calculated MACD for {} {} with params {}: {}", 
                symbol, interval, params, indicator.getSummary());
            
            return indicator;
            
        } catch (Exception e) {
            log.error("Error calculating MACD for {} {} with params {}", symbol, interval, params, e);
            return null;
        }
    }
    
    /**
     * Get MACD calculation statistics
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new ConcurrentHashMap<>();
        
        stats.put("cached_indicators", indicatorCache.size());
        stats.put("monitored_symbols", defaultSymbols.size());
        stats.put("monitored_intervals", defaultIntervals.size());
        
        // Count valid indicators
        long validCount = indicatorCache.values().stream()
            .mapToLong(ref -> {
                MACDIndicator indicator = ref.get();
                return (indicator != null && indicator.isValid()) ? 1 : 0;
            })
            .sum();
        
        stats.put("valid_indicators", validCount);
        stats.put("invalid_indicators", indicatorCache.size() - validCount);
        
        return stats;
    }
}
