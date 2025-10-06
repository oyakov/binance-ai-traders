# Infrastructure Documentation

## Overview

This directory contains comprehensive documentation for the Binance AI Traders infrastructure, including Docker Compose files, deployment scripts, and operational procedures.

## Documentation Structure

### Core Documentation

1. **[Docker Compose Consolidation](docker-compose-consolidation.md)**
   - Comprehensive analysis of all Docker Compose files
   - Normalization recommendations
   - Service configurations and dependencies
   - Deployment workflows and troubleshooting

2. **[Deployment Scripts Index](../scripts/deployment-scripts-index.md)**
   - Complete index of all deployment scripts
   - Script categories and usage patterns
   - Configuration and troubleshooting guides

3. **[Quick Reference](quick-reference.md)**
   - Quick access to common commands
   - Service ports and URLs
   - Emergency procedures
   - Troubleshooting shortcuts

### Templates

4. **[Docker Compose Template](docker-compose-template.yml)**
   - Standardized template for new compose files
   - Environment-specific configurations
   - Best practices implementation

## Key Features

### Docker Compose Files

- **Production**: Core infrastructure with all services
- **Testnet**: Complete testnet environment with monitoring
- **Test**: Integration testing environment
- **Kafka KRaft**: Standalone Kafka with KRaft mode
- **Monitoring**: Standalone monitoring stack

### Deployment Scripts

- **Health Monitoring**: Continuous service health monitoring
- **Testing**: Comprehensive testing suite
- **Strategy Management**: Trading strategy launch and monitoring
- **Deployment**: Automated deployment procedures

### Normalization

- **Version Consistency**: Standardized on Docker Compose 3.8
- **Service Naming**: Consistent naming patterns
- **Port Management**: Organized port allocation
- **Network Management**: Standardized network names
- **Health Checks**: Uniform health check patterns

## Quick Start

### 1. Production Deployment
```bash
# Set environment variables
export BINANCE_API_KEY=your_key
export BINANCE_API_SECRET=your_secret

# Start infrastructure
docker-compose up -d postgres elasticsearch kafka schema-registry

# Start application
docker-compose up -d binance-data-collection

# Monitor health
./scripts/health-monitor.ps1
```

### 2. Testnet Deployment
```bash
# Set testnet variables
export TESTNET_API_KEY=your_testnet_key
export TESTNET_SECRET_KEY=your_testnet_secret

# Deploy testnet
./docs/scripts/deploy-testnet.sh

# Monitor testnet
./scripts/monitor_testnet.ps1
```

### 3. Testing
```bash
# Run tests
./docs/scripts/docker-test.sh

# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Run enhanced tests
./docs/scripts/run-enhanced-tests.sh
```

## Service Architecture

### Core Services
- **Data Collection**: Collects market data from Binance
- **Data Storage**: Stores data in PostgreSQL and Elasticsearch
- **MACD Trader**: Implements MACD trading strategy
- **Telegram Frontend**: Python-based user interface

### Infrastructure Services
- **PostgreSQL**: Primary database
- **Elasticsearch**: Search and analytics
- **Kafka**: Message streaming
- **Schema Registry**: Schema management
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards

## Monitoring and Observability

### Health Checks
- All services expose health endpoints
- Automated health monitoring scripts
- Comprehensive logging and metrics

### Service URLs
- Production: 8080-8099 range
- Testnet: 8100-8199 range
- Test: 8200-8299 range
- Monitoring: 9000-9099 range

### Monitoring Scripts
- **Health Monitor**: Continuous health monitoring
- **Testnet Monitor**: Comprehensive testnet monitoring
- **API Key Testing**: API key validation
- **Strategy Launcher**: Strategy management

## Security Considerations

### Environment Variables
- Use `.env` files for sensitive data
- Never commit API keys to version control
- Use Docker secrets for production

### Network Security
- Isolated networks for each environment
- Proper firewall rules
- TLS for production communication

### Container Security
- Specific image tags
- Regular security updates
- Minimal base images

## Troubleshooting

### Common Issues
- Port conflicts
- Service dependencies
- Database connectivity
- API key validation

### Debugging Commands
- Service status checking
- Log analysis
- Resource monitoring
- Connectivity testing

### Emergency Procedures
- Stop all services
- Reset environment
- Backup procedures
- Recovery steps

## Maintenance

### Regular Tasks
- **Daily**: Health checks, log monitoring
- **Weekly**: Dependency updates, performance review
- **Monthly**: Security updates, backup verification

### Backup Procedures
- Database backups
- Volume backups
- Configuration backups
- Recovery procedures

## Future Improvements

### Infrastructure as Code
- Terraform for infrastructure management
- GitOps workflows
- Automated testing

### Monitoring Enhancements
- Distributed tracing
- Custom metrics
- Alerting systems

### Security Improvements
- RBAC implementation
- Network policies
- Service mesh

### Performance Optimization
- Horizontal scaling
- Load balancing
- Resource optimization

## Support and Resources

### Documentation
- Comprehensive guides for all components
- Troubleshooting procedures
- Best practices and recommendations

### Scripts
- Automated deployment and monitoring
- Testing and validation tools
- Maintenance and backup utilities

### Monitoring
- Health monitoring scripts
- Performance tracking
- Alert systems

## Conclusion

This infrastructure documentation provides a comprehensive reference for managing the Binance AI Traders project. The consolidation and normalization efforts ensure consistency, maintainability, and operational excellence.

For questions or issues, refer to the troubleshooting sections or contact the development team.
