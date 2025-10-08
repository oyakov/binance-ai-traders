package com.oyakov.binance_data_storage.controller;

import com.oyakov.binance_data_storage.model.klines.binance.storage.KlineItem;
import com.oyakov.binance_data_storage.repository.jpa.KlinePostgresRepository;
import com.oyakov.binance_data_storage.repository.elastic.KlineElasticRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

/**
 * REST Controller for querying kline data from shared databases.
 * This allows other microservices to access historical kline data without direct database access.
 */
@RestController
@RequestMapping("/api/v1/klines")
@RequiredArgsConstructor
@Log4j2
public class KlineDataController {

    private final KlinePostgresRepository postgresRepository;
    private final Optional<KlineElasticRepository> elasticRepository;

    /**
     * Get recent klines for a symbol and interval
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "1h", "4h", "1d")
     * @param limit Number of klines to return (default: 100, max: 1000)
     * @return List of recent klines
     */
    @GetMapping("/recent")
    public ResponseEntity<List<KlineItem>> getRecentKlines(
            @RequestParam String symbol,
            @RequestParam String interval,
            @RequestParam(defaultValue = "100") int limit) {
        
        try {
            log.info("Fetching recent {} klines for {} {}", limit, symbol, interval);
            
            // Limit to reasonable size
            int actualLimit = Math.min(Math.max(limit, 1), 1000);
            Pageable pageable = PageRequest.of(0, actualLimit, Sort.by("fingerprint.openTime").descending());
            
            List<KlineItem> klines = postgresRepository.findByFingerprintSymbolAndFingerprintIntervalOrderByFingerprintOpenTimeDesc(
                symbol.toUpperCase(), interval, pageable);
            
            log.info("Retrieved {} klines for {} {}", klines.size(), symbol, interval);
            return ResponseEntity.ok(klines);
            
        } catch (Exception e) {
            log.error("Error fetching recent klines for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get klines for a specific time range
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param startTime Start time in milliseconds
     * @param endTime End time in milliseconds
     * @return List of klines in the time range
     */
    @GetMapping("/range")
    public ResponseEntity<List<KlineItem>> getKlinesByRange(
            @RequestParam String symbol,
            @RequestParam String interval,
            @RequestParam long startTime,
            @RequestParam long endTime) {
        
        try {
            log.info("Fetching klines for {} {} from {} to {}", symbol, interval, startTime, endTime);
            
            List<KlineItem> klines = postgresRepository.findByFingerprintSymbolAndFingerprintIntervalAndFingerprintOpenTimeBetween(
                symbol.toUpperCase(), interval, startTime, endTime);
            
            log.info("Retrieved {} klines for {} {} in range", klines.size(), symbol, interval);
            return ResponseEntity.ok(klines);
            
        } catch (Exception e) {
            log.error("Error fetching klines by range for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get the latest kline for a symbol and interval
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @return Latest kline or 404 if not found
     */
    @GetMapping("/latest")
    public ResponseEntity<KlineItem> getLatestKline(
            @RequestParam String symbol,
            @RequestParam String interval) {
        
        try {
            log.info("Fetching latest kline for {} {}", symbol, interval);
            
            Optional<KlineItem> latestKline = postgresRepository.findTopByFingerprintSymbolAndFingerprintIntervalOrderByFingerprintOpenTimeDesc(
                symbol.toUpperCase(), interval);
            
            if (latestKline.isPresent()) {
                log.info("Found latest kline for {} {}: {}", symbol, interval, latestKline.get().getOpenTime());
                return ResponseEntity.ok(latestKline.get());
            } else {
                log.warn("No klines found for {} {}", symbol, interval);
                return ResponseEntity.notFound().build();
            }
            
        } catch (Exception e) {
            log.error("Error fetching latest kline for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Get klines count for a symbol and interval
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @return Count of klines
     */
    @GetMapping("/count")
    public ResponseEntity<Long> getKlinesCount(
            @RequestParam String symbol,
            @RequestParam String interval) {
        
        try {
            log.info("Counting klines for {} {}", symbol, interval);
            
            long count = postgresRepository.countByFingerprintSymbolAndFingerprintInterval(symbol.toUpperCase(), interval);
            
            log.info("Found {} klines for {} {}", count, symbol, interval);
            return ResponseEntity.ok(count);
            
        } catch (Exception e) {
            log.error("Error counting klines for {} {}", symbol, interval, e);
            return ResponseEntity.internalServerError().build();
        }
    }

    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("Kline Data API is healthy");
    }
}
