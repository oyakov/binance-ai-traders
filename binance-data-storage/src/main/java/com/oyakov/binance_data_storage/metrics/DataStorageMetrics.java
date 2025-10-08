package com.oyakov.binance_data_storage.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

/**
 * Metrics for Binance Data Storage Service
 * Provides comprehensive monitoring for kline data storage and processing
 */
@Component
@Log4j2
@RequiredArgsConstructor
public class DataStorageMetrics {

    private final MeterRegistry meterRegistry;

    private final Map<String, Counter> taggedCounters = new ConcurrentHashMap<>();
    private final Map<String, Timer> taggedTimers = new ConcurrentHashMap<>();
    
    // Counters for events
    private Counter klineEventsReceived;
    private Counter klineEventsSaved;
    private Counter klineEventsFailed;
    private Counter klineEventsCompensated;
    private Counter postgresSaves;
    private Counter postgresSaveFailures;
    private Counter elasticsearchSaves;
    private Counter elasticsearchSaveFailures;
    private Counter kafkaConsumerErrors;
    
    // Gauges for current state
    private final AtomicInteger activeKafkaConsumers = new AtomicInteger(0);
    private final AtomicLong lastKlineEventTimestamp = new AtomicLong(0);
    private final AtomicLong lastSuccessfulSaveTimestamp = new AtomicLong(0);
    private final AtomicInteger postgresConnectionStatus = new AtomicInteger(0);
    private final AtomicInteger elasticsearchConnectionStatus = new AtomicInteger(0);
    
    // Timers for performance monitoring
    private Timer klineEventProcessingTime;
    private Timer postgresSaveTime;
    private Timer elasticsearchSaveTime;
    private Timer kafkaConsumerProcessingTime;

    @PostConstruct
    public void init() {
        // Initialize counters
        klineEventsReceived = Counter.builder("binance_data_storage_kline_events_received_total")
                .description("Total number of kline events received from Kafka")
                .register(meterRegistry);
        
        klineEventsSaved = Counter.builder("binance_data_storage_kline_events_saved_total")
                .description("Total number of kline events successfully saved to storage")
                .register(meterRegistry);
        
        klineEventsFailed = Counter.builder("binance_data_storage_kline_events_failed_total")
                .description("Total number of kline events that failed to save")
                .register(meterRegistry);
        
        klineEventsCompensated = Counter.builder("binance_data_storage_kline_events_compensated_total")
                .description("Total number of kline events compensated/rolled back")
                .register(meterRegistry);
        
        postgresSaves = Counter.builder("binance_data_storage_postgres_saves_total")
                .description("Total number of successful PostgreSQL saves")
                .register(meterRegistry);
        
        postgresSaveFailures = Counter.builder("binance_data_storage_postgres_save_failures_total")
                .description("Total number of PostgreSQL save failures")
                .register(meterRegistry);
        
        elasticsearchSaves = Counter.builder("binance_data_storage_elasticsearch_saves_total")
                .description("Total number of successful Elasticsearch saves")
                .register(meterRegistry);
        
        elasticsearchSaveFailures = Counter.builder("binance_data_storage_elasticsearch_save_failures_total")
                .description("Total number of Elasticsearch save failures")
                .register(meterRegistry);
        
        kafkaConsumerErrors = Counter.builder("binance_data_storage_kafka_consumer_errors_total")
                .description("Total number of Kafka consumer errors")
                .register(meterRegistry);
        
        // Initialize timers
        klineEventProcessingTime = Timer.builder("binance_data_storage_kline_event_processing_duration_seconds")
                .description("Time taken to process a kline event")
                .register(meterRegistry);
        
        postgresSaveTime = Timer.builder("binance_data_storage_postgres_save_duration_seconds")
                .description("Time taken to save kline event to PostgreSQL")
                .register(meterRegistry);
        
        elasticsearchSaveTime = Timer.builder("binance_data_storage_elasticsearch_save_duration_seconds")
                .description("Time taken to save kline event to Elasticsearch")
                .register(meterRegistry);
        
        kafkaConsumerProcessingTime = Timer.builder("binance_data_storage_kafka_consumer_processing_duration_seconds")
                .description("Time taken to process a Kafka message")
                .register(meterRegistry);
        
        // Register gauges
        Gauge.builder("binance_data_storage_active_kafka_consumers", activeKafkaConsumers, AtomicInteger::get)
                .description("Number of active Kafka consumers")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_storage_last_kline_event_timestamp", lastKlineEventTimestamp, AtomicLong::get)
                .description("Timestamp of the last received kline event")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_storage_last_successful_save_timestamp", lastSuccessfulSaveTimestamp, AtomicLong::get)
                .description("Timestamp of the last successful save")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_storage_postgres_connection_status", postgresConnectionStatus, AtomicInteger::get)
                .description("PostgreSQL connection status (1=connected, 0=disconnected)")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_storage_elasticsearch_connection_status", elasticsearchConnectionStatus, AtomicInteger::get)
                .description("Elasticsearch connection status (1=connected, 0=disconnected)")
                .register(meterRegistry);
    }

    // Event counters
    public void incrementKlineEventsReceived() {
        klineEventsReceived.increment();
        lastKlineEventTimestamp.set(System.currentTimeMillis());
    }

    public void incrementKlineEventsReceived(String symbol, String interval) {
        incrementKlineEventsReceived();
        counterWithTags("binance_data_storage_kline_events_received_total",
                "Total number of kline events received from Kafka",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementKlineEventsSaved() {
        klineEventsSaved.increment();
        lastSuccessfulSaveTimestamp.set(System.currentTimeMillis());
    }

    public void incrementKlineEventsSaved(String symbol, String interval) {
        incrementKlineEventsSaved();
        counterWithTags("binance_data_storage_kline_events_saved_total",
                "Total number of kline events successfully saved to storage",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementKlineEventsFailed() {
        klineEventsFailed.increment();
    }

    public void incrementKlineEventsFailed(String symbol, String interval, String error) {
        incrementKlineEventsFailed();
        counterWithTags("binance_data_storage_kline_events_failed_total",
                "Total number of kline events that failed to save",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "error", sanitize(error))
                .increment();
    }

    public void incrementKlineEventsCompensated() {
        klineEventsCompensated.increment();
    }

    public void incrementPostgresSaves() {
        postgresSaves.increment();
    }

    public void incrementPostgresSaves(String symbol, String interval) {
        incrementPostgresSaves();
        counterWithTags("binance_data_storage_postgres_saves_total",
                "Total number of successful PostgreSQL saves",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementPostgresSaveFailures() {
        postgresSaveFailures.increment();
    }

    public void incrementPostgresSaveFailures(String symbol, String interval, String reason) {
        incrementPostgresSaveFailures();
        counterWithTags("binance_data_storage_postgres_save_failures_total",
                "Total number of PostgreSQL save failures",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "reason", sanitize(reason))
                .increment();
    }

    public void incrementElasticsearchSaves() {
        elasticsearchSaves.increment();
    }

    public void incrementElasticsearchSaves(String symbol, String interval) {
        incrementElasticsearchSaves();
        counterWithTags("binance_data_storage_elasticsearch_saves_total",
                "Total number of successful Elasticsearch saves",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementElasticsearchSaveFailures() {
        elasticsearchSaveFailures.increment();
    }

    public void incrementElasticsearchSaveFailures(String symbol, String interval, String reason) {
        incrementElasticsearchSaveFailures();
        counterWithTags("binance_data_storage_elasticsearch_save_failures_total",
                "Total number of Elasticsearch save failures",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "reason", sanitize(reason))
                .increment();
    }

    public void incrementKafkaConsumerErrors() {
        kafkaConsumerErrors.increment();
    }
    
    // Connection status
    public void setPostgresConnectionStatus(boolean connected) {
        postgresConnectionStatus.set(connected ? 1 : 0);
    }
    
    public void setElasticsearchConnectionStatus(boolean connected) {
        elasticsearchConnectionStatus.set(connected ? 1 : 0);
    }
    
    // Consumer management
    public void incrementActiveKafkaConsumers() {
        activeKafkaConsumers.incrementAndGet();
    }
    
    public void decrementActiveKafkaConsumers() {
        activeKafkaConsumers.decrementAndGet();
    }
    
    // Timers
    public Timer.Sample startKlineEventProcessing() {
        return Timer.start(meterRegistry);
    }
    
    public void recordKlineEventProcessingTime(Timer.Sample sample) {
        recordKlineEventProcessingTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordKlineEventProcessingTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(klineEventProcessingTime);
        timerWithTags("binance_data_storage_kline_event_processing_duration_seconds",
                "Time taken to process a kline event",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startPostgresSave() {
        return Timer.start(meterRegistry);
    }

    public void recordPostgresSaveTime(Timer.Sample sample) {
        recordPostgresSaveTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordPostgresSaveTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(postgresSaveTime);
        timerWithTags("binance_data_storage_postgres_save_duration_seconds",
                "Time taken to save kline event to PostgreSQL",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startElasticsearchSave() {
        return Timer.start(meterRegistry);
    }

    public void recordElasticsearchSaveTime(Timer.Sample sample) {
        recordElasticsearchSaveTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordElasticsearchSaveTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(elasticsearchSaveTime);
        timerWithTags("binance_data_storage_elasticsearch_save_duration_seconds",
                "Time taken to save kline event to Elasticsearch",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startKafkaConsumerProcessing() {
        return Timer.start(meterRegistry);
    }

    public void recordKafkaConsumerProcessingTime(Timer.Sample sample) {
        recordKafkaConsumerProcessingTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordKafkaConsumerProcessingTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(kafkaConsumerProcessingTime);
        timerWithTags("binance_data_storage_kafka_consumer_processing_duration_seconds",
                "Time taken to process a Kafka message",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    private Counter counterWithTags(String name, String description, String... tags) {
        String key = buildKey(name, tags);
        return taggedCounters.computeIfAbsent(key, k -> Counter.builder(name)
                .description(description)
                .tags(tags)
                .register(meterRegistry));
    }

    private Timer timerWithTags(String name, String description, String... tags) {
        String key = buildKey(name, tags);
        return taggedTimers.computeIfAbsent(key, k -> Timer.builder(name)
                .description(description)
                .tags(tags)
                .register(meterRegistry));
    }

    private String sanitize(String value) {
        return value == null || value.isBlank() ? "unknown" : value;
    }

    private String buildKey(String name, String... tags) {
        StringBuilder builder = new StringBuilder(name);
        for (String tag : tags) {
            builder.append('|').append(tag == null ? "" : tag);
        }
        return builder.toString();
    }
}
