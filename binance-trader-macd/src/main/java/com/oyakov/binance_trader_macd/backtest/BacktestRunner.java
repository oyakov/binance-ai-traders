package com.oyakov.binance_trader_macd.backtest;

import com.oyakov.binance_shared_model.backtest.BacktestDataset;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Log4j2
@Component
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "backtest", name = "enabled", havingValue = "true")
public class BacktestRunner implements ApplicationRunner {

    private final BacktestProperties properties;
    private final BacktestDatasetLoader datasetLoader;
    private final BacktestEngine backtestEngine;
    private final BacktestReportWriter reportWriter;

    @Override
    public void run(ApplicationArguments args) {
        if (properties.getDatasetPaths().isEmpty()) {
            throw new IllegalStateException("No dataset paths configured for backtesting. Set backtest.dataset-paths");
        }

        List<BacktestMetrics> metrics = new ArrayList<>();
        for (Path path : properties.getDatasetPaths()) {
            BacktestDataset dataset = datasetLoader.load(path);
            metrics.add(backtestEngine.run(dataset));
        }

        reportWriter.writeJson(properties.getReport().getJson(), metrics);
        reportWriter.writeCsv(properties.getReport().getCsv(), metrics);
    }
}
