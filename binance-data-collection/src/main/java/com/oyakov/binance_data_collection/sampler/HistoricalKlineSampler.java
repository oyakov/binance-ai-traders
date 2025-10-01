package com.oyakov.binance_data_collection.sampler;

import com.oyakov.binance_data_collection.rest.client.binance.BinanceRestKlineClient;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.time.Instant;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Component
@Log4j2
@RequiredArgsConstructor
public class HistoricalKlineSampler {

    private static final DateTimeFormatter CACHE_DAY_FORMATTER =
            DateTimeFormatter.ofPattern("yyyyMMdd").withZone(ZoneOffset.UTC);

    private final BinanceRestKlineClient klineClient;
    private final HistoricalSamplerProperties properties;
    private final BacktestDatasetFileWriter datasetWriter;
    private final HistoricalKlineCache klineCache;

    public List<Path> collect() {
        Instant collectedAt = Instant.now();
        Instant defaultEndInstant = resolveEndInstant(collectedAt);
        boolean useStandardRanges = shouldUseStandardRanges();
        List<Path> savedFiles = new ArrayList<>();
        for (String symbol : properties.getSymbols()) {
            for (String interval : properties.getIntervals()) {
                if (useStandardRanges) {
                    for (Integer days : properties.getDayRanges()) {
                        Path saved = collectForDayRange(symbol, interval, days, collectedAt, defaultEndInstant);
                        if (saved != null) {
                            savedFiles.add(saved);
                        }
                    }
                } else {
                    Path saved = collectWithCustomWindow(symbol, interval, collectedAt);
                    if (saved != null) {
                        savedFiles.add(saved);
                    }
                }
            }
        }
        return savedFiles;
    }

    private Path collectForDayRange(String symbol,
                                    String interval,
                                    Integer days,
                                    Instant collectedAt,
                                    Instant endInstant) {
        if (days == null || days <= 0) {
            log.warn("Skipping invalid day range {} for {} {}", days, symbol, interval);
            return null;
        }
        Instant startInstant = endInstant.minus(days, ChronoUnit.DAYS);
        String cacheKey = buildDayRangeCacheKey(symbol, interval, days, endInstant);
        List<KlineEvent> klines = resolveKlines(symbol, interval, null,
                startInstant.toEpochMilli(), endInstant.toEpochMilli(), collectedAt, cacheKey);
        if (klines.isEmpty()) {
            log.warn("No klines received for {} {} over {} days", symbol, interval, days);
            return null;
        }
        BacktestDataset dataset = BacktestDataset.builder()
                .name(symbol.toUpperCase() + "_" + interval + "_" + days + "d")
                .symbol(symbol.toUpperCase())
                .interval(interval)
                .collectedAt(collectedAt)
                .klines(klines)
                .build();
        return datasetWriter.writeDataset(dataset, properties.getOutputDirectory());
    }

    private Path collectWithCustomWindow(String symbol, String interval, Instant collectedAt) {
        String cacheKey = buildCustomWindowCacheKey(symbol, interval);
        List<KlineEvent> klines = resolveKlines(symbol, interval,
                properties.getLimit(), properties.getStartTime(), properties.getEndTime(), collectedAt, cacheKey);
        if (klines.isEmpty()) {
            log.warn("No klines received for {} {}", symbol, interval);
            return null;
        }
        BacktestDataset dataset = BacktestDataset.builder()
                .name(symbol.toUpperCase() + "_" + interval)
                .symbol(symbol.toUpperCase())
                .interval(interval)
                .collectedAt(collectedAt)
                .klines(klines)
                .build();
        return datasetWriter.writeDataset(dataset, properties.getOutputDirectory());
    }

    private List<KlineEvent> resolveKlines(String symbol,
                                          String interval,
                                          Integer limit,
                                          Long startTime,
                                          Long endTime,
                                          Instant collectedAt,
                                          String cacheKey) {
        if (properties.isCacheEnabled()) {
            Optional<BacktestDataset> cached = klineCache.loadDataset(properties.getCacheDirectory(), cacheKey);
            if (cached.isPresent()) {
                return new ArrayList<>(cached.get().getKlines());
            }
        }

        List<KlineEvent> klines = klineClient.fetchHistoricalKlines(symbol, interval, limit, startTime, endTime);
        if (!klines.isEmpty() && properties.isCacheEnabled()) {
            BacktestDataset cacheDataset = BacktestDataset.builder()
                    .name(cacheKey)
                    .symbol(symbol.toUpperCase())
                    .interval(interval)
                    .collectedAt(collectedAt)
                    .klines(List.copyOf(klines))
                    .build();
            klineCache.saveDataset(cacheDataset, properties.getCacheDirectory(), cacheKey);
        }
        return klines;
    }

    private Instant resolveEndInstant(Instant fallback) {
        if (properties.getEndTime() != null) {
            return Instant.ofEpochMilli(properties.getEndTime());
        }
        return fallback;
    }

    private boolean shouldUseStandardRanges() {
        return properties.getDayRanges() != null
                && !properties.getDayRanges().isEmpty()
                && properties.getStartTime() == null
                && properties.getEndTime() == null;
    }

    private String buildDayRangeCacheKey(String symbol, String interval, int days, Instant endInstant) {
        String dayLabel = CACHE_DAY_FORMATTER.format(endInstant);
        return "%s_%s_%dd_%s".formatted(symbol.toLowerCase(), interval, days, dayLabel);
    }

    private String buildCustomWindowCacheKey(String symbol, String interval) {
        StringBuilder descriptor = new StringBuilder();
        if (properties.getStartTime() != null || properties.getEndTime() != null) {
            descriptor.append("window_");
            descriptor.append(properties.getStartTime() != null ? properties.getStartTime() : "na");
            descriptor.append("_");
            descriptor.append(properties.getEndTime() != null ? properties.getEndTime() : "na");
        } else if (properties.getLimit() != null) {
            descriptor.append("limit_").append(properties.getLimit());
        } else {
            descriptor.append("open-window");
        }
        return "%s_%s_%s".formatted(symbol.toLowerCase(), interval, descriptor);
    }
}
