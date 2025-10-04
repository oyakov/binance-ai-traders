# Binance AI Traders

A comprehensive automated trading system for Binance cryptocurrency exchange, featuring advanced backtesting, real-time data collection, and multiple trading strategies.

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

- **Data Collection** → **Data Storage** → **Indicator Calculator** → **Trading Strategies**
- **Real-time WebSocket** data from Binance
- **Comprehensive backtesting** engine with real historical data
- **Multiple trading strategies** (MACD, Grid)
- **Telegram integration** for monitoring and control

## 📊 Key Features

- **🧪 Advanced Backtesting**: Test strategies on real Binance historical data
- **📈 Multiple Strategies**: MACD, Grid trading, and extensible framework
- **⚡ Real-time Data**: Live WebSocket data collection from Binance
- **📱 Telegram Integration**: Monitor and control via Telegram bot
- **📊 Comprehensive Monitoring**: Grafana dashboards and metrics
- **🔒 Testnet Ready**: Safe testing environment with Binance testnet

## 🏗️ Services

| Service | Purpose | Tech Stack |
|---------|---------|------------|
| **Data Collection** | Real-time Binance WebSocket data | Java, Spring Boot, Kafka |
| **Data Storage** | Persist market data | Java, Spring Boot, Elasticsearch |
| **MACD Trader** | MACD trading strategy + backtesting | Java, Spring Boot, Binance API |
| **Grid Trader** | Grid trading strategy | Java, Spring Boot, Kafka |
| **Telegram Bot** | User interface and notifications | Python, Telebot API |

## 📚 Documentation

### 🚀 Getting Started
- **[Quick Start Guide](docs/guides/QUICK_START.md)** - Get running in 5 minutes
- **[System Overview](docs/overview.md)** - Architecture and design
- **[Backtesting Guide](BACKTESTING_README.md)** - Strategy validation

### 🏗️ Development
- **[Service Documentation](docs/services/README.md)** - Individual service guides
- **[Scripts](docs/scripts/README.md)** - Automation and deployment
- **[Infrastructure](docs/inrastructure/README.md)** - Docker and monitoring

### 📊 Analysis & Reports
- **[Test Results](docs/reports/)** - Comprehensive analysis reports
- **[Milestone Guide](docs/guides/MILESTONE_GUIDE.md)** - Project roadmap
- **[Testnet Guide](docs/guides/TESTNET_LAUNCH_GUIDE.md)** - Testnet deployment

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

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Follow DDD principles for service design
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs/README.md](docs/README.md)
- **Issues**: [GitHub Issues](https://github.com/your-org/binance-ai-traders/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/binance-ai-traders/discussions)

---

**Status**: Active Development  
**Version**: 2.0  
**Last Updated**: 2025-01-05
