# Kline Metrics Implementation Guide

This guide explains how to implement the Prometheus metrics required for the kline monitoring dashboards.

## Overview

The kline monitoring dashboards require specific metrics to be exposed by the data collection and storage services. This document provides implementation examples for Spring Boot applications using Micrometer.

## Required Dependencies

Add these dependencies to your `pom.xml`:

```xml
<dependencies>
    <!-- Micrometer Prometheus -->
    <dependency>
        <groupId>io.micrometer</groupId>
        <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
    
    <!-- Spring Boot Actuator -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

## Configuration

### application.yml

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
    distribution:
      percentiles-histogram:
        kline.processing.duration: true
        kline.websocket.latency: true
        kline.postgres.write.duration: true
        kline.elasticsearch.write.duration: true
```

## Data Collection Service Metrics

### 1. Kline Records Counter

```java
@Component
public class KlineMetrics {
    
    private final Counter klineRecordsTotal;
    private final Counter klineErrorsTotal;
    private final Counter klineMessagesReceivedTotal;
    private final Counter klineMessagesProcessedTotal;
    private final Gauge klineWebsocketConnected;
    private final Gauge klineActiveStreams;
    private final Gauge klineProcessingQueueSize;
    private final Timer klineProcessingDuration;
    private final Timer klineWebsocketLatency;
    
    public KlineMetrics(MeterRegistry meterRegistry) {
        this.klineRecordsTotal = Counter.builder("kline_records_total")
            .description("Total number of kline records processed")
            .register(meterRegistry);
            
        this.klineErrorsTotal = Counter.builder("kline_errors_total")
            .description("Total number of kline processing errors")
            .register(meterRegistry);
            
        this.klineMessagesReceivedTotal = Counter.builder("kline_messages_received_total")
            .description("Total number of WebSocket messages received")
            .register(meterRegistry);
            
        this.klineMessagesProcessedTotal = Counter.builder("kline_messages_processed_total")
            .description("Total number of WebSocket messages processed")
            .register(meterRegistry);
            
        this.klineWebsocketConnected = Gauge.builder("kline_websocket_connected")
            .description("WebSocket connection status (1=connected, 0=disconnected)")
            .register(meterRegistry, this, KlineMetrics::getWebsocketStatus);
            
        this.klineActiveStreams = Gauge.builder("kline_active_streams")
            .description("Number of active kline streams")
            .register(meterRegistry, this, KlineMetrics::getActiveStreamsCount);
            
        this.klineProcessingQueueSize = Gauge.builder("kline_processing_queue_size")
            .description("Current processing queue size")
            .register(meterRegistry, this, KlineMetrics::getQueueSize);
            
        this.klineProcessingDuration = Timer.builder("kline_processing_duration_seconds")
            .description("Kline processing duration")
            .register(meterRegistry);
            
        this.klineWebsocketLatency = Timer.builder("kline_websocket_latency_seconds")
            .description("WebSocket message latency")
            .register(meterRegistry);
    }
    
    public void incrementRecordsTotal() {
        klineRecordsTotal.increment();
    }
    
    public void incrementErrorsTotal() {
        klineErrorsTotal.increment();
    }
    
    public void incrementMessagesReceived() {
        klineMessagesReceivedTotal.increment();
    }
    
    public void incrementMessagesProcessed() {
        klineMessagesProcessedTotal.increment();
    }
    
    public void recordProcessingDuration(Duration duration) {
        klineProcessingDuration.record(duration);
    }
    
    public void recordWebsocketLatency(Duration duration) {
        klineWebsocketLatency.record(duration);
    }
    
    private double getWebsocketStatus() {
        // Return 1 if connected, 0 if disconnected
        return websocketConnected ? 1.0 : 0.0;
    }
    
    private double getActiveStreamsCount() {
        // Return current number of active streams
        return activeStreams.size();
    }
    
    private double getQueueSize() {
        // Return current queue size
        return processingQueue.size();
    }
}
```

### 2. Price Data Metrics

```java
@Component
public class PriceMetrics {
    
    private final Gauge klinePriceOpen;
    private final Gauge klinePriceHigh;
    private final Gauge klinePriceLow;
    private final Gauge klinePriceClose;
    private final Gauge klineVolume;
    private final Gauge klineLatestTimestamp;
    
    public PriceMetrics(MeterRegistry meterRegistry) {
        this.klinePriceOpen = Gauge.builder("kline_price_open")
            .description("Kline open price")
            .tag("symbol", "BTCUSDT")
            .tag("interval", "1m")
            .register(meterRegistry, this, PriceMetrics::getOpenPrice);
            
        this.klinePriceHigh = Gauge.builder("kline_price_high")
            .description("Kline high price")
            .tag("symbol", "BTCUSDT")
            .tag("interval", "1m")
            .register(meterRegistry, this, PriceMetrics::getHighPrice);
            
        this.klinePriceLow = Gauge.builder("kline_price_low")
            .description("Kline low price")
            .tag("symbol", "BTCUSDT")
            .tag("interval", "1m")
            .register(meterRegistry, this, PriceMetrics::getLowPrice);
            
        this.klinePriceClose = Gauge.builder("kline_price_close")
            .description("Kline close price")
            .tag("symbol", "BTCUSDT")
            .tag("interval", "1m")
            .register(meterRegistry, this, PriceMetrics::getClosePrice);
            
        this.klineVolume = Gauge.builder("kline_volume")
            .description("Kline volume")
            .tag("symbol", "BTCUSDT")
            .tag("interval", "1m")
            .register(meterRegistry, this, PriceMetrics::getVolume);
            
        this.klineLatestTimestamp = Gauge.builder("kline_latest_timestamp")
            .description("Latest kline timestamp")
            .register(meterRegistry, this, PriceMetrics::getLatestTimestamp);
    }
    
    public void updatePriceData(KlineEvent klineEvent) {
        // Update price data for metrics
        latestKline = klineEvent;
    }
    
    private double getOpenPrice() {
        return latestKline != null ? latestKline.getOpen().doubleValue() : 0.0;
    }
    
    private double getHighPrice() {
        return latestKline != null ? latestKline.getHigh().doubleValue() : 0.0;
    }
    
    private double getLowPrice() {
        return latestKline != null ? latestKline.getLow().doubleValue() : 0.0;
    }
    
    private double getClosePrice() {
        return latestKline != null ? latestKline.getClose().doubleValue() : 0.0;
    }
    
    private double getVolume() {
        return latestKline != null ? latestKline.getVolume().doubleValue() : 0.0;
    }
    
    private double getLatestTimestamp() {
        return latestKline != null ? latestKline.getEventTime() : 0.0;
    }
}
```

## Data Storage Service Metrics

### 1. Storage Metrics

```java
@Component
public class StorageMetrics {
    
    private final Counter klineRecordsStoredTotal;
    private final Counter klineElasticsearchIndexedTotal;
    private final Counter klineStorageErrorsTotal;
    private final Counter klinePostgresErrorsTotal;
    private final Counter klineElasticsearchErrorsTotal;
    private final Counter klineValidationErrorsTotal;
    private final Timer klinePostgresWriteDuration;
    private final Timer klineElasticsearchWriteDuration;
    
    public StorageMetrics(MeterRegistry meterRegistry) {
        this.klineRecordsStoredTotal = Counter.builder("kline_records_stored_total")
            .description("Total number of kline records stored in PostgreSQL")
            .register(meterRegistry);
            
        this.klineElasticsearchIndexedTotal = Counter.builder("kline_elasticsearch_indexed_total")
            .description("Total number of kline records indexed in Elasticsearch")
            .register(meterRegistry);
            
        this.klineStorageErrorsTotal = Counter.builder("kline_storage_errors_total")
            .description("Total number of storage errors")
            .register(meterRegistry);
            
        this.klinePostgresErrorsTotal = Counter.builder("kline_postgres_errors_total")
            .description("Total number of PostgreSQL errors")
            .register(meterRegistry);
            
        this.klineElasticsearchErrorsTotal = Counter.builder("kline_elasticsearch_errors_total")
            .description("Total number of Elasticsearch errors")
            .register(meterRegistry);
            
        this.klineValidationErrorsTotal = Counter.builder("kline_validation_errors_total")
            .description("Total number of validation errors")
            .register(meterRegistry);
            
        this.klinePostgresWriteDuration = Timer.builder("kline_postgres_write_duration_seconds")
            .description("PostgreSQL write duration")
            .register(meterRegistry);
            
        this.klineElasticsearchWriteDuration = Timer.builder("kline_elasticsearch_write_duration_seconds")
            .description("Elasticsearch write duration")
            .register(meterRegistry);
    }
    
    public void incrementRecordsStored() {
        klineRecordsStoredTotal.increment();
    }
    
    public void incrementElasticsearchIndexed() {
        klineElasticsearchIndexedTotal.increment();
    }
    
    public void incrementStorageErrors() {
        klineStorageErrorsTotal.increment();
    }
    
    public void incrementPostgresErrors() {
        klinePostgresErrorsTotal.increment();
    }
    
    public void incrementElasticsearchErrors() {
        klineElasticsearchErrorsTotal.increment();
    }
    
    public void incrementValidationErrors() {
        klineValidationErrorsTotal.increment();
    }
    
    public void recordPostgresWriteDuration(Duration duration) {
        klinePostgresWriteDuration.record(duration);
    }
    
    public void recordElasticsearchWriteDuration(Duration duration) {
        klineElasticsearchWriteDuration.record(duration);
    }
}
```

## Usage in Services

### Data Collection Service

```java
@Service
public class KlineDataCollectionService {
    
    private final KlineMetrics klineMetrics;
    private final PriceMetrics priceMetrics;
    
    public KlineDataCollectionService(KlineMetrics klineMetrics, PriceMetrics priceMetrics) {
        this.klineMetrics = klineMetrics;
        this.priceMetrics = priceMetrics;
    }
    
    @EventListener
    public void handleKlineEvent(KlineEvent klineEvent) {
        try {
            // Record processing start time
            long startTime = System.currentTimeMillis();
            
            // Process kline event
            processKlineEvent(klineEvent);
            
            // Update metrics
            klineMetrics.incrementRecordsTotal();
            klineMetrics.incrementMessagesProcessed();
            priceMetrics.updatePriceData(klineEvent);
            
            // Record processing duration
            long duration = System.currentTimeMillis() - startTime;
            klineMetrics.recordProcessingDuration(Duration.ofMillis(duration));
            
        } catch (Exception e) {
            klineMetrics.incrementErrorsTotal();
            log.error("Error processing kline event", e);
        }
    }
}
```

### Data Storage Service

```java
@Service
public class KlineDataStorageService {
    
    private final StorageMetrics storageMetrics;
    
    public KlineDataStorageService(StorageMetrics storageMetrics) {
        this.storageMetrics = storageMetrics;
    }
    
    public void storeKlineData(KlineEvent klineEvent) {
        try {
            // Store in PostgreSQL
            long startTime = System.currentTimeMillis();
            postgresRepository.save(klineEvent);
            long postgresDuration = System.currentTimeMillis() - startTime;
            storageMetrics.recordPostgresWriteDuration(Duration.ofMillis(postgresDuration));
            storageMetrics.incrementRecordsStored();
            
            // Store in Elasticsearch
            startTime = System.currentTimeMillis();
            elasticsearchRepository.save(klineEvent);
            long elasticsearchDuration = System.currentTimeMillis() - startTime;
            storageMetrics.recordElasticsearchWriteDuration(Duration.ofMillis(elasticsearchDuration));
            storageMetrics.incrementElasticsearchIndexed();
            
        } catch (Exception e) {
            storageMetrics.incrementStorageErrors();
            if (e instanceof DataAccessException) {
                storageMetrics.incrementPostgresErrors();
            } else if (e instanceof ElasticsearchException) {
                storageMetrics.incrementElasticsearchErrors();
            }
            log.error("Error storing kline data", e);
        }
    }
}
```

## Prometheus Configuration

### prometheus.yml

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'binance-data-collection-testnet'
    static_configs:
      - targets: ['binance-data-collection-testnet:8080']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
    
  - job_name: 'binance-data-storage-testnet'
    static_configs:
      - targets: ['binance-data-storage-testnet:8081']
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
    
  - job_name: 'kafka-testnet'
    static_configs:
      - targets: ['kafka-testnet:9092']
    scrape_interval: 15s
    
  - job_name: 'postgres-testnet'
    static_configs:
      - targets: ['postgres-testnet:5432']
    scrape_interval: 15s
    
  - job_name: 'elasticsearch-testnet'
    static_configs:
      - targets: ['elasticsearch-testnet:9200']
    scrape_interval: 15s
```

## Testing Metrics

### Test Script

```bash
#!/bin/bash
# Test metrics endpoint

echo "Testing data collection metrics..."
curl -s http://localhost:8080/actuator/prometheus | grep kline_

echo "Testing data storage metrics..."
curl -s http://localhost:8081/actuator/prometheus | grep kline_

echo "Testing Prometheus targets..."
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health == "up")'
```

## Dashboard Integration

Once metrics are implemented:

1. **Import Dashboards**: Import the JSON dashboard files into Grafana
2. **Configure Data Source**: Ensure Prometheus is configured as a data source
3. **Verify Metrics**: Check that all required metrics are available
4. **Customize Alerts**: Set up alerting rules based on your requirements
5. **Test Functionality**: Verify all panels display data correctly

## Troubleshooting

### Common Issues

1. **Missing Metrics**: Ensure all required metrics are implemented and exposed
2. **Wrong Labels**: Verify metric labels match dashboard queries
3. **Data Not Appearing**: Check Prometheus targets and scrape configuration
4. **Performance Impact**: Monitor application performance with metrics enabled

### Debug Commands

```bash
# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.'

# Check specific metric
curl -s http://localhost:9090/api/v1/query?query=kline_records_total

# Check Grafana data source
curl -s http://localhost:3001/api/datasources
```

This implementation provides comprehensive monitoring for the kline data pipeline with real-time dashboards and alerting capabilities.
