package com.oyakov.binance_trader_macd.backtest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;

@Component
@Log4j2
@RequiredArgsConstructor
public class BacktestDatasetLoader {

    private final ObjectMapper objectMapper;

    public BacktestDataset load(Path datasetPath) {
        Objects.requireNonNull(datasetPath, "Dataset path cannot be null");
        log.info("Loading backtest dataset from {}", datasetPath);
        try {
            BacktestDataset dataset = objectMapper.readValue(Files.newBufferedReader(datasetPath), BacktestDataset.class);
            if (dataset.getName() == null || dataset.getName().isBlank()) {
                dataset.setName(datasetPath.getFileName().toString());
            }
            if (dataset.getKlines() == null) {
                throw new IllegalStateException("Dataset " + dataset.getName() + " does not contain klines");
            }
            List<KlineEvent> sorted = dataset.getKlines().stream()
                    .sorted(Comparator.comparingLong(KlineEvent::getCloseTime))
                    .toList();
            dataset.setKlines(sorted);
            log.info("Loaded dataset '{}' with {} klines", dataset.getName(), sorted.size());
            return dataset;
        } catch (IOException e) {
            throw new IllegalStateException("Failed to load dataset from " + datasetPath, e);
        }
    }
}
