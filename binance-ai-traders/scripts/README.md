# Scripts Documentation

This directory contains all automation scripts for the Binance AI Traders project, organized by platform and purpose.

Note: PowerShell scripts have moved to the top-level `scripts/` directory. Use `scripts/README.md` for Windows usage.

## 📁 Script Organization

### PowerShell Scripts (Windows)
Located in the root of this directory, these scripts are designed for Windows environments:

#### 🚀 Strategy Management
- **`launch_strategies.ps1`** - Launch multiple trading strategies with different configurations
  ```powershell
  # Launch all strategies
  .\launch_strategies.ps1 -LaunchAll
  
  # Launch specific strategies
  .\launch_strategies.ps1 -LaunchBTC
  .\launch_strategies.ps1 -LaunchETH
  .\launch_strategies.ps1 -LaunchADA
  .\launch_strategies.ps1 -LaunchSOL
  ```

- **`monitor_strategies.ps1`** - Monitor running trading strategies and their performance
  ```powershell
  # Monitor all strategies
  .\monitor_strategies.ps1
  
  # Monitor specific strategy
  .\monitor_strategies.ps1 -Strategy BTC
  ```

#### 🧪 Testnet Operations
- **`monitor_testnet.ps1`** - Monitor testnet deployment and trading activities
  ```powershell
  # Start testnet monitoring
  .\monitor_testnet.ps1
  
  # Monitor with specific interval
  .\monitor_testnet.ps1 -Interval 30
  ```

- **`testnet_long_term_monitor.ps1`** - Long-term testnet monitoring and reporting
  ```powershell
  # Start long-term monitoring
  .\testnet_long_term_monitor.ps1 -Duration 7days
  ```

### Shell Scripts (Linux/macOS)
Located in the root of this directory, these scripts are designed for Unix-like environments:

#### 🐳 Docker Operations
- **`docker-test.sh`** - Run comprehensive Docker-based tests
  ```bash
  # Run all tests
  ./docker-test.sh
  
  # Run specific test suite
  ./docker-test.sh --suite integration
  ```

- **`deploy-testnet.sh`** - Deploy the system to testnet environment
  ```bash
  # Deploy to testnet
  ./deploy-testnet.sh
  
  # Deploy with specific configuration
  ./deploy-testnet.sh --config testnet-prod
  ```

#### 🏥 Health & Performance
- **`health-check-test.sh`** - Comprehensive health checks for all services
  ```bash
  # Run health checks
  ./health-check-test.sh
  
  # Check specific service
  ./health-check-test.sh --service macd-trader
  ```

- **`performance-test.sh`** - Performance testing and benchmarking
  ```bash
  # Run performance tests
  ./performance-test.sh
  
  # Test specific component
  ./performance-test.sh --component backtesting
  ```

- **`run-enhanced-tests.sh`** - Run enhanced test suite with detailed reporting
  ```bash
  # Run enhanced tests
  ./run-enhanced-tests.sh
  
  # Run with specific options
  ./run-enhanced-tests.sh --verbose --coverage
  ```

## 🚀 Quick Start

### Windows Users
1. Open PowerShell as Administrator
2. Navigate to the project root
3. Run: `.\docs\scripts\launch_strategies.ps1 -LaunchAll`

### Linux/macOS Users
1. Make scripts executable: `chmod +x docs/scripts/*.sh`
2. Navigate to the project root
3. Run: `./docs/scripts/docker-test.sh`

## 📋 Script Categories

### 🎯 Strategy Management
- **Purpose**: Launch, monitor, and manage trading strategies
- **Platforms**: PowerShell (Windows), Shell (Linux/macOS)
- **Key Scripts**: `launch_strategies.ps1`, `monitor_strategies.ps1`

### 🧪 Testing & Validation
- **Purpose**: Run tests, validate deployments, check health
- **Platforms**: Shell (Linux/macOS)
- **Key Scripts**: `docker-test.sh`, `health-check-test.sh`, `run-enhanced-tests.sh`

### 🚀 Deployment
- **Purpose**: Deploy applications to different environments
- **Platforms**: Shell (Linux/macOS)
- **Key Scripts**: `deploy-testnet.sh`

### 📊 Monitoring
- **Purpose**: Monitor system performance and trading activities
- **Platforms**: PowerShell (Windows)
- **Key Scripts**: `monitor_testnet.ps1`, `testnet_long_term_monitor.ps1`

### ⚡ Performance
- **Purpose**: Performance testing and benchmarking
- **Platforms**: Shell (Linux/macOS)
- **Key Scripts**: `performance-test.sh`

## 🔧 Configuration

### Environment Variables
Most scripts use environment variables for configuration. Set these in your environment:

```bash
# Testnet Configuration
export BINANCE_TESTNET_API_KEY="your_testnet_api_key"
export BINANCE_TESTNET_SECRET_KEY="your_testnet_secret_key"

# Production Configuration (use with caution)
export BINANCE_MAINNET_API_KEY="your_mainnet_api_key"
export BINANCE_MAINNET_SECRET_KEY="your_mainnet_secret_key"

# Docker Configuration
export DOCKER_COMPOSE_FILE="docker-compose-testnet.yml"
export MONITORING_ENABLED="true"
```

### Script Parameters
Each script supports various parameters. Use `--help` or `-h` to see available options:

```bash
# Get help for any script
./script-name.sh --help
.\script-name.ps1 -Help
```

## 📊 Monitoring & Logging

### Log Locations
- **Testnet Logs**: `testnet_logs/`
- **Docker Logs**: Use `docker-compose logs <service>`
- **Script Logs**: Check console output or redirect to files

### Monitoring Dashboards
- **Grafana**: http://localhost:3001
- **Strategy Overview**: http://localhost:3001/d/strategy-overview-000/strategy-overview
- **BTC Strategy**: http://localhost:3001/d/btc-macd-strategy-001/btc-macd-strategy

## 🛠️ Troubleshooting

### Common Issues

#### PowerShell Execution Policy
```powershell
# If you get execution policy errors
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Permission Denied (Linux/macOS)
```bash
# Make scripts executable
chmod +x docs/scripts/*.sh
```

#### Docker Not Running
```bash
# Start Docker services
docker-compose up -d
```

#### Service Not Ready
```bash
# Check service health
./docs/scripts/health-check-test.sh
```

### Getting Help
1. Check script output for error messages
2. Review logs in `testnet_logs/`
3. Verify environment variables are set
4. Ensure all dependencies are installed

## 📝 Adding New Scripts

When adding new scripts:

1. **Choose the right platform**: PowerShell for Windows, Shell for Linux/macOS
2. **Follow naming conventions**: Use descriptive names with proper extensions
3. **Add help documentation**: Include `--help` parameter
4. **Update this README**: Add script description and usage examples
5. **Test thoroughly**: Verify scripts work in target environments

### Script Template

#### PowerShell Template
```powershell
param(
    [string]$Parameter1,
    [switch]$Flag1,
    [switch]$Help
)

if ($Help) {
    Write-Host "Script Description" -ForegroundColor Green
    Write-Host "Usage: .\script-name.ps1 -Parameter1 value -Flag1" -ForegroundColor Yellow
    exit 0
}

# Script implementation here
```

#### Shell Template
```bash
#!/bin/bash

# Script description
# Usage: ./script-name.sh [options]

set -e  # Exit on error

# Default values
PARAMETER1="default_value"
FLAG1=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --parameter1)
            PARAMETER1="$2"
            shift 2
            ;;
        --flag1)
            FLAG1=true
            shift
            ;;
        --help|-h)
            echo "Script Description"
            echo "Usage: $0 [options]"
            exit 0
            ;;
        *)
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Script implementation here
```

## 🔗 Related Documentation

- [Main Documentation](../README.md)
- [Docker Setup](../infrastructure/docker-compose.md)
- [Monitoring Setup](../infrastructure/monitoring-grafana-testnet.md)
- [Testnet Guide](../guides/TESTNET_LAUNCH_GUIDE.md)

---

**Last Updated**: 2025-01-05  
**Maintained By**: Development Team  
**Version**: 2.0 (Consolidated)
