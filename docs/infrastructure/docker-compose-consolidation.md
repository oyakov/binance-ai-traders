# Docker Compose Files and Deployment Scripts Consolidation

## Overview

This document consolidates, normalizes, and documents all Docker Compose files and deployment scripts in the Binance AI Traders project. It provides a comprehensive reference for infrastructure management and deployment procedures.

## Docker Compose Files

### 1. Main Production Compose (`docker-compose.yml`)

**Purpose**: Core production infrastructure with all services
**Version**: 3.8
**Services**: 6 services + infrastructure

#### Services:
- `binance-data-collection`: Data collection service
- `postgres`: PostgreSQL database (port 5432)
- `elasticsearch`: Elasticsearch for data storage (port 9200)
- `kafka`: Apache Kafka with KRaft mode (port 9092)
- `schema-registry`: Confluent Schema Registry (port 8081)

#### Key Features:
- Uses Apache Kafka 3.8.0 with KRaft mode (no Zookeeper)
- PostgreSQL with persistent volume
- Elasticsearch 8.5.0 with security disabled
- Single network: `binance-network`

### 2. Testnet Compose (`docker-compose-testnet.yml`)

**Purpose**: Complete testnet environment with monitoring
**Version**: 3.8
**Services**: 8 services + infrastructure

#### Services:
- `binance-trader-macd-testnet`: Main trading service (port 8083)
- `postgres-testnet`: PostgreSQL for testnet (port 5433)
- `elasticsearch-testnet`: Elasticsearch for testnet (port 9202)
- `kafka-testnet`: Kafka with Zookeeper (port 9095)
- `zookeeper-testnet`: Zookeeper for Kafka (port 2182)
- `schema-registry-testnet`: Schema Registry (port 8082)
- `prometheus-testnet`: Monitoring (port 9091)
- `grafana-testnet`: Dashboards (port 3001)

#### Key Features:
- Complete monitoring stack
- Separate network: `testnet-network`
- Health checks for all services
- Environment file support (`testnet.env`)

### 3. Test Compose (`docker-compose.test.yml`)

**Purpose**: Integration testing environment
**Version**: 3.8
**Services**: 8 services + infrastructure

#### Services:
- `zookeeper`: Zookeeper for Kafka
- `kafka`: Kafka with Zookeeper (port 9092)
- `postgres`: PostgreSQL for testing (port 5432)
- `elasticsearch`: Elasticsearch for testing (port 9200)
- `binance-data-collection`: Data collection (port 8081)
- `binance-data-storage`: Data storage (port 8082)
- `binance-trader-macd`: MACD trader (port 8083)
- `telegram-frontend`: Python frontend (port 8084)
- `prometheus`: Monitoring (port 9090)
- `grafana`: Dashboards (port 3000)

#### Key Features:
- Complete application stack
- Health checks with dependencies
- Test-specific configurations
- Network: `binance-test-network`

### 4. Kafka KRaft Compose (`docker-compose-kafka-kraft.yml`)

**Purpose**: Standalone Kafka with KRaft mode
**Version**: 3.7
**Services**: 1 service

#### Services:
- `kafka`: Apache Kafka with KRaft mode (port 9092)

#### Key Features:
- No Zookeeper dependency
- Single broker setup
- Auto topic creation enabled

### 5. Monitoring Compose (`monitoring/docker-compose.grafana-testnet.yml`)

**Purpose**: Standalone monitoring stack
**Version**: 3.8
**Services**: 2 services

#### Services:
- `prometheus`: Metrics collection (port 9090)
- `grafana`: Visualization (port 3000)

#### Key Features:
- Isolated monitoring environment
- Network: `grafana-monitoring`
- Persistent Grafana storage

## Deployment Scripts

### PowerShell Scripts

#### 1. Health Monitor (`docs/scripts/health-monitor.ps1`)

**Purpose**: Monitor service health and create metrics
**Parameters**:
- `IntervalSeconds`: Monitoring interval (default: 30)
- `MaxIterations`: Max iterations (0 = infinite)

**Features**:
- HTTP health checks
- Port connectivity fallback
- Color-coded output
- Service status summary

#### 2. Testnet Monitor (`docs/scripts/monitor_testnet.ps1`)

**Purpose**: Comprehensive testnet monitoring
**Parameters**:
- `IntervalSeconds`: Monitoring interval (default: 30)
- `MaxIterations`: Max iterations (0 = infinite)

**Features**:
- Docker container status monitoring
- Log analysis with error detection
- Detailed service summaries
- Critical issue detection

#### 3. API Key Testing (`docs/scripts/test-api-keys.ps1`)

**Purpose**: Comprehensive API key validation
**Parameters**:
- `Verbose`: Verbose output
- `SkipUnitTests`: Skip unit tests
- `SkipIntegrationTests`: Skip integration tests
- `SkipComprehensiveTests`: Skip comprehensive tests
- `SkipConnectivityTests`: Skip connectivity tests

**Features**:
- Multiple test types
- API key format validation
- Negative testing
- Performance and security tests

#### 4. Strategy Launcher (`docs/scripts/launch_strategies.ps1`)

**Purpose**: Launch multiple trading strategies
**Parameters**:
- `LaunchAll`: Launch all strategies
- `LaunchBTC`: Launch BTC strategy
- `LaunchETH`: Launch ETH strategy
- `LaunchADA`: Launch ADA strategy
- `LaunchSOL`: Launch SOL strategy
- `StrategyType`: Strategy type (default: MACD)

**Features**:
- Multiple strategy configurations
- Risk level management
- Service readiness checks
- Strategy monitoring URLs

#### 5. Trading Functionality Test (`docs/scripts/test-trading-functionality.ps1`)

**Purpose**: Test trading functionality
**Features**:
- Service health validation
- API endpoint testing
- Trading operation validation

#### 6. Long-term Testnet Monitor (`docs/scripts/testnet_long_term_monitor.ps1`)

**Purpose**: Long-term testnet monitoring
**Features**:
- Extended monitoring periods
- Performance tracking
- Alert generation

### Bash Scripts

#### 1. Deploy Testnet (`docs/scripts/deploy-testnet.sh`)

**Purpose**: Deploy testnet environment
**Features**:
- Environment validation
- Application building
- Service health checks
- Service URL documentation

#### 2. Docker Test (`docs/scripts/docker-test.sh`)

**Purpose**: Enhanced Docker testing
**Features**:
- Image building and testing
- Resource usage monitoring
- Service connectivity testing
- Docker Compose orchestration testing

#### 3. Enhanced Tests (`docs/scripts/run-enhanced-tests.sh`)

**Purpose**: Run enhanced test suite
**Features**:
- Comprehensive testing
- Test result analysis
- Performance validation

#### 4. Performance Test (`docs/scripts/performance-test.sh`)

**Purpose**: Performance testing
**Features**:
- Load testing
- Performance metrics
- Resource utilization

#### 5. Health Check Test (`docs/scripts/health-check-test.sh`)

**Purpose**: Health check testing
**Features**:
- Service health validation
- Endpoint testing
- Status reporting

## Normalization Recommendations

### 1. Docker Compose Standardization

#### Version Consistency
- **Current**: Mixed versions (3.7, 3.8)
- **Recommendation**: Standardize on 3.8 for all files

#### Service Naming
- **Current**: Inconsistent naming patterns
- **Recommendation**: Use consistent naming: `{service-name}-{environment}`

#### Port Management
- **Current**: Port conflicts and inconsistent mapping
- **Recommendation**: 
  - Production: 8080-8099
  - Testnet: 8100-8199
  - Test: 8200-8299
  - Monitoring: 9000-9099

#### Network Management
- **Current**: Multiple networks with different names
- **Recommendation**: Standardize network names:
  - `binance-production`
  - `binance-testnet`
  - `binance-test`
  - `binance-monitoring`

### 2. Environment Variable Standardization

#### Common Variables
```yaml
# Database
POSTGRES_DB: binance
POSTGRES_USER: binance_user
POSTGRES_PASSWORD: binance_password

# Kafka
KAFKA_BOOTSTRAP_SERVERS: kafka:9092
KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1

# Elasticsearch
ES_JAVA_OPTS: -Xms512m -Xmx512m
xpack.security.enabled: false

# Monitoring
PROMETHEUS_PORT: 9090
GRAFANA_PORT: 3000
```

### 3. Health Check Standardization

#### Standard Health Check Pattern
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### 4. Volume Management

#### Standard Volume Pattern
```yaml
volumes:
  {service-name}_data:
    driver: local
```

## Deployment Workflows

### 1. Production Deployment
```bash
# 1. Build and start infrastructure
docker-compose up -d postgres elasticsearch kafka schema-registry

# 2. Wait for infrastructure
sleep 30

# 3. Start application services
docker-compose up -d binance-data-collection

# 4. Verify deployment
./docs/scripts/health-monitor.ps1
```

### 2. Testnet Deployment
```bash
# 1. Set environment variables
export TESTNET_API_KEY=your_key
export TESTNET_SECRET_KEY=your_secret

# 2. Deploy testnet
./docs/scripts/deploy-testnet.sh

# 3. Monitor testnet
./docs/scripts/monitor_testnet.ps1
```

### 3. Testing Deployment
```bash
# 1. Run tests
./docs/scripts/docker-test.sh

# 2. Run enhanced tests
./docs/scripts/run-enhanced-tests.sh

# 3. Performance testing
./docs/scripts/performance-test.sh
```

## Monitoring and Observability

### 1. Service URLs

#### Production
- Data Collection: http://localhost:8080
- PostgreSQL: localhost:5432
- Elasticsearch: http://localhost:9200
- Kafka: localhost:9092
- Schema Registry: http://localhost:8081

#### Testnet
- Trading Service: http://localhost:8083
- PostgreSQL: localhost:5433
- Elasticsearch: http://localhost:9202
- Kafka: localhost:9095
- Prometheus: http://localhost:9091
- Grafana: http://localhost:3001

#### Test
- Data Collection: http://localhost:8081
- Data Storage: http://localhost:8082
- MACD Trader: http://localhost:8083
- Telegram Frontend: http://localhost:8084
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000

### 2. Health Check Endpoints

All services expose health checks at:
- Spring Boot: `/actuator/health`
- Python: `/health`
- Database: `pg_isready`
- Kafka: `kafka-broker-api-versions`

### 3. Monitoring Scripts

- **Health Monitor**: Continuous health monitoring
- **Testnet Monitor**: Comprehensive testnet monitoring
- **API Key Testing**: API key validation
- **Strategy Launcher**: Strategy management
- **Docker Test**: Container testing

## Security Considerations

### 1. Environment Variables
- Use `.env` files for sensitive data
- Never commit API keys to version control
- Use Docker secrets for production

### 2. Network Security
- Use isolated networks
- Implement proper firewall rules
- Use TLS for production communication

### 3. Container Security
- Use specific image tags
- Regular security updates
- Minimal base images

## Troubleshooting

### 1. Common Issues

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :8080

# Kill process using port
sudo kill -9 $(lsof -t -i:8080)
```

#### Service Dependencies
```bash
# Check service status
docker-compose ps

# Check service logs
docker-compose logs service-name

# Restart service
docker-compose restart service-name
```

#### Database Issues
```bash
# Check database connectivity
docker-compose exec postgres pg_isready -U binance_user -d binance

# Reset database
docker-compose down -v
docker-compose up -d
```

### 2. Debugging Commands

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f service-name

# Execute commands in container
docker-compose exec service-name bash

# Check container resources
docker stats

# Inspect container
docker inspect container-name
```

## Maintenance

### 1. Regular Tasks

#### Daily
- Check service health
- Monitor logs for errors
- Verify data collection

#### Weekly
- Update dependencies
- Review performance metrics
- Clean up old containers

#### Monthly
- Security updates
- Backup data
- Review configurations

### 2. Backup Procedures

#### Database Backup
```bash
# Backup PostgreSQL
docker-compose exec postgres pg_dump -U binance_user binance > backup.sql

# Restore PostgreSQL
docker-compose exec -T postgres psql -U binance_user binance < backup.sql
```

#### Volume Backup
```bash
# Backup volumes
docker run --rm -v binance_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .
```

## Future Improvements

### 1. Infrastructure as Code
- Use Terraform for infrastructure management
- Implement GitOps workflows
- Add automated testing

### 2. Monitoring Enhancements
- Implement distributed tracing
- Add custom metrics
- Set up alerting

### 3. Security Improvements
- Implement RBAC
- Add network policies
- Use service mesh

### 4. Performance Optimization
- Implement horizontal scaling
- Add load balancing
- Optimize resource usage

## Conclusion

This consolidation provides a comprehensive reference for managing Docker Compose files and deployment scripts in the Binance AI Traders project. The normalization recommendations will help standardize the infrastructure and improve maintainability.

For questions or issues, refer to the troubleshooting section or contact the development team.
