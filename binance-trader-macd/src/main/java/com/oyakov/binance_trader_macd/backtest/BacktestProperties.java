package com.oyakov.binance_trader_macd.backtest;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

@Data
@Component
@ConfigurationProperties(prefix = "backtest")
public class BacktestProperties {

    private boolean enabled = false;
    private List<Path> datasetPaths = new ArrayList<>();
    private Report report = new Report();

    @Data
    public static class Report {
        private Path json;
        private Path csv;
    }
}
