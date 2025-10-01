# Binance AI Traders - Backtesting Engine

## Overview

The backtesting engine is a comprehensive system designed to test trading strategies on historical data from Binance. It simulates real trading conditions and provides detailed performance metrics to evaluate strategy profitability and risk.

## Architecture

### Core Components

1. **MACDSignalAnalyzer** - Analyzes kline data to generate MACD-based trading signals
2. **BinanceHistoricalDataFetcher** - Fetches real historical data from Binance API
3. **BacktestTraderEngine** - Simulates trading execution based on signals
4. **BacktestOrderService** - Manages order placement and tracking
5. **BacktestMetricsCalculator** - Calculates comprehensive performance metrics
6. **ComprehensiveBacktestService** - Orchestrates the entire backtesting process

### Data Models

- **KlineEvent** - Represents a single kline/candlestick data point
- **BacktestDataset** - Collection of kline samples for backtesting
- **BacktestResult** - Contains results of a single backtest run
- **BacktestAnalysis** - Collection of multiple backtest results
- **BacktestMetrics** - Comprehensive performance metrics

## Features

### 1. Real Data Integration
- Fetches historical kline data directly from Binance API
- Supports multiple symbols and time intervals
- Handles API rate limiting and error recovery

### 2. MACD Signal Analysis
- Calculates Exponential Moving Averages (EMA)
- Computes MACD line and signal line
- Generates BUY/SELL signals based on crossovers
- Configurable parameters (fast EMA, slow EMA, signal period)

### 3. Trade Simulation
- Simulates realistic trading execution
- Tracks position sizes and portfolio value
- Implements stop-loss and take-profit logic
- Handles order management and position tracking

### 4. Comprehensive Metrics
- **Profitability Metrics**: Net profit, profit percentage, profit factor
- **Risk Metrics**: Maximum drawdown, Sharpe ratio, Sortino ratio
- **Trade Analysis**: Win rate, average win/loss, consecutive wins/losses
- **Time Analysis**: Average trade duration, trading frequency
- **Market Analysis**: Strategy vs market performance, recovery factor
- **Advanced Metrics**: Kelly percentage, expectancy, Calmar ratio

## Usage

### Quick Start

```java
// Run the standalone demo
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

### Basic Backtesting

```java
// 1. Initialize components
MACDSignalAnalyzer signalAnalyzer = new MACDSignalAnalyzer();
BacktestOrderService orderService = new BacktestOrderService();
BacktestTraderEngine traderEngine = new BacktestTraderEngine(
    signalAnalyzer, orderService, traderConfig);

// 2. Create or load dataset
List<KlineEvent> klines = createSyntheticData(); // or fetch from Binance

// 3. Run backtest
BacktestResult result = traderEngine.runBacktest(klines, initialCapital);

// 4. Analyze results
System.out.println("Net Profit: " + result.getMetrics().getNetProfit());
System.out.println("Win Rate: " + result.getMetrics().getWinRate());
```

### Using Real Binance Data

```java
// Fetch historical data
BinanceHistoricalDataFetcher dataFetcher = new BinanceHistoricalDataFetcher();
List<KlineEvent> klines = dataFetcher.fetchKlines(
    "BTCUSDT", "1h", startTime, endTime);

// Run comprehensive backtest
ComprehensiveBacktestService backtestService = new ComprehensiveBacktestService();
BacktestResult result = backtestService.runBacktestWithRealData(
    "BTCUSDT", "1h", startTime, endTime, initialCapital);
```

## Configuration

### Trader Configuration

```yaml
binance:
  trader:
    testOrderModeEnabled: true
    stopLossPercentage: 0.98
    takeProfitPercentage: 1.05
    orderQuantity: 0.05
    slidingWindowSize: 78
```

### MACD Parameters

The MACD signal analyzer uses the following default parameters:
- Fast EMA period: 12
- Slow EMA period: 26
- Signal period: 9

## Performance Metrics Explained

### Profitability Metrics
- **Net Profit**: Total profit/loss in USD
- **Net Profit %**: Percentage return on initial capital
- **Profit Factor**: Ratio of gross profit to gross loss
- **Average Win/Loss**: Average profit per winning/losing trade

### Risk Metrics
- **Maximum Drawdown**: Largest peak-to-trough decline
- **Sharpe Ratio**: Risk-adjusted return measure
- **Sortino Ratio**: Downside risk-adjusted return
- **Recovery Factor**: Net profit divided by maximum drawdown

### Trade Analysis
- **Win Rate**: Percentage of profitable trades
- **Total Trades**: Number of trades executed
- **Consecutive Wins/Losses**: Maximum streak of wins/losses
- **Average Trade Duration**: Average time per trade in hours

### Advanced Metrics
- **Kelly Percentage**: Optimal position size based on win rate and odds
- **Expectancy**: Expected value per trade
- **Calmar Ratio**: Annual return divided by maximum drawdown

## Example Output

```
=== BACKTEST RESULTS ===
Symbol: BTCUSDT
Period: 2024-01-01 to 2024-01-31
Initial Capital: $10,000.00
Final Capital: $10,153.65

=== PERFORMANCE METRICS ===
Net Profit: $153.65 (1.54%)
Total Trades: 7
Win Rate: 57.14%
Profit Factor: 1.23
Maximum Drawdown: 2.39%
Sharpe Ratio: 0.45
Sortino Ratio: 0.67

=== TRADE BREAKDOWN ===
Trade 1: BUY $153.65 (1.54%)
Trade 2: SELL $-370.82 (-2.24%)
Trade 3: BUY $108.66 (1.78%)
...
```

## Testing

### Unit Tests
```bash
mvn test -pl binance-trader-macd
```

### Integration Tests
```bash
mvn test -pl binance-trader-macd -Dtest=*Backtest*Test
```

### Standalone Demo
```bash
mvn test -pl binance-trader-macd -Dtest=StandaloneBacktestDemo
```

## File Structure

```
binance-trader-macd/
├── src/main/java/com/oyakov/binance_trader_macd/
│   ├── backtest/
│   │   ├── BinanceHistoricalDataFetcher.java
│   │   ├── ComprehensiveBacktestService.java
│   │   ├── BacktestResult.java
│   │   ├── BacktestAnalysis.java
│   │   ├── BacktestMetrics.java
│   │   └── BacktestMetricsCalculator.java
│   ├── domain/signal/
│   │   └── MACDSignalAnalyzer.java
│   └── backtest/
│       ├── BacktestTraderEngine.java
│       └── BacktestOrderService.java
└── src/test/java/com/oyakov/binance_trader_macd/
    ├── backtest/
    │   ├── ComprehensiveBacktestIntegrationTest.java
    │   └── StandaloneBacktestDemo.java
    └── integration/
        └── MacdBacktestIntegrationTest.java
```

## Dependencies

- Spring Boot 3.x
- Jackson (JSON processing)
- Lombok (code generation)
- JUnit 5 (testing)
- Mockito (mocking)

## API Integration

The backtesting engine integrates with Binance's public API endpoints:
- `GET /api/v3/klines` - Historical kline data
- Rate limiting: 1200 requests per minute
- Data format: OHLCV (Open, High, Low, Close, Volume)

## Best Practices

1. **Data Quality**: Always validate historical data before backtesting
2. **Parameter Tuning**: Test different MACD parameters for optimization
3. **Risk Management**: Set appropriate stop-loss and take-profit levels
4. **Market Conditions**: Test strategies across different market conditions
5. **Transaction Costs**: Consider realistic trading fees in calculations

## Limitations

1. **Slippage**: Does not account for market slippage
2. **Liquidity**: Assumes perfect liquidity for all trades
3. **Market Impact**: Large orders may affect market prices
4. **Data Quality**: Relies on historical data accuracy
5. **Regime Changes**: Past performance doesn't guarantee future results

## Future Enhancements

- [ ] Support for multiple trading strategies (RSI, Bollinger Bands, etc.)
- [ ] Portfolio-level backtesting across multiple assets
- [ ] Monte Carlo simulation for risk analysis
- [ ] Real-time backtesting with live data feeds
- [ ] Advanced visualization and reporting
- [ ] Machine learning integration for signal optimization

## Troubleshooting

### Common Issues

1. **API Rate Limiting**: Implement delays between requests
2. **Data Gaps**: Handle missing or incomplete data gracefully
3. **Memory Usage**: Process large datasets in chunks
4. **Network Issues**: Implement retry logic for API calls

### Debug Mode

Enable debug logging to see detailed signal analysis:
```yaml
logging:
  level:
    com.oyakov.binance_trader_macd: DEBUG
```

## Support

For issues and questions:
1. Check the test cases for usage examples
2. Review the integration tests for common patterns
3. Examine the standalone demo for a complete workflow
4. Refer to the JavaDoc comments in the source code

---

*This backtesting engine is part of the Binance AI Traders project and is designed to support automated trading strategy development and validation.*
