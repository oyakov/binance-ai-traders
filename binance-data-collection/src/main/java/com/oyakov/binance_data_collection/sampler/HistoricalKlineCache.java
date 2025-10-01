package com.oyakov.binance_data_collection.sampler;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

@Component
@Log4j2
@RequiredArgsConstructor
public class HistoricalKlineCache {

    private final ObjectMapper objectMapper;

    public Optional<BacktestDataset> loadDataset(String cacheDirectory, String cacheKey) {
        Path cachePath = resolvePath(cacheDirectory, cacheKey);
        if (!Files.exists(cachePath)) {
            return Optional.empty();
        }
        try {
            BacktestDataset dataset = objectMapper.readValue(cachePath.toFile(), BacktestDataset.class);
            log.info("Loaded cached dataset {} from {}", cacheKey, cachePath);
            return Optional.of(dataset);
        } catch (IOException e) {
            log.warn("Failed to read cached dataset from {}. Ignoring cache entry.", cachePath, e);
            return Optional.empty();
        }
    }

    public void saveDataset(BacktestDataset dataset, String cacheDirectory, String cacheKey) {
        Path cachePath = resolvePath(cacheDirectory, cacheKey);
        try {
            Files.createDirectories(cachePath.getParent());
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(cachePath.toFile(), dataset);
            log.info("Cached dataset {} with {} klines at {}", cacheKey, dataset.getKlines().size(), cachePath);
        } catch (IOException e) {
            log.warn("Failed to write cached dataset {} to {}", cacheKey, cachePath, e);
        }
    }

    private Path resolvePath(String cacheDirectory, String cacheKey) {
        String safeKey = cacheKey.replaceAll("[^a-zA-Z0-9_-]", "-");
        return Path.of(cacheDirectory).resolve(safeKey + ".json");
    }
}
