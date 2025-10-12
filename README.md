# Binance AI Traders

A comprehensive automated trading system for Binance cryptocurrency exchange, featuring advanced backtesting, real-time data collection, and multiple trading strategies. Built as a microservices architecture with Java/Spring Boot backend services and Python Telegram frontend.

## 🎯 Current Status

- **M0 (Backtesting Engine)**: ✅ **COMPLETED** - Full backtesting engine with 2,400+ test scenarios
- **M1 (Testnet Launch)**: 🚧 **IN PROGRESS** - Multi-instance testnet validation phase  
- **M2 (Production Launch)**: 📋 **PLANNED** - Low-budget production deployment

## 🚀 Quick Start

```bash
# Clone and build
git clone <repository-url>
cd binance-ai-traders
mvn clean install

# Start the system
docker-compose -f docker-compose-testnet.yml up -d

# Test the backtesting engine
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

📖 **[Full Quick Start Guide](docs/guides/QUICK_START.md)**

## 🏗️ Architecture

The system consists of microservices communicating through Kafka:

- **Data Collection** → **Data Storage** → **Trading Strategies** → **Telegram Bot**
- **Real-time WebSocket** data from Binance
- **Comprehensive backtesting** engine with real historical data
- **Multiple trading strategies** (MACD, Grid)
- **Telegram integration** for monitoring and control

## 📊 Key Features

- **🧪 Advanced Backtesting**: Test strategies on real Binance historical data (2,400+ scenarios tested)
- **📈 Multiple Strategies**: MACD, Grid trading, and extensible framework
- **⚡ Real-time Data**: Live WebSocket data collection from Binance
- **📱 Telegram Integration**: Monitor and control via Telegram bot
- **📊 Comprehensive Monitoring**: Grafana dashboards and metrics
- **🔒 Testnet Ready**: Safe testing environment with Binance testnet

## 🏗️ Services Status

| Service | Purpose | Tech Stack | Status | Notes |
|---------|---------|------------|--------|-------|
| **Data Collection** | Real-time Binance WebSocket data | Java 17, Spring Boot, Kafka | 🔴 **Skeleton** | Missing WebSocket implementation |
| **Data Storage** | Persist market data | Java 17, Spring Boot, PostgreSQL, Elasticsearch | 🟢 **Complete** | Well-implemented with dual persistence |
| **MACD Trader** | MACD trading strategy + backtesting | Java 17, Spring Boot, Binance API | 🟡 **Partial** | Backtesting complete, strategy logic incomplete |
| **Grid Trader** | Grid trading strategy | Java 17, Spring Boot, Kafka | 🔴 **Duplicate** | Needs implementation |
| **Telegram Bot** | User interface and notifications | Python 3.11, FastAPI, aiogram | 🔴 **Scaffolding** | Not runnable, missing dependencies |

## 🧪 Backtesting Engine

Test trading strategies on real Binance historical data:

```bash
# Run comprehensive backtesting demo
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

**Features:**
- Real Binance API data integration
- Multiple timeframes and symbols
- Comprehensive performance metrics
- Risk analysis and optimization
- **2,400+ test scenarios executed successfully**

## 🚀 Getting Started

### Prerequisites
- **Docker** and **Docker Compose**
- **Java 17+** and **Maven 3.8+**
- **Python 3.11+** (for Telegram bot)
- **Binance Testnet Account**

### Quick Setup
```bash
# 1. Build all services
mvn clean install

# 2. Configure environment
cp testnet.env.example testnet.env
# Edit testnet.env with your API keys

# 3. Start the system
docker-compose -f docker-compose-testnet.yml up -d

# 4. Verify installation
./docs/scripts/health-check-test.sh
```

### Access Points
- **Grafana Dashboard**: http://localhost:3001
- **Service Health**: http://localhost:8083/actuator/health
- **Elasticsearch**: http://localhost:9200

📖 **[Detailed Setup Guide](docs/guides/QUICK_START.md)**

## 📚 Documentation

### 🚀 Getting Started
- **[Quick Start Guide](docs/guides/QUICK_START.md)** - Get running in 5 minutes
- **[Where-is-what Index](docs/WHERE_IS_WHAT.md)** - Quick navigation across files
- **[System Overview](docs/overview.md)** - Architecture and design
- **[Agent Context](docs/AGENTS.md)** - Comprehensive agent guidance
- **[Backtesting Guide](binance-trader-macd/BACKTESTING_ENGINE.md)** - Strategy validation

### 🏗️ Development
- **[Service Documentation](docs/services/README.md)** - Individual service guides
- **[PowerShell Scripts](scripts/README.md)** - Windows automation and monitoring
- **[Bash Scripts](docs/scripts/README.md)** - Linux/macOS automation
- **[Infrastructure](docs/infrastructure/README.md)** - Docker and monitoring

### 📊 Analysis & Reports
- **[Test Results](docs/reports/)** - Comprehensive analysis reports
- **[Monitoring Reports](docs/reports/monitoring/README.md)** - Grafana consolidation, dashboard progress, observability rollouts
- **[Status Updates](docs/reports/status/README.md)** - Point-in-time improvements and system evaluations
- **[Incident Reviews](docs/reports/incidents/README.md)** - Root-cause analyses and remediation tracking
- **[Milestone Guide](docs/guides/MILESTONE_GUIDE.md)** - Project roadmap
- **[Testnet Guide](docs/guides/TESTNET_LAUNCH_GUIDE.md)** - Testnet deployment
- **[Memory System](docs/memory/memory-index.md)** - LLM knowledge management

## 🚨 Current Issues & Priorities

### Critical Issues
1. **Data Collection Gap**: Missing WebSocket implementation for real-time data
2. **Strategy Implementation**: MACD and Grid strategies need completion
3. **Telegram Bot**: Not runnable due to missing dependencies
4. **Testnet Integration**: Missing testnet-specific configuration

### Immediate Actions Required
1. Complete Data Collection Service implementation
2. Fix MACD Trader strategy logic
3. Implement Grid Trader (replace duplicate code)
4. Fix Telegram Bot dependencies
5. Complete M1 testnet deployment infrastructure

## 🤝 Contributing

We welcome contributions! Please see our [Agent Context Guide](docs/AGENTS.md) for comprehensive development guidelines.

### Development Workflow
1. Fork the repository
2. Create a feature branch from `main`
3. Follow DDD principles for service design
4. Add tests for new functionality
5. Update documentation alongside code changes
6. Submit a pull request with clear description

### Code Standards
- **Java**: Java 17, Spring Boot 3.x, Maven
- **Python**: Python 3.11, Poetry, FastAPI
- **Testing**: Comprehensive unit and integration tests
- **Documentation**: Update relevant docs with changes

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs/README.md](docs/README.md)
- **Agent Context**: [docs/AGENTS.md](docs/AGENTS.md)
- **Memory System**: [docs/memory/memory-index.md](docs/memory/memory-index.md)
- **Issues**: [GitHub Issues](https://github.com/your-org/binance-ai-traders/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/binance-ai-traders/discussions)

---

**Status**: M0 Complete, M1 In Progress  
**Version**: 2.0 (Agent Context)  
**Last Updated**: 2025-01-05
