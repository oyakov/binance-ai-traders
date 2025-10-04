# Agent Context & Repository Guidance

## 🎯 Project Overview

**binance-ai-traders** is a comprehensive automated trading system for Binance cryptocurrency exchange, featuring advanced backtesting, real-time data collection, and multiple trading strategies. The system is built as a microservices architecture with Java/Spring Boot backend services and a Python Telegram frontend.

### Current Project Status
- **M0 (Backtesting Engine)**: ✅ **COMPLETED** - Full backtesting engine with 2,400+ test scenarios
- **M1 (Testnet Launch)**: 🚧 **IN PROGRESS** - Multi-instance testnet validation phase
- **M2 (Production Launch)**: 📋 **PLANNED** - Low-budget production deployment

## 🏗️ Architecture & Services

### Core Services Status
| Service | Purpose | Tech Stack | Implementation Status | Critical Notes |
|---------|---------|------------|----------------------|----------------|
| **binance-data-collection** | Real-time Binance WebSocket data | Java 17, Spring Boot, Kafka | 🔴 **Skeleton** | Missing WebSocket/REST implementation |
| **binance-data-storage** | Persist market data | Java 17, Spring Boot, PostgreSQL, Elasticsearch | 🟢 **Substantial** | Well-implemented with dual persistence |
| **binance-trader-macd** | MACD trading strategy + backtesting | Java 17, Spring Boot, Binance API | 🟡 **Partial** | Backtesting complete, strategy logic incomplete |
| **binance-trader-grid** | Grid trading strategy | Java 17, Spring Boot, Kafka | 🔴 **Duplicate** | Duplicates storage service, needs implementation |
| **binance-shared-model** | Avro schemas for communication | Java 17, Avro | 🟢 **Complete** | Basic but functional |
| **telegram-frontend-python** | User interface and notifications | Python 3.11, FastAPI, aiogram | 🔴 **Scaffolding** | Extensive scaffolding, not runnable |

### Infrastructure Components
- **Kafka**: Message streaming and event distribution
- **PostgreSQL**: Relational data storage
- **Elasticsearch**: Search and analytics
- **Docker Compose**: Local development environment
- **Grafana**: Monitoring dashboards
- **Prometheus**: Metrics collection

## 🧠 Memory System & Context

### Active Findings (Critical Issues)
- **MEM-001**: Data Collection Service Implementation Gap
- **MEM-004**: Critical Testnet Integration Gaps
- **MEM-005**: Telegram Frontend Critical Dependencies Missing
- **MEM-006**: MACD Strategy Signal Generation Failure
- **MEM-007**: Database Compatibility Issues Blocking Integration Tests
- **MEM-008**: Grid Trader Service Duplication Issue

### Root Causes Identified
- **MEM-009**: Incomplete Service Integration Architecture
- **MEM-010**: Insufficient Testing Strategy
- **MEM-011**: Configuration Management Gaps

## 🚀 Development Workflow

### Code Conventions
- **Java Services**: Use Java 17, Spring Boot, Maven
- **Python Services**: Use Python 3.11, Poetry for dependency management
- **Type Safety**: Enforce type hints with `typing` or `pydantic` models
- **Documentation**: Write docstrings for public functions/classes with usage examples
- **Architecture**: Follow DDD principles, avoid circular imports using `binance-shared-model`

### Testing Strategy
- **Unit Tests**: Run with `pytest` (Python) or Maven Surefire (Java)
- **Integration Tests**: Use `docker compose` for service integration checks
- **Code Quality**: Validate with `ruff` (Python) and `mypy` (Python)
- **Coverage**: Maintain comprehensive test coverage, document any gaps

### Service Dependencies
```
binance-shared-model (foundation)
    ↓
binance-data-collection → binance-data-storage
    ↓
binance-trader-macd / binance-trader-grid
    ↓
telegram-frontend-python
```

## 📋 Current Priorities

### Immediate Actions Required
1. **Complete Data Collection Service**: Implement WebSocket consumers and Kafka publishers
2. **Fix MACD Trader Strategy Logic**: Complete signal generation and order placement
3. **Implement Grid Trader**: Replace duplicate code with actual strategy implementation
4. **Fix Telegram Bot Dependencies**: Resolve missing imports and make bot runnable
5. **Testnet Integration**: Complete M1 testnet deployment infrastructure

### Development Guidelines
- **Service Isolation**: Each service should be independently deployable
- **Configuration Management**: Use Spring profiles for different environments
- **Error Handling**: Implement comprehensive error handling and recovery
- **Monitoring**: Add health checks and metrics for all services
- **Security**: Implement proper API key management and encryption

## 🔧 Technical Standards

### Java Services
- **Framework**: Spring Boot 3.x
- **Build Tool**: Maven
- **Database**: JPA with PostgreSQL, Elasticsearch for analytics
- **Messaging**: Kafka with Avro serialization
- **Testing**: JUnit 5, Mockito, TestContainers

### Python Services
- **Framework**: FastAPI, aiogram
- **Build Tool**: Poetry
- **Database**: SQLAlchemy with PostgreSQL
- **Testing**: pytest, pytest-asyncio
- **Code Quality**: ruff, mypy, black

### Infrastructure
- **Containerization**: Docker with multi-stage builds
- **Orchestration**: Docker Compose for local development
- **Monitoring**: Prometheus + Grafana
- **Logging**: Structured logging with correlation IDs

## 📚 Documentation Standards

### Required Documentation
- **Service READMEs**: Each service must have comprehensive README
- **API Documentation**: Document all REST endpoints and Kafka topics
- **Configuration Guides**: Document all configuration options
- **Deployment Guides**: Step-by-step deployment instructions
- **Troubleshooting**: Common issues and solutions

### Documentation Structure
- **docs/services/**: Service-specific documentation
- **docs/guides/**: Implementation and deployment guides
- **docs/reports/**: Analysis and test results
- **docs/memory/**: LLM memory and knowledge management

## 🚨 Critical Issues & Blockers

### High Priority
1. **Data Collection Gap**: Cannot collect real-time data from Binance
2. **Strategy Implementation**: MACD and Grid strategies not functional
3. **Telegram Bot**: Not runnable due to missing dependencies
4. **Testnet Integration**: Missing testnet-specific configuration

### Medium Priority
1. **Testing Coverage**: Insufficient integration testing
2. **Monitoring**: Limited observability into system health
3. **Configuration**: Environment-specific configuration gaps
4. **Documentation**: Some services lack comprehensive documentation

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

## 🔄 Contribution Workflow

### Development Process
1. **Branch Strategy**: Create feature/bugfix branches from `main`
2. **Code Review**: All changes require review from domain owners
3. **Testing**: Run all relevant tests before submitting PRs
4. **Documentation**: Update documentation alongside code changes
5. **Integration**: Test changes in Docker Compose environment

### PR Requirements
- Clear description of changes and rationale
- Tests executed and their outcomes
- Documentation updates
- Follow-up tasks or deployment notes
- Reference to related issues or memory entries

## 🆘 Getting Help

### Documentation Resources
- **System Overview**: [docs/overview.md](overview.md)
- **Service Documentation**: [docs/services/](services/)
- **Memory System**: [docs/memory/memory-index.md](memory/memory-index.md)
- **Milestone Guide**: [docs/guides/MILESTONE_GUIDE.md](guides/MILESTONE_GUIDE.md)

### Key Contacts
- **Technical Lead**: Development team
- **Architecture**: System architecture team
- **Testing**: Quality assurance team

---

**Last Updated**: 2025-01-05  
**Version**: 2.0 (Agent Context)  
**Status**: M0 Complete, M1 In Progress
