# Deployment Scripts Index

## Overview

This document provides a comprehensive index of all deployment scripts in the Binance AI Traders project, organized by type and purpose.

## Script Categories

### 1. Health Monitoring Scripts

#### PowerShell Scripts

| Script | Purpose | Parameters | Key Features |
|--------|---------|------------|--------------|
| `health-monitor.ps1` | Monitor service health and create metrics | `IntervalSeconds`, `MaxIterations` | HTTP health checks, port connectivity fallback, color-coded output |
| `monitor_testnet.ps1` | Comprehensive testnet monitoring | `IntervalSeconds`, `MaxIterations` | Docker container status, log analysis, error detection |
| `testnet_long_term_monitor.ps1` | Long-term testnet monitoring | N/A | Extended monitoring periods, performance tracking |

#### Bash Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `health-check-test.sh` | Health check testing | Service health validation, endpoint testing, status reporting |

### 2. Testing Scripts

#### PowerShell Scripts

| Script | Purpose | Parameters | Key Features |
|--------|---------|------------|--------------|
| `test-api-keys.ps1` | Comprehensive API key validation | `Verbose`, `SkipUnitTests`, `SkipIntegrationTests`, `SkipComprehensiveTests`, `SkipConnectivityTests` | Multiple test types, API key format validation, negative testing |
| `test-trading-functionality.ps1` | Test trading functionality | N/A | Service health validation, API endpoint testing, trading operation validation |

#### Bash Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `docker-test.sh` | Enhanced Docker testing | Image building and testing, resource usage monitoring, service connectivity testing |
| `run-enhanced-tests.sh` | Run enhanced test suite | Comprehensive testing, test result analysis, performance validation |
| `performance-test.sh` | Performance testing | Load testing, performance metrics, resource utilization |

### 3. Deployment Scripts

#### Bash Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `deploy-testnet.sh` | Deploy testnet environment | Environment validation, application building, service health checks |

### 4. Strategy Management Scripts

#### PowerShell Scripts

| Script | Purpose | Parameters | Key Features |
|--------|---------|------------|--------------|
| `launch_strategies.ps1` | Launch multiple trading strategies | `LaunchAll`, `LaunchBTC`, `LaunchETH`, `LaunchADA`, `LaunchSOL`, `StrategyType` | Multiple strategy configurations, risk level management, service readiness checks |
| `monitor_strategies.ps1` | Monitor trading strategies | N/A | Strategy performance monitoring, status tracking |

### 5. Utility Scripts

#### PowerShell Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `start-health-server.ps1` | Start health monitoring server | Health server startup, monitoring initialization |

#### Bash Scripts

| Script | Purpose | Key Features |
|--------|---------|--------------|
| `test-api-keys.sh` | API key testing (Bash version) | API key validation, connectivity testing |

## Script Usage Patterns

### 1. Health Monitoring Workflow

```bash
# Start health monitoring
./docs/scripts/health-monitor.ps1 -IntervalSeconds 30

# Monitor testnet specifically
./docs/scripts/monitor_testnet.ps1 -IntervalSeconds 60

# Long-term monitoring
./docs/scripts/testnet_long_term_monitor.ps1
```

### 2. Testing Workflow

```bash
# Test API keys
./docs/scripts/test-api-keys.ps1 -Verbose

# Test Docker setup
./docs/scripts/docker-test.sh

# Run comprehensive tests
./docs/scripts/run-enhanced-tests.sh

# Performance testing
./docs/scripts/performance-test.sh
```

### 3. Deployment Workflow

```bash
# Deploy testnet
./docs/scripts/deploy-testnet.sh

# Launch strategies
./docs/scripts/launch_strategies.ps1 -LaunchAll

# Monitor strategies
./docs/scripts/monitor_strategies.ps1
```

## Script Dependencies

### 1. Required Tools

#### PowerShell Scripts
- PowerShell 5.1 or later
- Docker Desktop
- Maven (for testing scripts)

#### Bash Scripts
- Bash 4.0 or later
- Docker and Docker Compose
- Maven
- curl
- netstat (for port checking)

### 2. Environment Requirements

#### Common Requirements
- Docker Desktop running
- Project root directory
- Appropriate environment variables set

#### Testnet Scripts
- `testnet.env` file with API keys
- Testnet environment variables

#### Production Scripts
- Production API keys
- Production environment configuration

## Script Configuration

### 1. Environment Variables

#### Common Variables
```bash
# API Keys
BINANCE_API_KEY=your_api_key
BINANCE_API_SECRET=your_secret_key
TESTNET_API_KEY=your_testnet_key
TESTNET_SECRET_KEY=your_testnet_secret

# Service URLs
BINANCE_REST_BASE_URL=https://api.binance.com
TESTNET_API_URL=https://testnet.binance.vision

# Ports
POSTGRES_PORT=5432
ELASTICSEARCH_PORT=9200
KAFKA_PORT=9092
```

#### Testnet Specific
```bash
# Testnet Configuration
SPRING_PROFILES_ACTIVE=testnet
BINANCE_TRADER_TEST_ORDER_MODE_ENABLED=true
```

### 2. Script Parameters

#### Common Parameters
- `IntervalSeconds`: Monitoring interval (default: 30)
- `MaxIterations`: Maximum iterations (0 = infinite)
- `Verbose`: Verbose output
- `Skip*`: Skip specific test types

#### Strategy Parameters
- `LaunchAll`: Launch all strategies
- `LaunchBTC`: Launch BTC strategy
- `LaunchETH`: Launch ETH strategy
- `LaunchADA`: Launch ADA strategy
- `LaunchSOL`: Launch SOL strategy
- `StrategyType`: Strategy type (default: MACD)

## Error Handling

### 1. Common Error Scenarios

#### Service Not Available
- Check if Docker is running
- Verify service health
- Check port availability

#### API Key Issues
- Verify API key format
- Check API key permissions
- Validate network connectivity

#### Port Conflicts
- Check port usage
- Kill conflicting processes
- Use different ports

### 2. Debugging Commands

```bash
# Check service status
docker-compose ps

# View service logs
docker-compose logs service-name

# Check port usage
netstat -tulpn | grep :port

# Test API connectivity
curl -f http://localhost:port/actuator/health
```

## Best Practices

### 1. Script Execution

#### Before Running Scripts
1. Ensure Docker is running
2. Verify environment variables
3. Check port availability
4. Validate API keys

#### During Execution
1. Monitor output for errors
2. Check service health
3. Verify connectivity
4. Review logs

#### After Execution
1. Verify service status
2. Check health endpoints
3. Review monitoring data
4. Clean up resources

### 2. Script Maintenance

#### Regular Updates
- Update script dependencies
- Review error handling
- Update documentation
- Test with new configurations

#### Version Control
- Track script changes
- Document modifications
- Test before committing
- Tag stable versions

## Troubleshooting Guide

### 1. Common Issues

#### Script Won't Start
- Check PowerShell execution policy
- Verify script permissions
- Check required tools

#### Services Not Responding
- Check Docker status
- Verify service health
- Review service logs
- Check port conflicts

#### API Key Errors
- Validate API key format
- Check API key permissions
- Verify network connectivity
- Test with curl

### 2. Debugging Steps

1. **Check Prerequisites**
   - Docker running
   - Required tools installed
   - Environment variables set

2. **Verify Service Status**
   - Check Docker containers
   - Verify service health
   - Review service logs

3. **Test Connectivity**
   - Test API endpoints
   - Check port availability
   - Verify network connectivity

4. **Review Configuration**
   - Check environment variables
   - Verify script parameters
   - Review service configuration

## Future Improvements

### 1. Script Enhancements

#### Automation
- Add automated testing
- Implement CI/CD integration
- Add error recovery
- Improve logging

#### Monitoring
- Add metrics collection
- Implement alerting
- Add performance tracking
- Improve reporting

#### Security
- Add input validation
- Implement secure credential handling
- Add audit logging
- Improve error handling

### 2. Documentation

#### User Guides
- Create step-by-step guides
- Add troubleshooting sections
- Include examples
- Add best practices

#### API Documentation
- Document script parameters
- Add usage examples
- Include error codes
- Add configuration options

## Conclusion

This index provides a comprehensive reference for all deployment scripts in the Binance AI Traders project. Regular updates and maintenance will ensure the scripts remain effective and reliable.

For questions or issues, refer to the troubleshooting section or contact the development team.
