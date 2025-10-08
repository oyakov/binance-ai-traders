package com.oyakov.binance_trader_macd.service;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_trader_macd.config.MACDTraderConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for accessing kline data from the shared data storage service.
 * This replaces direct Binance API calls and focuses the trading service on calculations.
 */
@Service
@RequiredArgsConstructor
@Log4j2
public class KlineDataAccessService {

    private final RestTemplate restTemplate;
    private final MACDTraderConfig config;

    /**
     * Get recent klines for a symbol and interval from the shared database
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "1h", "4h", "1d")
     * @param limit Number of klines to return
     * @return List of recent klines as KlineEvent objects
     */
    public List<KlineEvent> getRecentKlines(String symbol, String interval, int limit) {
        try {
            log.debug("Fetching {} recent klines for {} {} from data storage", limit, symbol, interval);
            
            String url = String.format("%s/api/v1/klines/recent?symbol=%s&interval=%s&limit=%d", 
                config.getData().getStorage().getBaseUrl(), symbol, interval, limit);
            
            ResponseEntity<List<KlineDataResponse>> response = restTemplate.exchange(
                url, HttpMethod.GET, null, new ParameterizedTypeReference<List<KlineDataResponse>>() {});
            
            if (response.getBody() != null) {
                List<KlineEvent> klineEvents = response.getBody().stream()
                    .map(this::convertToKlineEvent)
                    .toList();
                
                log.info("Retrieved {} klines for {} {} from data storage", klineEvents.size(), symbol, interval);
                return klineEvents;
            } else {
                log.warn("No klines returned for {} {}", symbol, interval);
                return new ArrayList<>();
            }
            
        } catch (Exception e) {
            log.error("Error fetching recent klines for {} {} from data storage", symbol, interval, e);
            return new ArrayList<>();
        }
    }

    /**
     * Get klines for a specific time range from the shared database
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param startTime Start time in milliseconds
     * @param endTime End time in milliseconds
     * @return List of klines in the time range
     */
    public List<KlineEvent> getKlinesByRange(String symbol, String interval, long startTime, long endTime) {
        try {
            log.debug("Fetching klines for {} {} from {} to {} from data storage", 
                symbol, interval, startTime, endTime);
            
            String url = String.format("%s/api/v1/klines/range?symbol=%s&interval=%s&startTime=%d&endTime=%d", 
                config.getData().getStorage().getBaseUrl(), symbol, interval, startTime, endTime);
            
            ResponseEntity<List<KlineDataResponse>> response = restTemplate.exchange(
                url, HttpMethod.GET, null, new ParameterizedTypeReference<List<KlineDataResponse>>() {});
            
            if (response.getBody() != null) {
                List<KlineEvent> klineEvents = response.getBody().stream()
                    .map(this::convertToKlineEvent)
                    .toList();
                
                log.info("Retrieved {} klines for {} {} in range from data storage", 
                    klineEvents.size(), symbol, interval);
                return klineEvents;
            } else {
                log.warn("No klines returned for {} {} in range", symbol, interval);
                return new ArrayList<>();
            }
            
        } catch (Exception e) {
            log.error("Error fetching klines by range for {} {} from data storage", symbol, interval, e);
            return new ArrayList<>();
        }
    }

    /**
     * Get the latest kline for a symbol and interval
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @return Latest kline or null if not found
     */
    public KlineEvent getLatestKline(String symbol, String interval) {
        try {
            log.debug("Fetching latest kline for {} {} from data storage", symbol, interval);
            
            String url = String.format("%s/api/v1/klines/latest?symbol=%s&interval=%s", 
                config.getData().getStorage().getBaseUrl(), symbol, interval);
            
            ResponseEntity<KlineDataResponse> response = restTemplate.getForEntity(url, KlineDataResponse.class);
            
            if (response.getBody() != null) {
                KlineEvent klineEvent = convertToKlineEvent(response.getBody());
                log.info("Retrieved latest kline for {} {} from data storage", symbol, interval);
                return klineEvent;
            } else {
                log.warn("No latest kline found for {} {}", symbol, interval);
                return null;
            }
            
        } catch (Exception e) {
            log.error("Error fetching latest kline for {} {} from data storage", symbol, interval, e);
            return null;
        }
    }

    /**
     * Check if data storage service is available
     * 
     * @return true if available, false otherwise
     */
    public boolean isDataStorageAvailable() {
        try {
            String url = config.getData().getStorage().getBaseUrl() + "/api/v1/klines/health";
            ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.warn("Data storage service is not available: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Convert KlineDataResponse to KlineEvent
     */
    private KlineEvent convertToKlineEvent(KlineDataResponse response) {
        return KlineEvent.newBuilder()
            .setEventType("kline")
            .setEventTime(response.getTimestamp())
            .setSymbol(response.getSymbol())
            .setInterval(response.getInterval())
            .setOpenTime(response.getOpenTime())
            .setCloseTime(response.getCloseTime())
            .setOpen(BigDecimal.valueOf(response.getOpen()))
            .setHigh(BigDecimal.valueOf(response.getHigh()))
            .setLow(BigDecimal.valueOf(response.getLow()))
            .setClose(BigDecimal.valueOf(response.getClose()))
            .setVolume(BigDecimal.valueOf(response.getVolume()))
            .build();
    }

    /**
     * Response DTO for kline data from the data storage service
     */
    public static class KlineDataResponse {
        private String symbol;
        private String interval;
        private long openTime;
        private long closeTime;
        private long timestamp;
        private double open;
        private double high;
        private double low;
        private double close;
        private double volume;

        // Getters and setters
        public String getSymbol() { return symbol; }
        public void setSymbol(String symbol) { this.symbol = symbol; }
        
        public String getInterval() { return interval; }
        public void setInterval(String interval) { this.interval = interval; }
        
        public long getOpenTime() { return openTime; }
        public void setOpenTime(long openTime) { this.openTime = openTime; }
        
        public long getCloseTime() { return closeTime; }
        public void setCloseTime(long closeTime) { this.closeTime = closeTime; }
        
        public long getTimestamp() { return timestamp; }
        public void setTimestamp(long timestamp) { this.timestamp = timestamp; }
        
        public double getOpen() { return open; }
        public void setOpen(double open) { this.open = open; }
        
        public double getHigh() { return high; }
        public void setHigh(double high) { this.high = high; }
        
        public double getLow() { return low; }
        public void setLow(double low) { this.low = low; }
        
        public double getClose() { return close; }
        public void setClose(double close) { this.close = close; }
        
        public double getVolume() { return volume; }
        public void setVolume(double volume) { this.volume = volume; }
    }
}
