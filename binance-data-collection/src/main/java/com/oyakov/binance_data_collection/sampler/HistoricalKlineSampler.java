package com.oyakov.binance_data_collection.sampler;

import com.oyakov.binance_data_collection.rest.client.binance.BinanceRestKlineClient;
import com.oyakov.binance_shared_model.avro.KlineEvent;
import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Component
@Log4j2
@RequiredArgsConstructor
public class HistoricalKlineSampler {

    private final BinanceRestKlineClient klineClient;
    private final HistoricalSamplerProperties properties;
    private final BacktestDatasetFileWriter datasetWriter;

    public List<Path> collect() {
        Instant collectedAt = Instant.now();
        List<Path> savedFiles = new ArrayList<>();
        for (String symbol : properties.getSymbols()) {
            for (String interval : properties.getIntervals()) {
                List<KlineEvent> klines = klineClient.fetchHistoricalKlines(
                        symbol,
                        interval,
                        properties.getLimit(),
                        properties.getStartTime(),
                        properties.getEndTime());
                if (klines.isEmpty()) {
                    log.warn("No klines received for {} {}", symbol, interval);
                    continue;
                }
                BacktestDataset dataset = BacktestDataset.builder()
                        .name(symbol + "_" + interval)
                        .symbol(symbol.toUpperCase())
                        .interval(interval)
                        .collectedAt(collectedAt)
                        .klines(klines)
                        .build();
                savedFiles.add(datasetWriter.writeDataset(dataset, properties.getOutputDirectory()));
            }
        }
        return savedFiles;
    }
}
