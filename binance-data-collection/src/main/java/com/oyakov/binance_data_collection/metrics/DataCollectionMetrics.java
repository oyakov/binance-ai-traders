package com.oyakov.binance_data_collection.metrics;

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
 * Metrics for Binance Data Collection Service
 * Provides comprehensive monitoring for kline data flow
 */
@Component
@Log4j2
@RequiredArgsConstructor
public class DataCollectionMetrics {

    private final MeterRegistry meterRegistry;

    private final Map<String, Counter> taggedCounters = new ConcurrentHashMap<>();
    private final Map<String, Timer> taggedTimers = new ConcurrentHashMap<>();
    
    // Counters for events
    private Counter klineEventsReceived;
    private Counter klineEventsSentToKafka;
    private Counter klineEventsFailedToSend;
    private Counter websocketConnectionsEstablished;
    private Counter websocketConnectionsFailed;
    private Counter websocketConnectionsClosed;
    private Counter restApiCallsTotal;
    private Counter restApiCallsFailed;
    
    // Gauges for current state
    private final AtomicInteger activeWebsocketConnections = new AtomicInteger(0);
    private final AtomicInteger activeKlineStreams = new AtomicInteger(0);
    private final AtomicLong lastKlineEventTimestamp = new AtomicLong(0);
    private final AtomicLong lastWebsocketConnectionTimestamp = new AtomicLong(0);
    
    // Timers for performance monitoring
    private Timer klineEventProcessingTime;
    private Timer kafkaSendTime;
    private Timer websocketConnectionTime;
    private Timer restApiCallTime;

    @PostConstruct
    public void init() {
        // Initialize counters
        klineEventsReceived = Counter.builder("binance_data_collection_kline_events_received_total")
                .description("Total number of kline events received from Binance WebSocket")
                .register(meterRegistry);
        
        klineEventsSentToKafka = Counter.builder("binance_data_collection_kline_events_sent_kafka_total")
                .description("Total number of kline events sent to Kafka")
                .register(meterRegistry);
        
        klineEventsFailedToSend = Counter.builder("binance_data_collection_kline_events_failed_kafka_total")
                .description("Total number of kline events that failed to send to Kafka")
                .register(meterRegistry);
        
        websocketConnectionsEstablished = Counter.builder("binance_data_collection_websocket_connections_established_total")
                .description("Total number of WebSocket connections established")
                .register(meterRegistry);
        
        websocketConnectionsFailed = Counter.builder("binance_data_collection_websocket_connections_failed_total")
                .description("Total number of WebSocket connection failures")
                .register(meterRegistry);
        
        websocketConnectionsClosed = Counter.builder("binance_data_collection_websocket_connections_closed_total")
                .description("Total number of WebSocket connections closed")
                .register(meterRegistry);
        
        restApiCallsTotal = Counter.builder("binance_data_collection_rest_api_calls_total")
                .description("Total number of REST API calls to Binance")
                .register(meterRegistry);
        
        restApiCallsFailed = Counter.builder("binance_data_collection_rest_api_calls_failed_total")
                .description("Total number of failed REST API calls to Binance")
                .register(meterRegistry);
        
        // Initialize timers
        klineEventProcessingTime = Timer.builder("binance_data_collection_kline_event_processing_duration_seconds")
                .description("Time taken to process a kline event")
                .register(meterRegistry);
        
        kafkaSendTime = Timer.builder("binance_data_collection_kafka_send_duration_seconds")
                .description("Time taken to send kline event to Kafka")
                .register(meterRegistry);
        
        websocketConnectionTime = Timer.builder("binance_data_collection_websocket_connection_duration_seconds")
                .description("Time taken to establish WebSocket connection")
                .register(meterRegistry);
        
        restApiCallTime = Timer.builder("binance_data_collection_rest_api_call_duration_seconds")
                .description("Time taken to make REST API call to Binance")
                .register(meterRegistry);
        
        // Register gauges
        Gauge.builder("binance_data_collection_active_websocket_connections", activeWebsocketConnections, AtomicInteger::get)
                .description("Number of active WebSocket connections")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_collection_active_kline_streams", activeKlineStreams, AtomicInteger::get)
                .description("Number of active kline streams")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_collection_last_kline_event_timestamp", lastKlineEventTimestamp, AtomicLong::get)
                .description("Timestamp of the last received kline event")
                .register(meterRegistry);
        
        Gauge.builder("binance_data_collection_last_websocket_connection_timestamp", lastWebsocketConnectionTimestamp, AtomicLong::get)
                .description("Timestamp of the last WebSocket connection")
                .register(meterRegistry);
    }

    // Event counters
    public void incrementKlineEventsReceived() {
        klineEventsReceived.increment();
        lastKlineEventTimestamp.set(System.currentTimeMillis());
    }

    public void incrementKlineEventsReceived(String symbol, String interval) {
        incrementKlineEventsReceived();
        counterWithTags("binance_data_collection_kline_events_received_total",
                "Total number of kline events received from Binance WebSocket",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementKlineEventsSentToKafka() {
        klineEventsSentToKafka.increment();
    }

    public void incrementKlineEventsSentToKafka(String symbol, String interval) {
        incrementKlineEventsSentToKafka();
        counterWithTags("binance_data_collection_kline_events_sent_kafka_total",
                "Total number of kline events sent to Kafka",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementKlineEventsFailedToSend() {
        klineEventsFailedToSend.increment();
    }

    public void incrementKlineEventsFailedToSend(String symbol, String interval, String error) {
        incrementKlineEventsFailedToSend();
        counterWithTags("binance_data_collection_kline_events_failed_kafka_total",
                "Total number of kline events that failed to send to Kafka",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "error", sanitize(error))
                .increment();
    }

    public void incrementWebsocketConnectionsEstablished() {
        websocketConnectionsEstablished.increment();
        activeWebsocketConnections.incrementAndGet();
        lastWebsocketConnectionTimestamp.set(System.currentTimeMillis());
    }

    public void incrementWebsocketConnectionsEstablished(String symbol, String interval) {
        incrementWebsocketConnectionsEstablished();
        counterWithTags("binance_data_collection_websocket_connections_established_total",
                "Total number of WebSocket connections established",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementWebsocketConnectionsFailed() {
        websocketConnectionsFailed.increment();
    }

    public void incrementWebsocketConnectionsFailed(String symbol, String interval, String reason) {
        incrementWebsocketConnectionsFailed();
        counterWithTags("binance_data_collection_websocket_connections_failed_total",
                "Total number of WebSocket connection failures",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "reason", sanitize(reason))
                .increment();
    }

    public void incrementWebsocketConnectionsClosed() {
        websocketConnectionsClosed.increment();
        activeWebsocketConnections.decrementAndGet();
    }

    public void incrementWebsocketConnectionsClosed(String symbol, String interval) {
        incrementWebsocketConnectionsClosed();
        counterWithTags("binance_data_collection_websocket_connections_closed_total",
                "Total number of WebSocket connections closed",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval))
                .increment();
    }

    public void incrementRestApiCallsTotal() {
        restApiCallsTotal.increment();
    }

    public void incrementRestApiCallsTotal(String symbol, String interval, String operation) {
        incrementRestApiCallsTotal();
        counterWithTags("binance_data_collection_rest_api_calls_total",
                "Total number of REST API calls to Binance",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "operation", sanitize(operation))
                .increment();
    }

    public void incrementRestApiCallsFailed() {
        restApiCallsFailed.increment();
    }

    public void incrementRestApiCallsFailed(String symbol, String interval, String operation, String reason) {
        incrementRestApiCallsFailed();
        counterWithTags("binance_data_collection_rest_api_calls_failed_total",
                "Total number of failed REST API calls to Binance",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "operation", sanitize(operation),
                "reason", sanitize(reason))
                .increment();
    }
    
    // Stream management
    public void setActiveKlineStreams(int count) {
        activeKlineStreams.set(count);
    }
    
    public void incrementActiveKlineStreams() {
        activeKlineStreams.incrementAndGet();
    }
    
    public void decrementActiveKlineStreams() {
        activeKlineStreams.decrementAndGet();
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
        timerWithTags("binance_data_collection_kline_event_processing_duration_seconds",
                "Time taken to process a kline event",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startKafkaSend() {
        return Timer.start(meterRegistry);
    }

    public void recordKafkaSendTime(Timer.Sample sample) {
        recordKafkaSendTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordKafkaSendTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(kafkaSendTime);
        timerWithTags("binance_data_collection_kafka_send_duration_seconds",
                "Time taken to send kline event to Kafka",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startWebsocketConnection() {
        return Timer.start(meterRegistry);
    }

    public void recordWebsocketConnectionTime(Timer.Sample sample) {
        recordWebsocketConnectionTime(sample, "unknown", "unknown", "unknown");
    }

    public void recordWebsocketConnectionTime(Timer.Sample sample, String symbol, String interval, String status) {
        long duration = sample.stop(websocketConnectionTime);
        timerWithTags("binance_data_collection_websocket_connection_duration_seconds",
                "Time taken to establish WebSocket connection",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "status", sanitize(status))
                .record(duration, TimeUnit.NANOSECONDS);
    }

    public Timer.Sample startRestApiCall() {
        return Timer.start(meterRegistry);
    }

    public void recordRestApiCallTime(Timer.Sample sample) {
        recordRestApiCallTime(sample, "unknown", "unknown", "unknown", "unknown");
    }

    public void recordRestApiCallTime(Timer.Sample sample, String symbol, String interval, String operation, String status) {
        long duration = sample.stop(restApiCallTime);
        timerWithTags("binance_data_collection_rest_api_call_duration_seconds",
                "Time taken to make REST API call to Binance",
                "symbol", sanitize(symbol),
                "interval", sanitize(interval),
                "operation", sanitize(operation),
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
