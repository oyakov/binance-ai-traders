# Binance AI Traders - Project Rules & Core Features

## 🎯 Project Overview

**Binance AI Traders** is a comprehensive automated trading system for Binance cryptocurrency exchange, featuring advanced backtesting, real-time data collection, and multiple trading strategies. The system is built as a microservices architecture with Java/Spring Boot backend services and a Python Telegram frontend.

### Current Project Status
- **M0 (Backtesting Engine)**: ✅ **COMPLETED** - Full backtesting engine with 2,400+ test scenarios
- **M1 (Testnet Launch)**: 🚧 **IN PROGRESS** - Multi-instance testnet validation phase
- **M2 (Production Launch)**: 📋 **PLANNED** - Low-budget production deployment

## 🏗️ Core Architecture Rules

### 1. Microservices Architecture
- **Rule**: All services must be independently deployable and loosely coupled
- **Implementation**: Each service has its own Docker container and configuration
- **Communication**: Services communicate via Kafka events using Avro schemas
- **Dependencies**: Services depend on `binance-shared-model` for shared contracts

### 2. Service Dependencies
```
binance-shared-model (foundation)
    ↓
binance-data-collection → binance-data-storage
    ↓
binance-trader-macd / binance-trader-grid
    ↓
telegram-frontend-python
```

### 3. Technology Stack
- **Backend Services**: Java 17, Spring Boot 3.x, Maven
- **Frontend**: Python 3.11, FastAPI, aiogram
- **Data Storage**: PostgreSQL (relational), Elasticsearch (analytics)
- **Messaging**: Apache Kafka with Confluent Schema Registry
- **Infrastructure**: Docker, Docker Compose
- **Monitoring**: Prometheus, Grafana

## 📊 Core Features & Rules

### 1. Data Collection Service
**Purpose**: Stream real-time candlestick (kline) data from Binance WebSocket API

**Rules**:
- Must implement WebSocket clients for real-time data streaming
- Must publish normalized `KlineEvent` messages to Kafka topics
- Must handle API rate limiting and connection failures gracefully
- Must support multiple symbols and time intervals
- Must implement retry logic and error recovery

**Current Status**: 🔴 **Skeleton** - Missing WebSocket implementation

### 2. Data Storage Service
**Purpose**: Persist market data in dual storage systems

**Rules**:
- Must consume `KlineEvent` records from Kafka
- Must persist data to both PostgreSQL and Elasticsearch
- Must implement data normalization and mapping
- Must publish lifecycle events for downstream consumers
- Must handle compensation events for data consistency

**Current Status**: 🟢 **Complete** - Well-implemented with dual persistence

### 3. MACD Trading Strategy
**Purpose**: Implement MACD-based automated trading strategy

**Rules**:
- Must calculate MACD indicators (fast EMA, slow EMA, signal line)
- Must generate BUY/SELL signals based on crossovers
- Must integrate with Binance API for order placement
- Must implement risk management (stop-loss, take-profit)
- Must support both testnet and mainnet environments
- Must provide comprehensive backtesting capabilities

**Current Status**: 🟡 **Partial** - Backtesting complete, strategy logic incomplete

### 4. Grid Trading Strategy
**Purpose**: Implement grid trading strategy with layered buy/sell orders

**Rules**:
- Must place layered buy/sell orders around current market price
- Must implement grid spacing and order count configuration
- Must handle rebalancing and order management
- Must integrate with Kafka for market data consumption
- Must provide risk management and position sizing

**Current Status**: 🔴 **Duplicate** - Needs implementation (currently duplicates storage service)

### 5. Backtesting Engine
**Purpose**: Test trading strategies on historical data

**Rules**:
- Must fetch real historical data from Binance API
- Must simulate realistic trading execution
- Must calculate comprehensive performance metrics
- Must support multiple symbols and timeframes
- Must implement risk analysis and optimization
- Must provide detailed reporting and visualization

**Current Status**: 🟢 **Complete** - 2,400+ test scenarios executed successfully

### 6. Telegram Frontend
**Purpose**: Provide user interface and notifications

**Rules**:
- Must expose trading functionality through Telegram bot
- Must provide real-time monitoring and control
- Must implement user authentication and authorization
- Must send notifications for trades and alerts
- Must support multiple users and permissions

**Current Status**: 🔴 **Scaffolding** - Not runnable due to missing dependencies

## 🔧 Development Rules

### 1. Code Standards
- **Java**: Use Java 17, Spring Boot 3.x, Maven
- **Python**: Use Python 3.11, Poetry for dependency management
- **Type Safety**: Enforce type hints with `typing` or `pydantic` models
- **Documentation**: Write docstrings for public functions/classes
- **Architecture**: Follow DDD principles, avoid circular imports

### 2. Testing Requirements
- **Unit Tests**: Run with `pytest` (Python) or Maven Surefire (Java)
- **Integration Tests**: Use `docker compose` for service integration checks
- **Code Quality**: Validate with `ruff` (Python) and `mypy` (Python)
- **Coverage**: Maintain comprehensive test coverage

### 3. Configuration Management
- **Environment Variables**: Use Spring profiles for different environments
- **Secrets**: Store API keys and secrets in environment variables
- **Validation**: Validate all configuration at startup
- **Documentation**: Document all configuration options

### 4. Error Handling
- **Comprehensive**: Implement error handling for all external dependencies
- **Recovery**: Implement retry logic and circuit breakers
- **Logging**: Use structured logging with correlation IDs
- **Monitoring**: Expose health checks and metrics

## 🚨 Critical Issues & Priorities

### High Priority (Blocking M1)
1. **Data Collection Gap**: Cannot collect real-time data from Binance
2. **Strategy Implementation**: MACD and Grid strategies not functional
3. **Telegram Bot**: Not runnable due to missing dependencies
4. **Testnet Integration**: Missing testnet-specific configuration

### Medium Priority
1. **Testing Coverage**: Insufficient integration testing
2. **Monitoring**: Limited observability into system health
3. **Configuration**: Environment-specific configuration gaps
4. **Documentation**: Some services lack comprehensive documentation

## 📋 Service Implementation Rules

### 1. Data Collection Service
**Must Implement**:
- WebSocket client for Binance streams
- Kafka producer for `KlineEvent` messages
- Configuration for symbols and intervals
- Error handling and reconnection logic
- Health checks and metrics

### 2. MACD Trader Service
**Must Implement**:
- MACD signal calculation logic
- Kafka consumer for market data
- Binance API integration for orders
- Risk management implementation
- Position tracking and management

### 3. Grid Trader Service
**Must Implement**:
- Grid strategy logic
- Order management system
- Market data consumption
- Risk management
- Configuration management

### 4. Telegram Frontend
**Must Implement**:
- Bot command handlers
- User authentication
- Trading interface
- Notification system
- Error handling

## 🎯 Success Metrics

### M1 (Testnet) Goals
- All services running stable for 2+ weeks
- At least 3 strategies showing consistent profitability
- Risk management systems validated
- Performance metrics meeting backtesting expectations

### M2 (Production) Goals
- Strategy running stable on mainnet for 4+ weeks
- Consistent profitability above backtesting expectations
- Risk management systems working effectively
- Ready for scaled deployment

## 🔄 Development Workflow Rules

### 1. Branch Strategy
- Create feature/bugfix branches from `main`
- Use descriptive branch names
- Keep branches focused and small

### 2. Code Review
- All changes require review from domain owners
- Review must include testing verification
- Documentation updates must be included

### 3. Testing Requirements
- Run all relevant tests before submitting PRs
- Test changes in Docker Compose environment
- Verify integration with other services

### 4. Documentation
- Update documentation alongside code changes
- Include API documentation for new endpoints
- Update configuration guides for new options

## 🚀 Deployment Rules

### 1. Environment Configuration
- **Development**: Use `docker-compose.yml` for local development
- **Testnet**: Use `docker-compose-testnet.yml` for testnet validation
- **Production**: Use production-specific configuration

### 2. Service Dependencies
- Services must start in correct order
- Health checks must be implemented
- Graceful shutdown must be supported

### 3. Monitoring
- All services must expose health endpoints
- Metrics must be collected by Prometheus
- Logs must be structured and searchable

## 📚 Documentation Rules

### 1. Required Documentation
- Service READMEs with setup instructions
- API documentation for all endpoints
- Configuration guides for all options
- Deployment guides with step-by-step instructions
- Troubleshooting guides for common issues

### 2. Documentation Structure
- `docs/services/`: Service-specific documentation
- `docs/guides/`: Implementation and deployment guides
- `docs/reports/`: Analysis and test results
- `docs/memory/`: LLM memory and knowledge management

## 🔒 Security Rules

### 1. API Key Management
- Never commit API keys to version control
- Use environment variables for all secrets
- Implement proper key rotation
- Use testnet keys for development

### 2. Data Protection
- Encrypt sensitive data at rest
- Use secure communication protocols
- Implement proper access controls
- Regular security audits

## 🎯 Quality Assurance Rules

### 1. Code Quality
- Follow established coding standards
- Use static analysis tools
- Maintain high test coverage
- Regular code reviews

### 2. Performance
- Monitor service performance
- Optimize database queries
- Implement caching where appropriate
- Load testing for critical paths

### 3. Reliability
- Implement circuit breakers
- Use retry mechanisms
- Handle failures gracefully
- Regular health checks

---

**Last Updated**: 2025-01-05  
**Version**: 1.0 (Project Rules)  
**Status**: M0 Complete, M1 In Progress
