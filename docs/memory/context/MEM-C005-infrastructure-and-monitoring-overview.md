# MEM-C005: Infrastructure and Monitoring Overview

**Type**: Context  
**Status**: Active  
**Created**: 2025-01-08  
**Last Updated**: 2025-01-08  
**Scope**: Infrastructure  

## Infrastructure Architecture

### Container Orchestration

#### Docker Compose Files
- **`docker-compose.yml`**: Main development stack
- **`docker-compose-testnet.yml`**: Testnet environment configuration
- **`docker-compose.override.yml`**: Local development overrides
- **`docker-compose.test.yml`**: Testing environment

#### Core Infrastructure Services
```yaml
services:
  kafka:                    # Apache Kafka 3.8.0 (KRaft mode)
  schema-registry:          # Confluent Schema Registry 7.5.1
  postgres:                 # PostgreSQL latest
  elasticsearch:            # Elasticsearch 8.5.0
  prometheus:               # Prometheus metrics collection
  grafana:                  # Grafana visualization
```

### Message Streaming Infrastructure

#### Apache Kafka
- **Version**: 3.8.0 with KRaft mode (no ZooKeeper)
- **Configuration**: Single-node setup for development
- **Topics**: 
  - `kline-events`: Market data events
  - `trading-signals`: Trading strategy signals
  - `system-health`: Health and status messages

#### Schema Registry
- **Version**: Confluent Schema Registry 7.5.1
- **Purpose**: Avro schema management and evolution
- **Compatibility**: NONE (development mode)
- **Integration**: All services use schema registry for serialization

### Data Storage Infrastructure

#### PostgreSQL
- **Version**: Latest (latest tag)
- **Purpose**: Relational data storage for structured data
- **Configuration**:
  - Database: `binance`
  - User: `postgres`
  - Password: `postgres`
  - Port: `5432`

#### Elasticsearch
- **Version**: 8.5.0
- **Purpose**: Time-series data, search, and analytics
- **Configuration**:
  - Single-node setup
  - Security disabled (development)
  - Ports: `9200` (HTTP), `9300` (transport)

### Monitoring and Observability

#### Prometheus
- **Purpose**: Metrics collection and alerting
- **Configuration**: `monitoring/prometheus.yml`
- **Scrape Targets**:
  - All Spring Boot services (via Actuator)
  - Infrastructure services (Kafka, PostgreSQL, Elasticsearch)
  - Custom health metrics server

#### Grafana
- **Purpose**: Visualization and dashboards
- **Configuration**: Pre-configured dashboards in `monitoring/grafana/`
- **Authentication**: admin/testnet_admin
- **Port**: 3001

#### Metrics Collection
```yaml
# Service Metrics (via Actuator)
- binance-data-collection:8080/actuator/prometheus
- binance-data-storage:8080/actuator/prometheus
- binance-trader-macd:8080/actuator/prometheus

# Infrastructure Metrics
- kafka:9092 (JMX metrics)
- postgres:5432 (custom metrics)
- elasticsearch:9200 (built-in metrics)
```

## Monitoring Dashboards

### System Health Dashboards
1. **System Health Overview** (`01-system-health/`)
   - Service status and health checks
   - Infrastructure component status
   - Resource utilization metrics

2. **Infrastructure Health** (`system-monitoring/`)
   - Kafka cluster health
   - Database connection status
   - Elasticsearch cluster status

### Trading Dashboards
1. **Trading Operations Overview** (`02-trading-overview/`)
   - Trading strategy performance
   - Order execution metrics
   - P&L tracking

2. **MACD Strategies** (`03-macd-strategies/`)
   - MACD indicator calculations
   - Signal generation metrics
   - Strategy performance analysis

### Data Monitoring Dashboards
1. **Kline Data Monitoring** (`04-kline-data/`)
   - Data collection rates
   - Storage performance
   - Data quality metrics

2. **Analytics Insights** (`05-analytics/`)
   - Market data analysis
   - Trading pattern recognition
   - Performance optimization insights

### Executive Dashboards
1. **Executive Overview** (`06-executive/`)
   - High-level system status
   - Key performance indicators
   - Business metrics

## Service Configuration

### Environment Variables
```bash
# Data Collection Service
SPRING_KAFKA_BOOTSTRAP_SERVERS=kafka:9092
SPRING_KAFKA_PROPERTIES_SCHEMA_REGISTRY_URL=http://schema-registry:8081

# Data Storage Service
SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/binance
SPRING_ELASTICSEARCH_URIS=http://elasticsearch:9200

# MACD Trader Service
BINANCE_API_KEY=${BINANCE_API_KEY}
BINANCE_API_SECRET=${BINANCE_API_SECRET}
BINANCE_REST_BASE_URL=${BINANCE_REST_BASE_URL}
```

### Port Configuration
```yaml
# Service Ports
binance-data-collection: 8080
binance-data-storage: 8081
binance-trader-macd: 8082
binance-trader-grid: 8083

# Infrastructure Ports
postgres: 5432
elasticsearch: 9200, 9300
kafka: 9092, 9093
schema-registry: 8081
prometheus: 9091
grafana: 3001
```

## Deployment Scripts and Automation

### PowerShell Scripts (74 scripts)
- **Build Scripts**: `build-data-collection-fast.ps1`
- **Test Scripts**: `test-*.ps1` (comprehensive testing suite)
- **Monitoring Scripts**: `check-metrics.ps1`, `verify-metrics-*.ps1`
- **Dashboard Scripts**: `setup-*-dashboard.ps1`

### Key Automation Scripts
```powershell
# Quick Start
.\quick-rebuild.bat
.\quick-test.ps1

# Monitoring
.\open-monitoring.ps1
.\check-metrics.ps1

# Dashboard Setup
.\setup-comprehensive-dashboard.ps1
.\setup-dashboard-simple.ps1
```

### Docker Build Optimization
- **Multi-stage Builds**: Optimized Dockerfile configurations
- **Layer Caching**: Efficient build caching strategies
- **Image Size Optimization**: Minimal base images and dependencies

## Network Configuration

### Docker Networks
```yaml
networks:
  binance-network:
    driver: bridge
    # All services communicate within this network
```

### Service Communication
- **Internal Communication**: Services use container names for DNS resolution
- **External Access**: Port mapping for development access
- **Security**: No external exposure in production mode

## Health Checks and Monitoring

### Service Health Endpoints
```bash
# Spring Boot Actuator Health Checks
http://localhost:8080/actuator/health  # Data Collection
http://localhost:8081/actuator/health  # Data Storage
http://localhost:8082/actuator/health  # MACD Trader
http://localhost:8083/actuator/health  # Grid Trader
```

### Custom Health Metrics
- **Database Connections**: PostgreSQL and Elasticsearch connection status
- **Kafka Connectivity**: Producer/consumer health
- **Binance API**: API connectivity and rate limits
- **WebSocket Connections**: Real-time connection status

### Alerting Configuration
```yaml
# Prometheus Alert Rules
- Service down alerts
- High error rate alerts
- Database connection failures
- Memory usage thresholds
- Disk space alerts
```

## Performance Monitoring

### Key Metrics
```promql
# Service Performance
rate(http_server_requests_seconds_count[5m])
jvm_memory_used_bytes
application_started_time_seconds

# Data Collection
binance_data_collection_kline_events_received_total
binance_data_collection_active_websocket_connections

# Data Storage
binance_data_storage_postgres_saves_total
binance_data_storage_elasticsearch_saves_total

# Trading
binance_trader_macd_signals_generated_total
binance_trader_macd_orders_placed_total
```

### Performance Optimization
- **Connection Pooling**: HikariCP for PostgreSQL
- **Kafka Batching**: Optimized batch sizes for throughput
- **Elasticsearch Indexing**: Optimized indexing strategies
- **JVM Tuning**: Memory and GC optimization

## Security Configuration

### API Key Management
```bash
# Environment Variables for API Keys
BINANCE_API_KEY=your_api_key
BINANCE_API_SECRET=your_api_secret
BINANCE_REST_BASE_URL=https://testnet.binance.vision  # Testnet
```

### Network Security
- **Internal Networks**: Services communicate within Docker network
- **Port Exposure**: Only necessary ports exposed for development
- **SSL/TLS**: Not configured (development environment)

### Data Security
- **Database Credentials**: Environment variable configuration
- **API Keys**: Secure environment variable storage
- **Logging**: No sensitive data in logs

## Backup and Recovery

### Data Persistence
```yaml
volumes:
  postgres-data:    # PostgreSQL data persistence
  es-data:          # Elasticsearch data persistence
  kafka-data:       # Kafka data persistence
```

### Backup Strategies
- **Database Backups**: PostgreSQL dump scripts
- **Configuration Backups**: Docker Compose and configuration files
- **Dashboard Backups**: Grafana dashboard exports

## Troubleshooting and Maintenance

### Common Issues
1. **Service Startup Failures**: Check dependencies and configuration
2. **Database Connection Issues**: Verify PostgreSQL/Elasticsearch status
3. **Kafka Connectivity**: Check broker status and topic creation
4. **Metrics Collection**: Verify Prometheus targets and scraping

### Maintenance Tasks
- **Log Rotation**: Configure log rotation for long-running services
- **Database Maintenance**: Regular PostgreSQL and Elasticsearch maintenance
- **Kafka Cleanup**: Topic retention and cleanup policies
- **Monitoring Updates**: Dashboard and alert rule updates

## Scaling Considerations

### Horizontal Scaling
- **Kafka**: Multiple broker configuration
- **Elasticsearch**: Cluster setup for production
- **PostgreSQL**: Read replicas and connection pooling
- **Services**: Multiple instances with load balancing

### Vertical Scaling
- **Memory**: JVM heap size optimization
- **CPU**: Multi-core utilization
- **Storage**: SSD optimization for databases
- **Network**: Bandwidth optimization for data streaming

---

**Related Memory Entries**: MEM-C003, MEM-C004, MEM-I001 through MEM-I005  
**Dependencies**: All infrastructure components, monitoring systems  
**Last Review**: 2025-01-08
