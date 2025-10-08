package com.oyakov.binance_data_storage.metrics;

import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class DataStorageMetricsTest {

    private SimpleMeterRegistry meterRegistry;
    private DataStorageMetrics metrics;

    @BeforeEach
    void setUp() {
        meterRegistry = new SimpleMeterRegistry();
        metrics = new DataStorageMetrics(meterRegistry);
        metrics.init();
    }

    @AfterEach
    void tearDown() {
        meterRegistry.close();
    }

    @Test
    void incrementKlineEventsSavedAddsSymbolTags() {
        metrics.incrementKlineEventsSaved("BTCUSDT", "1m");

        double total = meterRegistry.get("binance_data_storage_kline_events_saved_total")
                .counter()
                .count();
        assertEquals(1.0, total, 0.0001);

        double tagged = meterRegistry.get("binance_data_storage_kline_events_saved_total")
                .tag("symbol", "BTCUSDT")
                .tag("interval", "1m")
                .counter()
                .count();
        assertEquals(1.0, tagged, 0.0001);
    }

    @Test
    void incrementPostgresSaveFailuresTracksReason() {
        metrics.incrementPostgresSaveFailures("ETHUSDT", "5m", "DuplicateKey");

        double total = meterRegistry.get("binance_data_storage_postgres_save_failures_total")
                .counter()
                .count();
        assertEquals(1.0, total, 0.0001);

        double tagged = meterRegistry.get("binance_data_storage_postgres_save_failures_total")
                .tag("symbol", "ETHUSDT")
                .tag("interval", "5m")
                .tag("reason", "DuplicateKey")
                .counter()
                .count();
        assertEquals(1.0, tagged, 0.0001);
    }

    @Test
    void recordPostgresSaveTimeAddsStatusTag() {
        Timer.Sample sample = metrics.startPostgresSave();
        metrics.recordPostgresSaveTime(sample, "SOLUSDT", "15m", "success");

        Timer timer = meterRegistry.get("binance_data_storage_postgres_save_duration_seconds")
                .tag("symbol", "SOLUSDT")
                .tag("interval", "15m")
                .tag("status", "success")
                .timer();

        assertNotNull(timer);
        assertEquals(1, timer.count());
    }
}
