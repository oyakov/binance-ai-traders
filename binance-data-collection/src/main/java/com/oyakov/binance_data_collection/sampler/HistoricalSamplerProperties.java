package com.oyakov.binance_data_collection.sampler;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@Data
@Component
@ConfigurationProperties(prefix = "binance.sampler")
public class HistoricalSamplerProperties {

    private boolean enabled = false;
    private List<String> symbols = new ArrayList<>(Arrays.asList(
            "BTCUSDT",
            "ETHUSDT",
            "ADAUSDT",
            "BNBUSDT",
            "SOLUSDT",
            "XRPUSDT",
            "MATICUSDT",
            "LTCUSDT"
    ));
    private List<String> intervals = new ArrayList<>(Arrays.asList(
            "15m",
            "1h",
            "2h",
            "4h",
            "6h",
            "1d",
            "1w"
    ));
    private Integer limit = 500;
    private Long startTime;
    private Long endTime;
    private String outputDirectory = "backtest-datasets";
    private List<Integer> dayRanges = new ArrayList<>(Arrays.asList(90, 180, 365, 720));
    private boolean cacheEnabled = true;
    private String cacheDirectory = "backtest-cache";
}
