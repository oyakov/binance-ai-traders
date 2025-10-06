# Postman Testing Collections for Binance AI Traders

This directory contains comprehensive Postman collections and environments for testing the Binance AI Traders system.

## Files Overview

### Environment Files
- **`Binance-AI-Traders-Testnet-Environment.json`** - Environment configuration for testnet testing with all necessary variables and credentials

### Test Collections
- **`Binance-AI-Traders-Comprehensive-Test-Collection.json`** - Complete system testing covering all components
- **`Binance-AI-Traders-Monitoring-Tests.json`** - Specialized monitoring and metrics validation tests

## Quick Start

### 1. Setup Testing Environment
```powershell
# Install Newman and required dependencies
.\scripts\setup-testing-environment.ps1

# Or manually install Newman
npm install -g newman newman-reporter-html
```

### 2. Start the System
```powershell
# Start testnet environment
docker-compose -f docker-compose-testnet.yml up -d

# Wait for services to be ready
Start-Sleep -Seconds 60
```

### 3. Run Tests
```powershell
# Run all tests
.\scripts\run-comprehensive-tests.ps1

# Run specific test categories
.\scripts\run-comprehensive-tests.ps1 -SkipMonitoring
.\scripts\run-comprehensive-tests.ps1 -SkipHealthCheck

# Run continuous monitoring
.\scripts\run-comprehensive-tests.ps1 -Continuous -IntervalMinutes 5
```

## Test Collections Details

### Comprehensive Test Collection
**File**: `Binance-AI-Traders-Comprehensive-Test-Collection.json`

**Test Categories**:
1. **System Health Checks** (7 tests)
   - Trading Service Health
   - Data Collection Service Health
   - PostgreSQL Health
   - Elasticsearch Health
   - Kafka Health
   - Prometheus Health
   - Grafana Health

2. **Binance API Integration** (4 tests)
   - Binance Testnet Ping
   - Binance Testnet Server Time
   - Binance Testnet Account Info
   - Binance Testnet Kline Data

3. **Service Metrics and Monitoring** (5 tests)
   - Trading Service Metrics
   - Data Collection Service Metrics
   - Prometheus Targets Status
   - Prometheus Query - System Metrics
   - Grafana Data Source Test

4. **Data Flow and Integration** (3 tests)
   - Kafka Topics Check
   - Elasticsearch Index Check
   - PostgreSQL Database Check

5. **Performance and Load Tests** (3 tests)
   - Trading Service Load Test
   - Memory Usage Check
   - HTTP Request Metrics

6. **End-to-End Trading Flow** (2 tests)
   - Trading Service Info
   - Trading Service Configuration

### Monitoring Tests Collection
**File**: `Binance-AI-Traders-Monitoring-Tests.json`

**Test Categories**:
1. **Prometheus Metrics Validation** (4 tests)
   - Check All Service Targets
   - Query System Uptime Metrics
   - Query JVM Memory Metrics
   - Query HTTP Request Metrics

2. **Grafana Dashboard Validation** (4 tests)
   - Check Grafana API Health
   - Validate Data Sources
   - Test Data Source Connectivity
   - List Available Dashboards

3. **Custom Metrics Validation** (2 tests)
   - Check Trading Service Custom Metrics
   - Validate Metrics Format

4. **System Performance Monitoring** (3 tests)
   - Check System Resource Usage
   - Check CPU Usage
   - Check Response Times

## Environment Variables

The testnet environment includes the following key variables:

### Service Ports
- `trading_service_port`: 8083
- `data_collection_port`: 8086
- `postgres_port`: 5433
- `elasticsearch_port`: 9202
- `kafka_port`: 9095
- `prometheus_port`: 9091
- `grafana_port`: 3001

### API Configuration
- `testnet_url`: https://testnet.binance.vision
- `api_key`: Testnet API key
- `api_secret`: Testnet API secret

### Test Configuration
- `test_symbol`: BTCUSDT
- `test_interval`: 1m
- `test_limit`: 100
- `test_timeout`: 30000ms

## Running Individual Tests

### Using Newman CLI
```bash
# Run comprehensive tests
newman run Binance-AI-Traders-Comprehensive-Test-Collection.json \
  -e Binance-AI-Traders-Testnet-Environment.json \
  --reporters cli,html \
  --reporter-html-export comprehensive-report.html

# Run monitoring tests only
newman run Binance-AI-Traders-Monitoring-Tests.json \
  -e Binance-AI-Traders-Testnet-Environment.json \
  --reporters cli,html \
  --reporter-html-export monitoring-report.html

# Run specific folder
newman run Binance-AI-Traders-Comprehensive-Test-Collection.json \
  -e Binance-AI-Traders-Testnet-Environment.json \
  --folder "1. System Health Checks" \
  --reporters cli,html \
  --reporter-html-export health-check-report.html
```

### Using Postman GUI
1. Import the environment file into Postman
2. Import the collection files into Postman
3. Select the testnet environment
4. Run the desired collection or individual requests

## Test Assertions

### Health Check Assertions
- HTTP status codes (200 OK)
- Response times (< 30 seconds)
- Service status ("UP")
- Database connectivity
- Message queue availability

### API Integration Assertions
- Binance testnet connectivity
- Authentication validation
- Data structure validation
- Response format validation

### Metrics Validation Assertions
- Prometheus targets status
- Custom metrics presence
- JVM metrics availability
- HTTP metrics collection

### Monitoring System Assertions
- Grafana API health
- Data source configuration
- Dashboard availability
- Query execution success

## Troubleshooting

### Common Issues

1. **Services not responding**
   - Check Docker container status: `docker-compose -f docker-compose-testnet.yml ps`
   - View service logs: `docker-compose -f docker-compose-testnet.yml logs [service-name]`

2. **Newman not found**
   - Install Newman: `npm install -g newman`
   - Verify installation: `newman --version`

3. **Test failures**
   - Check service health manually
   - Verify environment variables
   - Review test reports for detailed error information

4. **Grafana showing "No data"**
   - Verify Prometheus targets are up
   - Check data source configuration
   - Validate Prometheus query responses

### Debug Mode
Run tests with verbose output:
```bash
newman run [collection] -e [environment] --verbose
```

## Continuous Integration

### GitHub Actions Example
```yaml
name: System Testing
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      - name: Install Newman
        run: npm install -g newman
      - name: Start Services
        run: docker-compose -f docker-compose-testnet.yml up -d
      - name: Wait for Services
        run: sleep 60
      - name: Run Tests
        run: |
          newman run postman/Binance-AI-Traders-Comprehensive-Test-Collection.json \
            -e postman/Binance-AI-Traders-Testnet-Environment.json \
            --reporters cli,html \
            --reporter-html-export test-report.html
```

## Report Generation

Test reports are generated in HTML format and include:
- Test execution summary
- Individual test results
- Assertion details
- Performance metrics
- Error analysis

Reports are saved in the `test-reports` directory with timestamps.

## Maintenance

### Regular Updates
- Update test data and scenarios weekly
- Review and update assertions monthly
- Optimize test performance quarterly

### Adding New Tests
1. Create new requests in Postman
2. Add appropriate assertions
3. Update collection documentation
4. Test with Newman CLI
5. Commit to version control

## Support

For issues with the testing setup:
1. Check the troubleshooting section
2. Review test reports for error details
3. Verify system service health
4. Check Newman and Postman documentation
