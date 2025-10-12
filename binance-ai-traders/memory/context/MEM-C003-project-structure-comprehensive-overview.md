# MEM-C003: Project Structure Comprehensive Overview

**Type**: Context  
**Status**: Active  
**Created**: 2025-01-08  
**Last Updated**: 2025-01-08  
**Scope**: Global  

## Project Overview

The **binance-ai-traders** project is a comprehensive automated trading system for Binance cryptocurrency exchange. It features advanced backtesting, real-time data collection, and multiple trading strategies, built as a microservices architecture with Java/Spring Boot backend services and a Python Telegram frontend.

## Current Project Status

- **M0 (Backtesting Engine)**: ✅ **COMPLETED** - Full backtesting engine with 2,400+ test scenarios
- **M1 (Testnet Launch)**: 🚧 **IN PROGRESS** - Multi-instance testnet validation phase  
- **M2 (Production Launch)**: 📋 **PLANNED** - Low-budget production deployment

## Core Architecture

### Data Flow
```
Binance API → Data Collection → Kafka → Data Storage → PostgreSQL/Elasticsearch
                                    ↓
                              MACD Trader → Binance API (Orders)
                                    ↓
                              Telegram Bot (Monitoring)
```

### Technology Stack
- **Backend**: Java 21, Spring Boot 3.3.9, Maven
- **Message Streaming**: Apache Kafka 3.8.0, Confluent Schema Registry 7.5.1
- **Data Storage**: PostgreSQL (relational), Elasticsearch 8.5.0 (search/analytics)
- **Frontend**: Python 3.11, FastAPI, aiogram (Telegram bot)
- **Monitoring**: Prometheus, Grafana
- **Containerization**: Docker, Docker Compose
- **Build System**: Maven (multi-module project)

## Microservices Architecture

### 1. binance-shared-model
- **Purpose**: Avro schemas for cross-service communication
- **Status**: 🟢 **Complete** - Basic but functional
- **Key Features**:
  - Avro schema definitions for kline events
  - Shared data contracts across services
  - Kafka serialization support

### 2. binance-data-collection
- **Purpose**: Real-time Binance WebSocket data collection
- **Status**: 🔴 **Skeleton** - Missing WebSocket implementation
- **Key Features** (Planned):
  - WebSocket connection to Binance API
  - Real-time kline data streaming
  - Kafka message publishing
  - Connection management and error handling

### 3. binance-data-storage
- **Purpose**: Persist and normalize market data
- **Status**: 🟢 **Substantial** - Well-implemented with dual persistence
- **Key Features**:
  - Dual persistence: PostgreSQL + Elasticsearch
  - Kafka consumer for kline events
  - Data normalization and validation
  - Connection health monitoring
  - Flyway database migrations

### 4. binance-trader-macd
- **Purpose**: MACD trading strategy + comprehensive backtesting
- **Status**: 🟡 **Partial** - Backtesting complete, strategy logic incomplete
- **Key Features**:
  - ✅ Advanced backtesting engine (2,400+ test scenarios)
  - ✅ Real Binance API data integration
  - ✅ Comprehensive performance metrics
  - ✅ Risk analysis and optimization
  - 🔄 MACD strategy implementation (in progress)
  - 🔄 Order placement logic (in progress)

### 5. binance-trader-grid
- **Purpose**: Grid trading strategy
- **Status**: 🔴 **Duplicate** - Duplicates storage service, needs implementation
- **Issues**: Currently contains duplicate code from data-storage service

### 6. telegram-frontend-python
- **Purpose**: User interface and notifications via Telegram
- **Status**: 🔴 **Scaffolding** - Extensive scaffolding, not runnable
- **Key Features** (Planned):
  - Telegram bot interface
  - Trading signal notifications
  - System monitoring and control
  - User authentication and permissions

## Infrastructure Components

### Message Streaming
- **Kafka**: Apache Kafka 3.8.0 with KRaft mode (no ZooKeeper)
- **Schema Registry**: Confluent Schema Registry 7.5.1
- **Topics**: kline-events, trading-signals, system-health

### Data Storage
- **PostgreSQL**: Primary relational database for structured data
- **Elasticsearch**: Search and analytics engine for time-series data
- **Dual Persistence**: Both databases store kline events for different use cases

### Monitoring & Observability
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **Micrometer**: Application metrics in Spring Boot services
- **Actuator**: Health checks and operational endpoints

### Container Orchestration
- **Docker**: Service containerization
- **Docker Compose**: Local development environment
- **Multiple Compose Files**:
  - `docker-compose.yml` - Main development stack
  - `docker-compose-testnet.yml` - Testnet environment
  - `docker-compose.override.yml` - Local overrides

## Development Environment

### Build System
- **Maven**: Multi-module project structure
- **Java 21**: Latest LTS version
- **Spring Boot 3.3.9**: Latest stable version
- **Lombok**: Code generation and boilerplate reduction

### Testing Strategy
- **Unit Tests**: JUnit 5 with Spring Boot Test
- **Integration Tests**: TestContainers for database testing
- **Backtesting**: Comprehensive strategy validation
- **Code Coverage**: JaCoCo reporting

### Development Tools
- **Docker Compose**: Local service orchestration
- **PowerShell Scripts**: Windows automation (74 scripts)
- **Bash Scripts**: Linux/macOS automation
- **Postman Collections**: API testing and validation

## Key Features

### Advanced Backtesting
- Real Binance historical data integration
- Multiple timeframes and trading pairs
- Comprehensive performance metrics
- Risk analysis and optimization
- 2,400+ test scenarios executed successfully

### Real-time Data Processing
- WebSocket data streaming from Binance
- Kafka-based event processing
- Dual persistence for reliability
- Elasticsearch for time-series analytics

### Multiple Trading Strategies
- MACD strategy (in development)
- Grid trading strategy (planned)
- Extensible framework for new strategies
- Strategy performance monitoring

### Comprehensive Monitoring
- Prometheus metrics collection
- Grafana dashboards for visualization
- Health checks and alerting
- Performance monitoring and optimization

### Telegram Integration
- Bot interface for monitoring and control
- Real-time notifications
- Trading signal alerts
- System status updates

## Current Critical Issues

### Implementation Gaps
1. **Data Collection**: Missing WebSocket implementation
2. **MACD Strategy**: Incomplete trading logic
3. **Grid Trader**: Duplicate code, needs proper implementation
4. **Telegram Bot**: Missing dependencies, not runnable

### Integration Issues
1. **Testnet Configuration**: Missing testnet-specific setup
2. **Service Dependencies**: Incomplete service integration
3. **Configuration Management**: Environment-specific configs needed

### Testing & Quality
1. **Integration Tests**: Database compatibility issues
2. **End-to-End Testing**: Missing comprehensive test coverage
3. **Performance Testing**: No load testing framework

## Project Structure

```
binance-ai-traders/
├── binance-shared-model/          # Avro schemas
├── binance-data-collection/       # WebSocket data collection
├── binance-data-storage/          # Data persistence
├── binance-trader-macd/           # MACD strategy + backtesting
├── binance-trader-grid/           # Grid trading strategy
├── telegram-frontend-python/      # Telegram bot interface
├── monitoring/                    # Prometheus & Grafana configs
├── docs/                         # Comprehensive documentation
├── scripts/                      # Automation scripts
├── postman/                      # API testing collections
└── docker-compose*.yml           # Container orchestration
```

## Documentation System

### Comprehensive Documentation
- **System Overview**: Architecture and design principles
- **Service Documentation**: Individual microservice guides
- **Deployment Guides**: Testnet and production deployment
- **API Documentation**: Service endpoints and contracts
- **Memory System**: LLM knowledge management

### Memory Management
- **Context Entries**: System architecture and dependencies
- **Findings**: Critical issues and implementation gaps
- **Templates**: Documentation and development templates
- **Infrastructure**: Deployment and monitoring guides

## Next Steps

### Immediate Priorities (M1)
1. Complete Data Collection Service implementation
2. Fix MACD Trader strategy logic
3. Implement Grid Trader (replace duplicate code)
4. Fix Telegram Bot dependencies
5. Complete testnet deployment infrastructure

### Medium-term Goals (M2)
1. Production deployment optimization
2. Performance monitoring and alerting
3. Advanced trading strategies
4. User interface improvements
5. Comprehensive testing framework

---

**Related Memory Entries**: MEM-C001, MEM-C002, MEM-001 through MEM-011  
**Dependencies**: All microservices, infrastructure components  
**Last Review**: 2025-01-08
