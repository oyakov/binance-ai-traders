# Quick Start Guide

Get up and running with the Binance AI Traders system in minutes.

## 🚀 Prerequisites

### Required Software
- **Docker** and **Docker Compose** (latest version)
- **Java 17+** (for local development)
- **Maven 3.8+** (for building Java services)
- **Python 3.11+** (for Telegram frontend)

### Required Accounts
- **Binance Testnet Account** (for testing)
- **Telegram Bot Token** (for notifications)

## ⚡ 5-Minute Setup

### 1. Clone and Build
```bash
# Clone the repository
git clone <repository-url>
cd binance-ai-traders

# Build all services
mvn clean install
```

### 2. Configure Environment
```bash
# Copy environment template
cp testnet.env.example testnet.env

# Edit configuration (add your API keys)
nano testnet.env
```

### 3. Start the System
```bash
# Start all services with Docker Compose
docker-compose -f docker-compose-testnet.yml up -d

# Check service health
./docs/scripts/health-check-test.sh
```

### 4. Verify Installation
- **Grafana Dashboard**: http://localhost:3001
- **Service Health**: http://localhost:8083/actuator/health
- **Kafka**: http://localhost:9092

## 🧪 Test the Backtesting Engine

### Run the Demo
```bash
# Execute comprehensive backtesting demo
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

### Expected Output
You should see detailed backtesting results including:
- Performance metrics (profit, win rate, Sharpe ratio)
- Risk analysis (drawdown, volatility)
- Trade breakdown with entry/exit prices
- Strategy performance vs buy-and-hold

## 🎯 Launch Trading Strategies

### Windows
```powershell
# Launch all strategies
.\docs\scripts\launch_strategies.ps1 -LaunchAll

# Launch specific strategy
.\docs\scripts\launch_strategies.ps1 -LaunchBTC
```

### Linux/macOS
```bash
# Launch strategies (if implemented)
./docs/scripts/launch_strategies.sh --all
```

## 📊 Monitor Performance

### Access Dashboards
1. **Strategy Overview**: http://localhost:3001/d/strategy-overview-000/strategy-overview
2. **BTC Strategy**: http://localhost:3001/d/btc-macd-strategy-001/btc-macd-strategy
3. **System Health**: http://localhost:3001/d/system-health-000/system-health

### Monitor Logs
```bash
# View all service logs
docker-compose -f docker-compose-testnet.yml logs -f

# View specific service logs
docker-compose -f docker-compose-testnet.yml logs -f binance-trader-macd
```

## 🔧 Configuration

### Trading Parameters
Edit `binance-trader-macd/src/main/resources/application.yml`:

```yaml
binance:
  trader:
    testOrderModeEnabled: true
    stopLossPercentage: 0.98
    takeProfitPercentage: 1.05
    orderQuantity: 0.05
    slidingWindowSize: 78
```

### Strategy Settings
Modify strategy parameters in the configuration:

```yaml
macd:
  fastEmaPeriod: 12
  slowEmaPeriod: 26
  signalPeriod: 9
```

## 🚨 Troubleshooting

### Common Issues

#### Services Won't Start
```bash
# Check Docker is running
docker --version
docker-compose --version

# Check port availability
netstat -tulpn | grep :8083
```

#### API Connection Issues
```bash
# Verify API keys in testnet.env
cat testnet.env

# Test API connectivity
curl -X GET "https://testnet.binance.vision/api/v3/ping"
```

#### Memory Issues
```bash
# Increase Docker memory limit
# Edit docker-compose-testnet.yml and add:
# deploy:
#   resources:
#     limits:
#       memory: 2G
```

### Getting Help
1. Check [Troubleshooting Guide](TROUBLESHOOTING.md)
2. Review [Service Documentation](../services/README.md)
3. Check logs in `testnet_logs/`
4. Verify configuration in `testnet.env`

## 📈 Next Steps

### 1. Explore Backtesting
- Try different MACD parameters
- Test on different symbols (BTC, ETH, ADA)
- Experiment with various timeframes

### 2. Deploy to Testnet
- Follow [Testnet Launch Guide](TESTNET_LAUNCH_GUIDE.md)
- Set up multiple strategy instances
- Monitor performance over time

### 3. Customize Strategies
- Modify trading parameters
- Add new indicators
- Implement custom strategies

### 4. Production Deployment
- Review [Milestone Guide](MILESTONE_GUIDE.md)
- Follow security best practices
- Start with minimal capital

## 📚 Additional Resources

### Documentation
- [System Overview](../overview.md) - Architecture overview
- [Backtesting Guide](../BACKTESTING_README.md) - Strategy validation
- [Service Documentation](../services/README.md) - Individual services
- [Scripts Documentation](../scripts/README.md) - Automation tools

### Monitoring
- [Grafana Setup](../infrastructure/monitoring-grafana-testnet.md)
- [Performance Monitoring](../infrastructure/README.md)

### Development
- [Contributing Guidelines](../CONTRIBUTING.md)
- [API Documentation](../services/README.md)
- [Testing Guide](../TESTING.md)

## 🆘 Support

### Quick Help
- **Documentation**: Check the [docs](../README.md) directory
- **Issues**: Search existing issues or create new ones
- **Discussions**: Use project discussions for questions

### Emergency Contacts
- **Technical Issues**: Development team
- **Trading Issues**: Risk management team
- **Infrastructure**: DevOps team

---

**Last Updated**: 2025-01-05  
**Version**: 2.0  
**Status**: Ready for Use
