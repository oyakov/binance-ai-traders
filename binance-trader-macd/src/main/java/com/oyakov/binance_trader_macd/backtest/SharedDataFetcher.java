package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import com.oyakov.binance_trader_macd.service.KlineDataAccessService;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Service to fetch historical kline data from the shared data storage service.
 * This replaces direct Binance API calls and focuses on using already collected data.
 */
@Component
@Log4j2
@RequiredArgsConstructor
public class SharedDataFetcher {

    private final KlineDataAccessService klineDataAccessService;

    /**
     * Fetches historical kline data from the shared database and creates a BacktestDataset.
     * 
     * @param symbol Trading pair symbol (e.g., "BTCUSDT")
     * @param interval Kline interval (e.g., "1h", "4h", "1d")
     * @param startTime Start time in milliseconds
     * @param endTime End time in milliseconds
     * @param datasetName Name for the dataset
     * @return BacktestDataset containing the historical data
     */
    public BacktestDataset fetchHistoricalData(String symbol, String interval, 
                                             long startTime, long endTime, String datasetName) {
        log.info("Fetching historical data for {} {} from {} to {} from shared database", 
                symbol, interval, startTime, endTime);
        
        try {
            // Check if data storage is available
            if (!klineDataAccessService.isDataStorageAvailable()) {
                log.error("Data storage service is not available");
                return createEmptyDataset(symbol, interval, datasetName, "Data storage service unavailable");
            }

            // Fetch data from shared database
            List<KlineEvent> klines = klineDataAccessService.getKlinesByRange(symbol, interval, startTime, endTime);
            
            if (klines.isEmpty()) {
                log.warn("No historical data available for {} {} in range {} to {}", 
                        symbol, interval, startTime, endTime);
                return createEmptyDataset(symbol, interval, datasetName, "No data available in range");
            }
            
            log.info("Fetched {} klines for {} {} from shared database", klines.size(), symbol, interval);
            
            return BacktestDataset.builder()
                    .name(datasetName)
                    .symbol(symbol)
                    .interval(interval)
                    .collectedAt(Instant.now())
                    .klines(klines)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error fetching historical data for {} {} from shared database", symbol, interval, e);
            return createEmptyDataset(symbol, interval, datasetName, "Error: " + e.getMessage());
        }
    }

    /**
     * Fetches the last N days of data for a symbol and interval.
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param days Number of days to fetch
     * @param datasetName Name for the dataset
     * @return BacktestDataset containing the historical data
     */
    public BacktestDataset fetchLastNDays(String symbol, String interval, int days, String datasetName) {
        log.info("Fetching last {} days of data for {} {} from shared database", days, symbol, interval);
        
        try {
            // Check if data storage is available
            if (!klineDataAccessService.isDataStorageAvailable()) {
                log.error("Data storage service is not available");
                return createEmptyDataset(symbol, interval, datasetName, "Data storage service unavailable");
            }

            // Calculate time range
            long endTime = System.currentTimeMillis();
            long startTime = endTime - (days * 24 * 60 * 60 * 1000L);
            
            return fetchHistoricalData(symbol, interval, startTime, endTime, datasetName);
            
        } catch (Exception e) {
            log.error("Error fetching last {} days of data for {} {} from shared database", days, symbol, interval, e);
            return createEmptyDataset(symbol, interval, datasetName, "Error: " + e.getMessage());
        }
    }

    /**
     * Fetches recent klines for a symbol and interval.
     * 
     * @param symbol Trading pair symbol
     * @param interval Kline interval
     * @param limit Number of klines to fetch
     * @param datasetName Name for the dataset
     * @return BacktestDataset containing the recent data
     */
    public BacktestDataset fetchRecentKlines(String symbol, String interval, int limit, String datasetName) {
        log.info("Fetching {} recent klines for {} {} from shared database", limit, symbol, interval);
        
        try {
            // Check if data storage is available
            if (!klineDataAccessService.isDataStorageAvailable()) {
                log.error("Data storage service is not available");
                return createEmptyDataset(symbol, interval, datasetName, "Data storage service unavailable");
            }

            // Fetch recent data from shared database
            List<KlineEvent> klines = klineDataAccessService.getRecentKlines(symbol, interval, limit);
            
            if (klines.isEmpty()) {
                log.warn("No recent data available for {} {}", symbol, interval);
                return createEmptyDataset(symbol, interval, datasetName, "No recent data available");
            }
            
            log.info("Fetched {} recent klines for {} {} from shared database", klines.size(), symbol, interval);
            
            return BacktestDataset.builder()
                    .name(datasetName)
                    .symbol(symbol)
                    .interval(interval)
                    .collectedAt(Instant.now())
                    .klines(klines)
                    .build();
                    
        } catch (Exception e) {
            log.error("Error fetching recent klines for {} {} from shared database", symbol, interval, e);
            return createEmptyDataset(symbol, interval, datasetName, "Error: " + e.getMessage());
        }
    }

    /**
     * Creates an empty dataset with error information
     */
    private BacktestDataset createEmptyDataset(String symbol, String interval, String datasetName, String errorMessage) {
        log.warn("Creating empty dataset for {} {}: {}", symbol, interval, errorMessage);
        
        return BacktestDataset.builder()
                .name(datasetName)
                .symbol(symbol)
                .interval(interval)
                .collectedAt(Instant.now())
                .klines(new ArrayList<>())
                .build();
    }
}
