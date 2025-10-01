package com.oyakov.binance_trader_macd.backtest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Service to fetch historical kline data from Binance API and convert it to BacktestDataset format.
 * This allows the backtesting engine to work with real market data instead of synthetic data.
 */
@Component
@Log4j2
@RequiredArgsConstructor
public class BinanceHistoricalDataFetcher {

    private final RestTemplate restTemplate;

    private static final String BINANCE_KLINES_URL = "https://api.binance.com/api/v3/klines";
    private static final int MAX_KLINES_PER_REQUEST = 1000;

    /**
     * Fetches historical kline data from Binance and creates a BacktestDataset.
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
        log.info("Fetching historical data for {} {} from {} to {}", symbol, interval, startTime, endTime);
        
        List<KlineEvent> allKlines = new ArrayList<>();
        long currentStartTime = startTime;
        
        while (currentStartTime < endTime) {
            long currentEndTime = Math.min(currentStartTime + (MAX_KLINES_PER_REQUEST * getIntervalMs(interval)), endTime);
            
            List<KlineEvent> batchKlines = fetchKlinesBatch(symbol, interval, currentStartTime, currentEndTime);
            allKlines.addAll(batchKlines);
            
            if (batchKlines.isEmpty()) {
                log.warn("No more data available, stopping fetch");
                break;
            }
            
            // Move to next batch
            currentStartTime = batchKlines.get(batchKlines.size() - 1).getCloseTime() + 1;
            
            // Add delay to respect rate limits
            try {
                Thread.sleep(100);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
        
        log.info("Fetched {} klines for {} {}", allKlines.size(), symbol, interval);
        
        return BacktestDataset.builder()
                .name(datasetName)
                .symbol(symbol)
                .interval(interval)
                .collectedAt(Instant.now())
                .klines(allKlines)
                .build();
    }

    /**
     * Fetches a batch of klines from Binance API.
     */
    private List<KlineEvent> fetchKlinesBatch(String symbol, String interval, long startTime, long endTime) {
        try {
            String url = String.format("%s?symbol=%s&interval=%s&startTime=%d&endTime=%d&limit=%d",
                    BINANCE_KLINES_URL, symbol, interval, startTime, endTime, MAX_KLINES_PER_REQUEST);
            
            log.debug("Fetching from URL: {}", url);
            
            @SuppressWarnings("unchecked")
            List<List<Object>> response = restTemplate.getForObject(url, List.class);
            
            if (response == null || response.isEmpty()) {
                return new ArrayList<>();
            }
            
            List<KlineEvent> klines = new ArrayList<>();
            for (List<Object> klineData : response) {
                KlineEvent kline = convertToKlineEvent(klineData, symbol, interval);
                klines.add(kline);
            }
            
            return klines;
            
        } catch (Exception e) {
            log.error("Error fetching klines batch for {} {} from {} to {}", symbol, interval, startTime, endTime, e);
            return new ArrayList<>();
        }
    }

    /**
     * Converts Binance API response to KlineEvent.
     */
    private KlineEvent convertToKlineEvent(List<Object> klineData, String symbol, String interval) {
        // Binance kline format: [timestamp, open, high, low, close, volume, closeTime, quoteAssetVolume, 
        //                        numberOfTrades, takerBuyBaseAssetVolume, takerBuyQuoteAssetVolume, ignore]
        
        long openTime = Long.parseLong(klineData.get(0).toString());
        String open = klineData.get(1).toString();
        String high = klineData.get(2).toString();
        String low = klineData.get(3).toString();
        String close = klineData.get(4).toString();
        String volume = klineData.get(5).toString();
        long closeTime = Long.parseLong(klineData.get(6).toString());
        String quoteAssetVolume = klineData.get(7).toString();
        long numberOfTrades = Long.parseLong(klineData.get(8).toString());
        String takerBuyBaseAssetVolume = klineData.get(9).toString();
        String takerBuyQuoteAssetVolume = klineData.get(10).toString();
        String ignore = klineData.get(11).toString();
        
        return new KlineEvent(
                "kline",
                openTime,
                symbol,
                interval,
                openTime,
                closeTime,
                new BigDecimal(open),
                new BigDecimal(high),
                new BigDecimal(low),
                new BigDecimal(close),
                new BigDecimal(volume)
        );
    }

    /**
     * Gets the interval duration in milliseconds.
     */
    private long getIntervalMs(String interval) {
        switch (interval) {
            case "1m": return 60 * 1000L;
            case "3m": return 3 * 60 * 1000L;
            case "5m": return 5 * 60 * 1000L;
            case "15m": return 15 * 60 * 1000L;
            case "30m": return 30 * 60 * 1000L;
            case "1h": return 60 * 60 * 1000L;
            case "2h": return 2 * 60 * 60 * 1000L;
            case "4h": return 4 * 60 * 60 * 1000L;
            case "6h": return 6 * 60 * 60 * 1000L;
            case "8h": return 8 * 60 * 60 * 1000L;
            case "12h": return 12 * 60 * 60 * 1000L;
            case "1d": return 24 * 60 * 60 * 1000L;
            case "3d": return 3 * 24 * 60 * 60 * 1000L;
            case "1w": return 7 * 24 * 60 * 60 * 1000L;
            case "1M": return 30L * 24 * 60 * 60 * 1000L;
            default: return 60 * 1000L; // Default to 1 minute
        }
    }

    /**
     * Convenience method to fetch data for the last N days.
     */
    public BacktestDataset fetchLastNDays(String symbol, String interval, int days, String datasetName) {
        long endTime = System.currentTimeMillis();
        long startTime = endTime - (days * 24 * 60 * 60 * 1000L);
        return fetchHistoricalData(symbol, interval, startTime, endTime, datasetName);
    }

    /**
     * Convenience method to fetch data for a specific date range.
     */
    public BacktestDataset fetchDateRange(String symbol, String interval, 
                                        LocalDateTime start, LocalDateTime end, String datasetName) {
        long startTime = start.toInstant(ZoneOffset.UTC).toEpochMilli();
        long endTime = end.toInstant(ZoneOffset.UTC).toEpochMilli();
        return fetchHistoricalData(symbol, interval, startTime, endTime, datasetName);
    }
}
