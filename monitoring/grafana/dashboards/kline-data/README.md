# Kline Data Dashboards

This directory contains comprehensive Grafana dashboards for monitoring kline data collection, streaming, and storage in the Binance AI Traders system.

## Dashboard Overview

### 1. Kline Collection Overview (`kline-collection-overview.json`)
**Purpose**: High-level monitoring of the data collection pipeline
**Key Metrics**:
- Service health status (Data Collection, Data Storage, Kafka, PostgreSQL)
- Kline records count and collection rate
- Error rates and processing latency
- Data collection timeline

### 2. Live Price Charts (`kline-price-charts.json`)
**Purpose**: Real-time price visualization and analysis
**Key Features**:
- Interactive price charts with OHLC data
- Volume analysis
- Multi-symbol comparison
- Price volatility metrics
- Template variables for symbol and interval selection

### 3. Streaming Monitor (`kline-streaming-monitor.json`)
**Purpose**: WebSocket streaming health and performance
**Key Metrics**:
- WebSocket connection status
- Active streams count
- Message processing rates
- Queue sizes and latency distribution
- Memory usage monitoring

### 4. Storage Monitor (`kline-storage-monitor.json`)
**Purpose**: Database and Elasticsearch storage monitoring
**Key Metrics**:
- PostgreSQL and Elasticsearch health
- Storage success rates
- Connection pool monitoring
- Index health and document counts
- Storage latency and error rates

### 5. Alerts & Health (`kline-alerts.json`)
**Purpose**: Alerting and system health overview
**Key Features**:
- Critical alert indicators
- System health overview
- Error rate trends
- Data quality metrics
- Performance and resource utilization

## Metrics Required

These dashboards expect the following Prometheus metrics to be available:

### Data Collection Metrics
- `binance_data_collection_kline_events_received_total{symbol,interval}` - Total kline events received from WebSocket streams
- `binance_data_collection_kline_events_sent_kafka_total{symbol,interval}` - Successful kline events published to Kafka
- `binance_data_collection_kline_events_failed_kafka_total{symbol,interval,error}` - Failed Kafka publish attempts with error classification
- `binance_data_collection_kafka_send_duration_seconds_{sum,count}{symbol,interval,status}` - Kafka publish latency histogram data
- `binance_data_collection_websocket_connections_{established,failed,closed}_total{symbol,interval}` - WebSocket lifecycle counters
- `binance_data_collection_rest_api_calls_{total,failed}_total{symbol,interval,operation,reason}` - REST warmup call success/failure metrics
- `binance_data_collection_active_websocket_connections` - Current count of active WebSocket sessions
- `binance_data_collection_active_kline_streams` - Active kline stream subscriptions

### Storage Metrics
- `binance_data_storage_kline_events_saved_total{symbol,interval}` - Persisted kline events across repositories
- `binance_data_storage_kline_events_failed_total{symbol,interval,error}` - Storage failures by symbol and interval
- `binance_data_storage_postgres_save_duration_seconds_{sum,count}{symbol,interval,status}` - PostgreSQL write latency histogram data
- `binance_data_storage_elasticsearch_save_duration_seconds_{sum,count}{symbol,interval,status}` - Elasticsearch write latency histogram data
- `binance_data_storage_postgres_{saves,save_failures}_total{symbol,interval,reason}` - PostgreSQL success/failure counters
- `binance_data_storage_elasticsearch_{saves,save_failures}_total{symbol,interval,reason}` - Elasticsearch success/failure counters
- `binance_data_storage_postgres_connection_status` - PostgreSQL connection health (1=up)
- `binance_data_storage_elasticsearch_connection_status` - Elasticsearch connection health (1=up)
- `binance_data_storage_active_kafka_consumers` - Current Kafka consumer count
- `binance_data_storage_kafka_consumer_processing_duration_seconds_{sum,count}{symbol,interval,status}` - Kafka consumer processing latency

### Price Data Metrics
- Price charts leverage persisted data; refer to analytics dashboards for OHLC and volume metrics derived from storage outputs.

### System Metrics
- `up{job}` - Service availability
- `jvm_memory_used_bytes` - JVM memory usage
- `jvm_memory_max_bytes` - JVM max memory
- `hikaricp_connections_active` - Database connection pool
- `elasticsearch_indices_docs_count` - Elasticsearch document count

## Usage

1. **Import Dashboards**: Import these JSON files into your Grafana instance
2. **Configure Data Source**: Ensure Prometheus is configured as a data source
3. **Set Up Metrics**: Implement the required metrics in your applications
4. **Customize**: Adjust thresholds and alerts based on your requirements

## Alerting Rules

The dashboards include built-in alerting for:
- WebSocket disconnections
- Data collection failures
- Storage errors
- High latency
- Memory usage thresholds
- Queue size limits

## Customization

- **Time Ranges**: Adjust default time ranges in each dashboard
- **Refresh Rates**: Modify refresh intervals based on your needs
- **Thresholds**: Update alert thresholds for your environment
- **Visualizations**: Add or modify panels as needed
- **Templates**: Use template variables for dynamic filtering

## Integration

These dashboards integrate with:
- Prometheus for metrics collection
- Grafana for visualization
- AlertManager for notifications
- The Binance AI Traders data pipeline

## Maintenance

- **Regular Updates**: Update dashboards as new metrics are added
- **Performance**: Monitor dashboard performance with large datasets
- **Backup**: Export and backup dashboard configurations
- **Documentation**: Keep this README updated with changes
