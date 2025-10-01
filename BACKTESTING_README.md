# Backtesting Engine - Binance AI Traders

## 🚀 Quick Start

The backtesting engine allows you to test trading strategies on historical Binance data to validate profitability before live trading.

### Run the Demo

```bash
# Execute the comprehensive backtesting demo
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

This will:
1. Generate synthetic market data with realistic price movements
2. Apply MACD signal analysis to generate trading signals
3. Simulate trade execution with realistic order management
4. Calculate comprehensive performance metrics
5. Display detailed results including profit/loss, win rate, and risk metrics

## 📊 What You'll See

The demo outputs detailed backtesting results including:

- **Performance Metrics**: Net profit, win rate, profit factor
- **Risk Analysis**: Maximum drawdown, Sharpe ratio, Sortino ratio  
- **Trade Breakdown**: Individual trade results with entry/exit prices
- **Market Analysis**: Strategy performance vs buy-and-hold

## 🏗️ Architecture

The backtesting system consists of several key components:

- **MACDSignalAnalyzer**: Generates BUY/SELL signals based on MACD crossovers
- **BinanceHistoricalDataFetcher**: Fetches real historical data from Binance API
- **BacktestTraderEngine**: Simulates realistic trading execution
- **BacktestMetricsCalculator**: Computes comprehensive performance metrics

## 📈 Supported Strategies

Currently implemented:
- **MACD Strategy**: Moving Average Convergence Divergence signals
- **Configurable Parameters**: Fast EMA, slow EMA, signal period

Planned:
- RSI (Relative Strength Index)
- Bollinger Bands
- Custom indicator combinations

## 🔧 Configuration

The system uses Spring Boot configuration for trader settings:

```yaml
binance:
  trader:
    testOrderModeEnabled: true
    stopLossPercentage: 0.98
    takeProfitPercentage: 1.05
    orderQuantity: 0.05
    slidingWindowSize: 78
```

## 📋 Key Features

### Real Data Integration
- Fetches historical kline data from Binance API
- Supports multiple symbols (BTCUSDT, ETHUSDT, etc.)
- Multiple time intervals (1m, 5m, 15m, 1h, 4h, 1d)

### Comprehensive Metrics
- **Profitability**: Net profit, profit percentage, profit factor
- **Risk Management**: Drawdown analysis, Sharpe/Sortino ratios
- **Trade Analysis**: Win rate, average win/loss, consecutive streaks
- **Advanced**: Kelly percentage, expectancy, Calmar ratio

### Realistic Simulation
- Position sizing and portfolio tracking
- Stop-loss and take-profit logic
- Order management and execution simulation
- Transaction cost considerations

## 🧪 Testing

### Run All Tests
```bash
mvn test -pl binance-trader-macd
```

### Run Specific Tests
```bash
# Integration tests
mvn test -pl binance-trader-macd -Dtest=*Backtest*Test

# Original MACD test
mvn test -pl binance-trader-macd -Dtest=MacdBacktestIntegrationTest
```

## 📁 Project Structure

```
binance-trader-macd/
├── src/main/java/com/oyakov/binance_trader_macd/
│   ├── backtest/                    # Core backtesting components
│   │   ├── BinanceHistoricalDataFetcher.java
│   │   ├── ComprehensiveBacktestService.java
│   │   ├── BacktestResult.java
│   │   ├── BacktestAnalysis.java
│   │   ├── BacktestMetrics.java
│   │   └── BacktestMetricsCalculator.java
│   ├── domain/signal/               # Signal analysis
│   │   └── MACDSignalAnalyzer.java
│   └── backtest/                    # Trading simulation
│       ├── BacktestTraderEngine.java
│       └── BacktestOrderService.java
└── src/test/java/com/oyakov/binance_trader_macd/
    ├── backtest/                    # Backtesting tests
    │   ├── ComprehensiveBacktestIntegrationTest.java
    │   └── StandaloneBacktestDemo.java
    └── integration/                 # Integration tests
        └── MacdBacktestIntegrationTest.java
```

## 🎯 Use Cases

1. **Strategy Validation**: Test new trading strategies before live deployment
2. **Parameter Optimization**: Find optimal MACD parameters for different market conditions
3. **Risk Assessment**: Evaluate strategy performance and risk characteristics
4. **Performance Benchmarking**: Compare different strategies and approaches
5. **Educational**: Learn about algorithmic trading and backtesting concepts

## ⚠️ Important Notes

- **Historical Performance**: Past results don't guarantee future performance
- **Market Conditions**: Test strategies across different market regimes
- **Transaction Costs**: Consider realistic trading fees in your analysis
- **Data Quality**: Ensure historical data accuracy and completeness

## 🔗 Related Documentation

- [Detailed Backtesting Engine Documentation](binance-trader-macd/BACKTESTING_ENGINE.md)
- [MACD Strategy Implementation](binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/domain/signal/MACDSignalAnalyzer.java)
- [Performance Metrics Reference](binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/backtest/BacktestMetrics.java)

## 🚀 Next Steps

1. Run the demo to see the backtesting engine in action
2. Experiment with different MACD parameters
3. Test on different symbols and time periods
4. Integrate with your own trading strategies
5. Extend the system with additional indicators

---

*The backtesting engine is part of the Binance AI Traders project, designed to support automated trading strategy development and validation.*
