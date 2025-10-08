# 📊 Monitoring Guide - Binance AI Traders

## Overview
Your project has a complete monitoring stack with Prometheus and Grafana already configured to collect and visualize metrics from your services.

## 🚀 Quick Start

### Option 1: Use the Convenience Script
```powershell
.\open-monitoring.ps1
```

### Option 2: Manual Access
- **Prometheus**: http://localhost:9091
- **Grafana**: http://localhost:3001 (admin/testnet_admin)

## 📈 Prometheus (Raw Metrics & Queries)

### Access
- **URL**: http://localhost:9091
- **Purpose**: Query metrics, view raw data, set up alerts

### Key Features
1. **Query Interface**: Use PromQL to query metrics
2. **Targets**: View which services are being scraped
3. **Graphs**: Visualize time-series data
4. **Alerts**: Set up alerting rules

### Useful Queries for Your Services

#### Collection Service Metrics
```promql
# Total kline events received
binance_data_collection_kline_events_received_total

# WebSocket connections
binance_data_collection_active_websocket_connections

# Kafka send rate
rate(binance_data_collection_kline_events_sent_kafka_total[5m])

# Processing time
histogram_quantile(0.95, binance_data_collection_kline_event_processing_duration_seconds_bucket)
```

#### Storage Service Metrics
```promql
# Database operations
binance_data_storage_postgres_saves_total
binance_data_storage_elasticsearch_saves_total

# Connection status
binance_data_storage_postgres_connection_status
binance_data_storage_elasticsearch_connection_status

# Error rates
rate(binance_data_storage_kline_events_failed_total[5m])
```

#### System Metrics
```promql
# HTTP request rate
rate(http_server_requests_seconds_count[5m])

# JVM memory usage
jvm_memory_used_bytes

# Application startup time
application_started_time_seconds
```

## 🎨 Grafana (Beautiful Dashboards)

### Access
- **URL**: http://localhost:3001
- **Username**: `admin`
- **Password**: `testnet_admin`

### Pre-configured Dashboards
Your project already includes several dashboards:

1. **System Health Dashboards**
   - Health overview
   - Infrastructure monitoring
   - System performance

2. **Trading Dashboards**
   - MACD strategy monitoring
   - Trading operations
   - Order tracking

3. **Kline Data Dashboards**
   - Data collection overview
   - Storage monitoring
   - Streaming metrics

### Creating Custom Dashboards

#### Step 1: Create New Dashboard
1. Go to Grafana → "+" → Dashboard
2. Click "Add visualization"
3. Select "Prometheus" as data source

#### Step 2: Add Panels for Your Services

**Collection Service Panel Example:**
- **Query**: `binance_data_collection_kline_events_received_total`
- **Visualization**: Time series
- **Title**: "Kline Events Received"

**Storage Service Panel Example:**
- **Query**: `binance_data_storage_postgres_connection_status`
- **Visualization**: Stat
- **Title**: "PostgreSQL Connection Status"

#### Step 3: Useful Panel Types
- **Time Series**: For metrics over time
- **Stat**: For current values
- **Gauge**: For status indicators
- **Table**: For detailed data
- **Heatmap**: For distribution data

## 🔍 Direct Metrics Access

### Collection Service
- **Health**: http://localhost:8086/actuator/health
- **Metrics**: http://localhost:8086/actuator/metrics
- **Prometheus**: http://localhost:8086/actuator/prometheus

### Storage Service
- **Health**: http://localhost:8087/actuator/health
- **Metrics**: http://localhost:8087/actuator/metrics
- **Prometheus**: http://localhost:8087/actuator/prometheus

## 📊 Available Metrics

### Collection Service Metrics
- `binance_data_collection_kline_events_received_total`
- `binance_data_collection_kline_events_sent_kafka_total`
- `binance_data_collection_websocket_connections_established_total`
- `binance_data_collection_active_websocket_connections`
- `binance_data_collection_kline_event_processing_duration_seconds`

### Storage Service Metrics
- `binance_data_storage_kline_events_received_total`
- `binance_data_storage_kline_events_saved_total`
- `binance_data_storage_postgres_saves_total`
- `binance_data_storage_elasticsearch_saves_total`
- `binance_data_storage_postgres_connection_status`
- `binance_data_storage_elasticsearch_connection_status`

### System Metrics
- `http_server_requests_seconds_count`
- `jvm_memory_used_bytes`
- `application_started_time_seconds`
- `application_ready_time_seconds`

## 🚨 Setting Up Alerts

### In Prometheus
1. Go to Prometheus → Alerts
2. Create alert rules for:
   - Service down
   - High error rates
   - Connection failures
   - Memory usage

### In Grafana
1. Go to Alerting → Alert Rules
2. Create notification channels
3. Set up dashboard alerts

## 🛠️ Troubleshooting

### Services Not Appearing in Prometheus
1. Check if services are running: `docker ps`
2. Check Prometheus targets: http://localhost:9091/targets
3. Verify service health endpoints

### Grafana Not Loading Dashboards
1. Check if Prometheus is running
2. Verify data source configuration
3. Check Grafana logs: `docker logs grafana-testnet`

### Metrics Not Updating
1. Check if services are processing data
2. Verify Prometheus scraping interval
3. Check for errors in service logs

## 📝 Next Steps

1. **Explore Existing Dashboards**: Check out the pre-configured dashboards
2. **Create Custom Dashboards**: Build dashboards specific to your needs
3. **Set Up Alerts**: Configure alerts for critical metrics
4. **Monitor in Real-time**: Use the tools to monitor your services

## 🔗 Quick Links

- **Prometheus**: http://localhost:9091
- **Grafana**: http://localhost:3001
- **Collection Health**: http://localhost:8086/actuator/health
- **Storage Health**: http://localhost:8087/actuator/health
- **Collection Metrics**: http://localhost:8086/actuator/prometheus
- **Storage Metrics**: http://localhost:8087/actuator/prometheus

---

**Happy Monitoring! 🎉**
