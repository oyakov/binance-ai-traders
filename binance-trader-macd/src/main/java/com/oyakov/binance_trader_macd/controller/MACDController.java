package com.oyakov.binance_trader_macd.controller;

import com.oyakov.binance_trader_macd.domain.MACDIndicator;
import com.oyakov.binance_trader_macd.domain.MACDParameters;
import com.oyakov.binance_trader_macd.metrics.MACDMetricsService;
import com.oyakov.binance_trader_macd.service.MACDCalculationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * REST Controller for MACD indicators and calculations
 */
@RestController
@RequestMapping("/api/v1/macd")
@RequiredArgsConstructor
@Log4j2
public class MACDController {

    private final MACDCalculationService macdCalculationService;
    private final MACDMetricsService macdMetricsService;

    /**
     * Get current MACD indicator for a specific symbol and interval
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "5m", "1h", "1d")
     * @param fastPeriod Fast EMA period (optional, default: 12)
     * @param slowPeriod Slow EMA period (optional, default: 26)
     * @param signalPeriod Signal line period (optional, default: 9)
     */
    @GetMapping("/indicator/{symbol}/{interval}")
    public ResponseEntity<MACDIndicator> getMACDIndicator(
            @PathVariable String symbol,
            @PathVariable String interval,
            @RequestParam(required = false, defaultValue = "12") int fastPeriod,
            @RequestParam(required = false, defaultValue = "26") int slowPeriod,
            @RequestParam(required = false, defaultValue = "9") int signalPeriod) {
        
        log.debug("Getting MACD indicator for {} {} with params: fast={}, slow={}, signal={}", 
            symbol, interval, fastPeriod, slowPeriod, signalPeriod);
        
        try {
            MACDParameters params = MACDParameters.builder()
                .fastPeriod(fastPeriod)
                .slowPeriod(slowPeriod)
                .signalPeriod(signalPeriod)
                .build();
            
            if (!params.isValid()) {
                return ResponseEntity.badRequest().build();
            }
            
            MACDIndicator indicator = macdCalculationService.calculateMACD(symbol, interval, params);
            return ResponseEntity.ok(indicator);
            
        } catch (Exception e) {
            log.error("Error getting MACD indicator for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get current MACD indicator with default parameters
     */
    @GetMapping("/indicator/{symbol}/{interval}/default")
    public ResponseEntity<MACDIndicator> getMACDIndicatorDefault(
            @PathVariable String symbol,
            @PathVariable String interval) {
        
        try {
            MACDIndicator indicator = macdCalculationService.calculateMACD(symbol, interval);
            return ResponseEntity.ok(indicator);
            
        } catch (Exception e) {
            log.error("Error getting default MACD indicator for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get historical MACD indicators for a symbol
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param limit Number of historical points to return (default: 50)
     * @param fastPeriod Fast EMA period (optional, default: 12)
     * @param slowPeriod Slow EMA period (optional, default: 26)
     * @param signalPeriod Signal line period (optional, default: 9)
     */
    @GetMapping("/history/{symbol}/{interval}")
    public ResponseEntity<List<MACDIndicator>> getMACDHistory(
            @PathVariable String symbol,
            @PathVariable String interval,
            @RequestParam(required = false, defaultValue = "50") int limit,
            @RequestParam(required = false, defaultValue = "12") int fastPeriod,
            @RequestParam(required = false, defaultValue = "26") int slowPeriod,
            @RequestParam(required = false, defaultValue = "9") int signalPeriod) {
        
        log.debug("Getting MACD history for {} {} with limit {} and params: fast={}, slow={}, signal={}", 
            symbol, interval, limit, fastPeriod, slowPeriod, signalPeriod);
        
        try {
            MACDParameters params = MACDParameters.builder()
                .fastPeriod(fastPeriod)
                .slowPeriod(slowPeriod)
                .signalPeriod(signalPeriod)
                .build();
            
            if (!params.isValid()) {
                return ResponseEntity.badRequest().build();
            }
            
            List<MACDIndicator> indicators = macdCalculationService.getHistoricalMACD(symbol, interval, limit, params);
            return ResponseEntity.ok(indicators);
            
        } catch (Exception e) {
            log.error("Error getting MACD history for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get MACD indicators for multiple symbols
     * 
     * @param symbols Comma-separated list of symbols (e.g., "BTCUSDT,ETHUSDT,BNBUSDT")
     * @param interval Kline interval
     * @param fastPeriod Fast EMA period (optional, default: 12)
     * @param slowPeriod Slow EMA period (optional, default: 26)
     * @param signalPeriod Signal line period (optional, default: 9)
     */
    @GetMapping("/indicators")
    public ResponseEntity<List<MACDIndicator>> getMultipleMACDIndicators(
            @RequestParam String symbols,
            @RequestParam String interval,
            @RequestParam(required = false, defaultValue = "12") int fastPeriod,
            @RequestParam(required = false, defaultValue = "26") int slowPeriod,
            @RequestParam(required = false, defaultValue = "9") int signalPeriod) {
        
        log.debug("Getting MACD indicators for symbols: {} with interval {} and params: fast={}, slow={}, signal={}", 
            symbols, interval, fastPeriod, slowPeriod, signalPeriod);
        
        try {
            List<String> symbolList = List.of(symbols.split(","));
            MACDParameters params = MACDParameters.builder()
                .fastPeriod(fastPeriod)
                .slowPeriod(slowPeriod)
                .signalPeriod(signalPeriod)
                .build();
            
            if (!params.isValid()) {
                return ResponseEntity.badRequest().build();
            }
            
            List<MACDIndicator> indicators = macdCalculationService.calculateMACDForSymbols(symbolList, interval, params);
            return ResponseEntity.ok(indicators);
            
        } catch (Exception e) {
            log.error("Error getting multiple MACD indicators for symbols: {}", symbols, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get all cached MACD indicators from metrics service
     */
    @GetMapping("/cached")
    public ResponseEntity<Map<String, MACDIndicator>> getCachedIndicators() {
        try {
            Map<String, MACDIndicator> indicators = macdMetricsService.getAllIndicators();
            return ResponseEntity.ok(indicators);
            
        } catch (Exception e) {
            log.error("Error getting cached indicators", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Update MACD indicators for all monitored symbols
     */
    @PostMapping("/update")
    public ResponseEntity<String> updateAllIndicators() {
        try {
            macdMetricsService.updateAllIndicators();
            return ResponseEntity.ok("MACD indicators updated successfully");
            
        } catch (Exception e) {
            log.error("Error updating all indicators", e);
            return ResponseEntity.internalServerError().body("Error updating indicators: " + e.getMessage());
        }
    }

    /**
     * Update MACD indicator for a specific symbol and interval
     */
    @PostMapping("/update/{symbol}/{interval}")
    public ResponseEntity<String> updateIndicator(
            @PathVariable String symbol,
            @PathVariable String interval) {
        
        try {
            macdMetricsService.updateIndicator(symbol, interval);
            return ResponseEntity.ok("MACD indicator updated for " + symbol + " " + interval);
            
        } catch (Exception e) {
            log.error("Error updating indicator for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().body("Error updating indicator: " + e.getMessage());
        }
    }

    /**
     * Get MACD metrics statistics
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        try {
            Map<String, Object> stats = macdMetricsService.getStatistics();
            return ResponseEntity.ok(stats);
            
        } catch (Exception e) {
            log.error("Error getting MACD statistics", e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<String> healthCheck() {
        return ResponseEntity.ok("MACD API is healthy");
    }
}
