# 📊 Grafana Dashboard Setup Guide

## 🎯 **Your Complete Monitoring Solution**

You now have a fully functional monitoring stack! Here's how to set up your comprehensive dashboard.

## 🚀 **Quick Start**

### **1. Access Grafana**
- **URL**: http://localhost:3001
- **Username**: `admin`
- **Password**: `testnet_admin`

### **2. Access Prometheus**
- **URL**: http://localhost:9091

## 📈 **Available Metrics**

### **Storage Service Metrics** (Working ✅)
- `binance_data_storage_kline_events_received_total` - Total events received
- `binance_data_storage_kline_events_saved_total` - Total events saved
- `binance_data_storage_postgres_connection_status` - PostgreSQL connection status
- `binance_data_storage_elasticsearch_connection_status` - Elasticsearch connection status
- `binance_data_storage_postgres_saves_total` - PostgreSQL save operations
- `binance_data_storage_elasticsearch_saves_total` - Elasticsearch save operations
- `binance_data_storage_kline_events_failed_total` - Failed events
- `binance_data_storage_kafka_consumer_errors_total` - Kafka consumer errors

### **Collection Service Metrics** (System metrics available)
- `kafka_producer_topic_record_send_total` - Kafka records sent
- `jvm_memory_used_bytes` - JVM memory usage
- `system_cpu_usage` - CPU usage
- `http_server_requests_seconds_count` - HTTP requests

## 🎨 **Creating Your Dashboard**

### **Step 1: Create New Dashboard**
1. Go to Grafana → **"+"** → **"Dashboard"**
2. Click **"Add visualization"**
3. Select **"Prometheus Testnet"** as data source

### **Step 2: Add Panels**

#### **Panel 1: Data Processing Counters**
- **Query**: `binance_data_storage_kline_events_received_total`
- **Legend**: "Events Received"
- **Visualization**: Time series
- **Title**: "Data Processing Counters"

Add second query:
- **Query**: `binance_data_storage_kline_events_saved_total`
- **Legend**: "Events Saved"

#### **Panel 2: Database Connection Status**
- **Query**: `binance_data_storage_postgres_connection_status`
- **Legend**: "PostgreSQL"
- **Visualization**: Stat
- **Title**: "Database Connections"

Add second query:
- **Query**: `binance_data_storage_elasticsearch_connection_status`
- **Legend**: "Elasticsearch"

#### **Panel 3: Processing Rate**
- **Query**: `rate(binance_data_storage_kline_events_received_total[5m])`
- **Legend**: "Events/sec"
- **Visualization**: Time series
- **Title**: "Processing Rate"

#### **Panel 4: Database Operations**
- **Query**: `binance_data_storage_postgres_saves_total`
- **Legend**: "PostgreSQL Saves"
- **Visualization**: Time series
- **Title**: "Database Operations"

Add second query:
- **Query**: `binance_data_storage_elasticsearch_saves_total`
- **Legend**: "Elasticsearch Saves"

#### **Panel 5: Error Monitoring**
- **Query**: `binance_data_storage_kline_events_failed_total`
- **Legend**: "Failed Events"
- **Visualization**: Time series
- **Title**: "Error Monitoring"

Add second query:
- **Query**: `binance_data_storage_kafka_consumer_errors_total`
- **Legend**: "Kafka Errors"

#### **Panel 6: JVM Memory Usage**
- **Query**: `jvm_memory_used_bytes{application="binance-data-storage"}`
- **Legend**: "Storage Service Memory"
- **Visualization**: Time series
- **Title**: "Memory Usage"

Add second query:
- **Query**: `jvm_memory_used_bytes{application="binance-data-collection"}`
- **Legend**: "Collection Service Memory"

#### **Panel 7: CPU Usage**
- **Query**: `system_cpu_usage{application="binance-data-storage"} * 100`
- **Legend**: "Storage Service CPU"
- **Visualization**: Time series
- **Title**: "CPU Usage"

Add second query:
- **Query**: `system_cpu_usage{application="binance-data-collection"} * 100`
- **Legend**: "Collection Service CPU"

#### **Panel 8: Kafka Operations**
- **Query**: `kafka_producer_topic_record_send_total{application="binance-data-collection",topic="binance-kline"}`
- **Legend**: "Kafka Records Sent"
- **Visualization**: Time series
- **Title**: "Kafka Operations"

## 🔍 **Useful Prometheus Queries**

### **Data Processing**
```promql
# Total events processed
binance_data_storage_kline_events_received_total

# Events per second
rate(binance_data_storage_kline_events_received_total[5m])

# Success rate
binance_data_storage_kline_events_saved_total / binance_data_storage_kline_events_received_total * 100
```

### **Performance Monitoring**
```promql
# 95th percentile processing time
histogram_quantile(0.95, binance_data_storage_kline_event_processing_duration_seconds_bucket)

# Average processing time
binance_data_storage_kline_event_processing_duration_seconds_sum / binance_data_storage_kline_event_processing_duration_seconds_count
```

### **System Health**
```promql
# Memory usage percentage
jvm_memory_used_bytes / jvm_memory_max_bytes * 100

# CPU usage
system_cpu_usage * 100

# HTTP request rate
rate(http_server_requests_seconds_count[5m])
```

## 🎯 **Key Indicators to Monitor**

### **Critical Metrics**
1. **Data Flow**: Events received vs saved
2. **Database Health**: Connection status
3. **Error Rate**: Failed events
4. **Performance**: Processing latency
5. **System Health**: Memory and CPU usage

### **Alerting Thresholds**
- **Error Rate**: > 1% failed events
- **Memory Usage**: > 80% of max
- **CPU Usage**: > 70%
- **Database Connection**: < 1 (disconnected)

## 🚨 **Troubleshooting**

### **If you see "No data":**
1. Check if services are running: `docker ps`
2. Verify Prometheus targets: http://localhost:9091/targets
3. Check service health: http://localhost:8086/actuator/health
4. The services need to be actively processing data to show metrics

### **If metrics are missing:**
1. The custom metrics are only generated when services process real data
2. System metrics (JVM, CPU, HTTP) should always be available
3. Check service logs: `docker logs binance-data-storage-testnet`

## 📊 **Dashboard Layout Suggestions**

### **Row 1**: Data Processing Overview
- Data Processing Counters
- Processing Rate

### **Row 2**: Database Health
- Database Connection Status
- Database Operations

### **Row 3**: System Health
- Memory Usage
- CPU Usage

### **Row 4**: Error Monitoring
- Error Monitoring
- Kafka Operations

## 🎉 **You're All Set!**

Your monitoring stack is ready! You now have:
- ✅ Prometheus collecting metrics
- ✅ Grafana for visualization
- ✅ Comprehensive metrics from both services
- ✅ Real-time monitoring capabilities

**Next Steps:**
1. Create your dashboard using the queries above
2. Set up alerts for critical metrics
3. Monitor your services in real-time
4. Customize the dashboard to your needs

**Happy Monitoring! 🚀**
