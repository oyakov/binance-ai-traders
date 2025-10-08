package com.oyakov.binance_data_collection.metrics;

import io.micrometer.core.instrument.simple.SimpleMeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

class DataCollectionMetricsTest {

    private SimpleMeterRegistry meterRegistry;
    private DataCollectionMetrics metrics;

    @BeforeEach
    void setUp() {
        meterRegistry = new SimpleMeterRegistry();
        metrics = new DataCollectionMetrics(meterRegistry);
        metrics.init();
    }

    @AfterEach
    void tearDown() {
        meterRegistry.close();
    }

    @Test
    void incrementKlineEventsReceivedRegistersTaggedCounters() {
        metrics.incrementKlineEventsReceived("BTCUSDT", "1m");

        double total = meterRegistry.get("binance_data_collection_kline_events_received_total")
                .counter()
                .count();
        assertEquals(1.0, total, 0.0001);

        double tagged = meterRegistry.get("binance_data_collection_kline_events_received_total")
                .tag("symbol", "BTCUSDT")
                .tag("interval", "1m")
                .counter()
                .count();
        assertEquals(1.0, tagged, 0.0001);
    }

    @Test
    void incrementKlineEventsFailedToSendAddsErrorTag() {
        metrics.incrementKlineEventsFailedToSend("ETHUSDT", "5m", "Timeout");

        double total = meterRegistry.get("binance_data_collection_kline_events_failed_kafka_total")
                .counter()
                .count();
        assertEquals(1.0, total, 0.0001);

        double tagged = meterRegistry.get("binance_data_collection_kline_events_failed_kafka_total")
                .tag("symbol", "ETHUSDT")
                .tag("interval", "5m")
                .tag("error", "Timeout")
                .counter()
                .count();
        assertEquals(1.0, tagged, 0.0001);
    }

    @Test
    void recordKafkaSendTimeCreatesTaggedTimer() {
        Timer.Sample sample = metrics.startKafkaSend();
        metrics.recordKafkaSendTime(sample, "SOLUSDT", "15m", "success");

        Timer timer = meterRegistry.get("binance_data_collection_kafka_send_duration_seconds")
                .tag("symbol", "SOLUSDT")
                .tag("interval", "15m")
                .tag("status", "success")
                .timer();

        assertNotNull(timer);
        assertEquals(1, timer.count());
    }
}
