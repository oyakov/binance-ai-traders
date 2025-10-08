package com.oyakov.binance_data_storage.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Metrics for Binance Data Storage Service
 * Provides comprehensive monitoring for kline data storage and processing
 */
@Component
@Log4j2
@RequiredArgsConstructor
public class DataStorageMetrics {

    private final MeterRegistry meterRegistry;
    
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
        klineEventsReceived.increment();
        lastKlineEventTimestamp.set(System.currentTimeMillis());
    }
    
    public void incrementKlineEventsSaved() {
        klineEventsSaved.increment();
        lastSuccessfulSaveTimestamp.set(System.currentTimeMillis());
    }
    
    public void incrementKlineEventsSaved(String symbol, String interval) {
        klineEventsSaved.increment();
        lastSuccessfulSaveTimestamp.set(System.currentTimeMillis());
    }
    
    public void incrementKlineEventsFailed() {
        klineEventsFailed.increment();
    }
    
    public void incrementKlineEventsFailed(String symbol, String interval, String error) {
        klineEventsFailed.increment();
    }
    
    public void incrementKlineEventsCompensated() {
        klineEventsCompensated.increment();
    }
    
    public void incrementPostgresSaves() {
        postgresSaves.increment();
    }
    
    public void incrementPostgresSaveFailures() {
        postgresSaveFailures.increment();
    }
    
    public void incrementElasticsearchSaves() {
        elasticsearchSaves.increment();
    }
    
    public void incrementElasticsearchSaveFailures() {
        elasticsearchSaveFailures.increment();
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
        sample.stop(klineEventProcessingTime);
    }
    
    public Timer.Sample startPostgresSave() {
        return Timer.start(meterRegistry);
    }
    
    public void recordPostgresSaveTime(Timer.Sample sample) {
        sample.stop(postgresSaveTime);
    }
    
    public Timer.Sample startElasticsearchSave() {
        return Timer.start(meterRegistry);
    }
    
    public void recordElasticsearchSaveTime(Timer.Sample sample) {
        sample.stop(elasticsearchSaveTime);
    }
    
    public Timer.Sample startKafkaConsumerProcessing() {
        return Timer.start(meterRegistry);
    }
    
    public void recordKafkaConsumerProcessingTime(Timer.Sample sample) {
        sample.stop(kafkaConsumerProcessingTime);
    }
}
