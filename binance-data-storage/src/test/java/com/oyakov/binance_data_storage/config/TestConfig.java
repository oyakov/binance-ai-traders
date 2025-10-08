package com.oyakov.binance_data_storage.config;

import com.oyakov.binance_data_storage.metrics.DataStorageMetrics;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

import static org.mockito.Mockito.mock;

@TestConfiguration
public class TestConfig {

    @Bean
    @Primary
    public DataStorageMetrics dataStorageMetrics() {
        return mock(DataStorageMetrics.class);
    }
}
