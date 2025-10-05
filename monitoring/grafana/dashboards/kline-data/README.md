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
- `kline_records_total` - Total kline records processed
- `kline_errors_total` - Total errors encountered
- `kline_processing_duration_seconds` - Processing time histogram
- `kline_websocket_connected` - WebSocket connection status
- `kline_active_streams` - Number of active streams
- `kline_messages_received_total` - Total messages received
- `kline_messages_processed_total` - Total messages processed
- `kline_processing_queue_size` - Current queue size

### Storage Metrics
- `kline_records_stored_total` - Total records stored in PostgreSQL
- `kline_elasticsearch_indexed_total` - Total records indexed in Elasticsearch
- `kline_storage_errors_total` - Total storage errors
- `kline_postgres_errors_total` - PostgreSQL-specific errors
- `kline_elasticsearch_errors_total` - Elasticsearch-specific errors
- `kline_validation_errors_total` - Data validation errors

### Price Data Metrics
- `kline_price_open{symbol, interval}` - Open prices
- `kline_price_high{symbol, interval}` - High prices
- `kline_price_low{symbol, interval}` - Low prices
- `kline_price_close{symbol, interval}` - Close prices
- `kline_volume{symbol, interval}` - Trading volumes

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
