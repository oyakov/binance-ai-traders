package com.oyakov.binance_trader_macd.backtest;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.io.BufferedWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

@Component
@Log4j2
@RequiredArgsConstructor
public class BacktestReportWriter {

    private final ObjectMapper objectMapper;

    public void writeJson(Path path, List<BacktestMetrics> metrics) {
        if (path == null) {
            return;
        }
        try {
            createParentDirectories(path);
            objectMapper.writerWithDefaultPrettyPrinter().writeValue(path.toFile(), metrics);
            log.info("Written JSON backtest report to {}", path);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to write JSON report to " + path, e);
        }
    }

    public void writeCsv(Path path, List<BacktestMetrics> metrics) {
        if (path == null) {
            return;
        }
        try {
            createParentDirectories(path);
            try (BufferedWriter writer = Files.newBufferedWriter(path)) {
                writer.write("dataset,totalTrades,winningTrades,losingTrades,breakEvenTrades,netProfit,averageReturn,winRate,maxDrawdown,maxDrawdownPercent,bestTrade,worstTrade");
                writer.newLine();
                for (BacktestMetrics metric : metrics) {
                    writer.write(String.join(",",
                            escape(metric.getDatasetName()),
                            String.valueOf(metric.getTotalTrades()),
                            String.valueOf(metric.getWinningTrades()),
                            String.valueOf(metric.getLosingTrades()),
                            String.valueOf(metric.getBreakEvenTrades()),
                            metric.getNetProfit().toPlainString(),
                            metric.getAverageReturn().toPlainString(),
                            metric.getWinRate().toPlainString(),
                            metric.getMaxDrawdown().toPlainString(),
                            metric.getMaxDrawdownPercent().toPlainString(),
                            metric.getBestTrade().toPlainString(),
                            metric.getWorstTrade().toPlainString()));
                    writer.newLine();
                }
            }
            log.info("Written CSV backtest report to {}", path);
        } catch (IOException e) {
            throw new IllegalStateException("Failed to write CSV report to " + path, e);
        }
    }

    private void createParentDirectories(Path path) throws IOException {
        Path parent = path.getParent();
        if (parent != null && !Files.exists(parent)) {
            Files.createDirectories(parent);
        }
    }

    private String escape(String value) {
        if (value == null) {
            return "";
        }
        if (value.contains(",") || value.contains("\"")) {
            return '"' + value.replace("\"", "\"\"") + '"';
        }
        return value;
    }
}
