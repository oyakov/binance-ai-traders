# Binance AI Traders - Documentation

Welcome to the comprehensive documentation for the Binance AI Traders project. This documentation is organized to help you understand, deploy, and maintain the trading system.

## 📚 Documentation Structure

### 🏠 [System Overview](overview.md)
High-level architecture and system design overview.

### 🚀 [Quick Start Guide](guides/QUICK_START.md)
Get up and running quickly with the trading system.

### 📋 [Guides](guides/)
- [Milestone Guide](guides/MILESTONE_GUIDE.md) - Project progression roadmap
- [Testnet Launch Guide](guides/TESTNET_LAUNCH_GUIDE.md) - Testnet deployment instructions
- [Backtesting Guide](BACKTESTING_README.md) - Comprehensive backtesting documentation

### 🏗️ [Services](services/)
Detailed documentation for each microservice:
- [Data Collection](services/binance-data-collection.md)
- [Data Storage](services/binance-data-storage.md)
- [MACD Trader](services/binance-trader-macd.md)
- [Grid Trader](services/binance-trader-grid.md)
- [Indicator Calculator](services/indicator-calculator.md)

### 🗺️ Quick Navigation
- [Where-is-what Index](WHERE_IS_WHAT.md) — Jump table for modules, compose, monitoring, scripts

### 📄 Root-Level References
- [Core Features Summary](../CORE_FEATURES_SUMMARY.md)
- [Project Rules](../PROJECT_RULES.md)
- [System Recommendations](../SYSTEM_RECOMMENDATIONS.md)
- [Docker Build Optimization](../DOCKER_BUILD_OPTIMIZATION.md)
- [YAML Consolidation Summary](../YAML_CONSOLIDATION_SUMMARY.md)

### 📊 [Reports](reports/)
Analysis reports and test results:
- [Backtesting Evaluation](reports/BACKTESTING_EVALUATION_REPORT.md)
- [Comprehensive Analysis](reports/COMPREHENSIVE_ANALYSIS_RESULTS.md)
- [Test Coverage Report](reports/TEST_COVERAGE_REPORT.md)
- [Real Data Analysis](reports/REAL_DATA_ANALYSIS_RESULTS.md)

### 🔧 [Scripts](scripts/)
Automation and deployment scripts:
- [PowerShell Scripts](scripts/README.md) - Windows automation scripts
- [Shell Scripts](scripts/README.md) - Linux/macOS automation scripts

### 🏛️ [Infrastructure](infrastructure/)
- [Docker Compose](infrastructure/docker-compose.md)
- [Monitoring Setup](infrastructure/monitoring-grafana-testnet.md)
- [Infrastructure Quick Reference](infrastructure/quick-reference.md)

### 📡 Monitoring & Metrics
- [Metrics Testing Summary](../METRICS_TESTING_SUMMARY.md)
- [Grafana Dashboard Setup](../GRAFANA_DASHBOARD_SETUP.md)

### 📚 [Libraries](libs/)
- [Shared Model](libs/binance-shared-model.md)

### 🔌 [Client Integrations](clients/)
- [Telegram Frontend](clients/telegram-frontend-python.md)

### 🧪 Postman
- [Postman Collections](../postman/README.md)

### 🧠 [Memory System](memory/)
LLM memory and knowledge management system.

## 🚀 Quick Navigation

### For Developers
1. Start with [System Overview](overview.md)
2. Review [Service Documentation](services/README.md)
3. Check [Infrastructure Setup](infrastructure/README.md)

### For Operators
1. Follow [Quick Start Guide](guides/QUICK_START.md)
2. Use [Scripts](scripts/README.md) for automation
3. Monitor with [Grafana Dashboards](infrastructure/monitoring-grafana-testnet.md)

### For Analysts
1. Review [Backtesting Results](reports/BACKTESTING_EVALUATION_REPORT.md)
2. Check [Performance Analysis](reports/COMPREHENSIVE_ANALYSIS_RESULTS.md)
3. Understand [Strategy Implementation](services/binance-trader-macd.md)

## 📖 Key Documentation

### Essential Reading
- **[Main README](../README.md)** - Project overview and quick start
- **[Backtesting Engine](BACKTESTING_README.md)** - Strategy validation system
- **[Milestone Guide](guides/MILESTONE_GUIDE.md)** - Project roadmap
- **[Testnet Guide](guides/TESTNET_LAUNCH_GUIDE.md)** - Testnet deployment

### Architecture Documents
- **[System Overview](overview.md)** - High-level architecture
- **[Service Dependencies](memory/context/MEM-C002-service-dependencies-map.md)** - Service relationships
- **[High-Level Design](../high_level_design.drawio)** - System diagram

### Operational Guides
- **[Docker Setup](infrastructure/docker-compose.md)** - Container orchestration
- **[Monitoring](infrastructure/monitoring-grafana-testnet.md)** - System monitoring
- **[Scripts](scripts/README.md)** - Automation tools

## 🔍 Finding Information

### By Topic
- **Trading Strategies**: [Services](services/) → [MACD Trader](services/binance-trader-macd.md)
- **Data Collection**: [Services](services/) → [Data Collection](services/binance-data-collection.md)
- **Backtesting**: [Backtesting Guide](BACKTESTING_README.md)
- **Deployment**: [Guides](guides/) → [Testnet Launch](guides/TESTNET_LAUNCH_GUIDE.md)
- **Monitoring**: [Infrastructure](infrastructure/) → [Monitoring](infrastructure/monitoring-grafana-testnet.md)

### By File Type
- **Configuration**: Look in service directories for `application.yml` files
- **Docker**: `docker-compose*.yml` files in root and infrastructure
- **Scripts**: [Scripts Directory](scripts/)
- **Tests**: `src/test/` directories in each service

## 📝 Contributing to Documentation

When adding new documentation:
1. Place files in the appropriate directory
2. Update this README with links
3. Follow the existing naming conventions
4. Include clear descriptions and examples

## 🆘 Getting Help

- **Technical Issues**: Check service-specific documentation
- **Deployment Problems**: Review [Infrastructure](infrastructure/) guides
- **Strategy Questions**: See [Backtesting](BACKTESTING_README.md) documentation
- **General Questions**: Start with [System Overview](overview.md)

---

**Last Updated**: 2025-01-05  
**Maintained By**: Development Team  
**Version**: 2.0 (Consolidated)