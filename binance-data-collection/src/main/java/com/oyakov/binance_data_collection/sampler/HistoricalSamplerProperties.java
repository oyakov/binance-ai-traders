package com.oyakov.binance_data_collection.sampler;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Data
@Component
@ConfigurationProperties(prefix = "binance.sampler")
public class HistoricalSamplerProperties {

    private boolean enabled = false;
    private List<String> symbols = new ArrayList<>();
    private List<String> intervals = new ArrayList<>();
    private Integer limit = 500;
    private Long startTime;
    private Long endTime;
    private String outputDirectory = "backtest-datasets";
}
