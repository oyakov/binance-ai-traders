# Strategy Research Framework

## Overview

This framework provides a systematic approach to trading strategy research, leveraging the comprehensive testability and observability infrastructure to enable data-driven strategy optimization and continuous improvement.

## Research Philosophy

### Core Principles

1. **Data-Driven**: All decisions based on empirical evidence from backtesting
2. **Systematic**: Reproducible processes with versioned datasets
3. **Comprehensive**: Test across multiple market conditions and timeframes
4. **Iterative**: Continuous feedback loop drives improvement
5. **Robust**: Validate strategies across diverse scenarios

### The Feedback Loop

```
HYPOTHESIS → BACKTEST → ANALYZE → INSIGHTS → OPTIMIZATION → VALIDATION → DEPLOYMENT
     ↑                                                                          ↓
     └──────────────────────── MONITOR & LEARN ──────────────────────────────┘
```

## Research Workflow

### Phase 1: Hypothesis Formation

**Objective**: Define what you want to test

**Activities**:
1. Identify strategy concept or parameter to optimize
2. Define success criteria (Sharpe ratio, win rate, drawdown)
3. Specify test scope (symbols, intervals, time ranges)
4. Document hypothesis clearly

**Example Hypotheses**:
- "MACD with faster EMAs (8/20) will outperform standard (12/26) in volatile markets"
- "Tighter stop-loss (0.985) will reduce drawdown without significantly impacting returns"
- "Strategy performs better in bull trending markets vs ranging markets"

### Phase 2: Dataset Preparation

**Objective**: Ensure high-quality, comprehensive test data

**Activities**:
1. Collect datasets for target scope
2. Validate dataset integrity
3. Verify market condition diversity
4. Document dataset characteristics

**Commands**:
```powershell
# Collect datasets
.\scripts\collect-backtest-datasets.ps1 -Symbol BTCUSDT -Interval 1h

# Validate datasets
.\scripts\validate-datasets.ps1 -CheckGaps -CheckAnomalies
```

**Dataset Selection Guidelines**:
| Research Goal | Recommended Datasets |
|--------------|---------------------|
| Quick iteration | 7d datasets (5 symbols × 5 intervals = 25 tests) |
| Comprehensive testing | 30d datasets (25 tests) |
| Robustness validation | 90d + 180d datasets (50 tests) |
| Production readiness | All datasets (100 tests) |

### Phase 3: Backtesting Execution

**Objective**: Run comprehensive backtests across datasets

**Activities**:
1. Configure strategy parameters
2. Execute multi-dataset backtest runs
3. Persist results to database
4. Monitor execution for errors

**Execution Methods**:

#### Method 1: Java Multi-Dataset Runner
```java
MultiDatasetBacktestRunner runner = new MultiDatasetBacktestRunner(
    backtestEngine,
    datasetLoader,
    resultsRepository
);

BacktestExecutionConfig config = BacktestExecutionConfig.builder()
    .symbols(List.of("BTCUSDT", "ETHUSDT"))
    .intervals(List.of("1h", "4h"))
    .timeRanges(List.of("30d", "90d"))
    .strategyName("MACD")
    .parameters(Map.of("fastEMA", 12, "slowEMA", 26, "signal", 9))
    .build();

List<BacktestResult> results = runner.execute(config);
```

#### Method 2: REST API (via Postman)
```http
POST /api/v1/backtest/run-multi
{
  "symbols": ["BTCUSDT", "ETHUSDT"],
  "intervals": ["1h", "4h"],
  "timeRanges": ["30d", "90d"],
  "strategy": "MACD",
  "parameters": {
    "fastEMA": 12,
    "slowEMA": 26,
    "signal": 9,
    "stopLoss": 0.98,
    "takeProfit": 1.05
  }
}
```

#### Method 3: Automated Test Pipeline
```bash
# Docker-based automated testing
./tests/docker-test-runner.sh --backtest-suite --strategy MACD
```

### Phase 4: Results Analysis

**Objective**: Extract insights from backtest data

**Activities**:
1. Query backtest results from database
2. Visualize performance in Grafana
3. Identify patterns and correlations
4. Compare to baseline/previous iterations

**Analysis Queries**:

#### Overall Performance Summary
```sql
SELECT 
    symbol,
    interval,
    AVG(net_profit_percent) as avg_profit,
    AVG(win_rate) as avg_win_rate,
    AVG(sharpe_ratio) as avg_sharpe,
    AVG(max_drawdown_percent) as avg_drawdown,
    COUNT(*) as test_count
FROM v_backtest_metrics_summary
WHERE strategy_name = 'MACD'
    AND created_at > NOW() - INTERVAL '7 days'
GROUP BY symbol, interval
ORDER BY avg_sharpe DESC;
```

#### Parameter Performance Comparison
```sql
SELECT 
    parameter_name,
    parameter_value,
    AVG(net_profit_percent) as avg_profit,
    AVG(sharpe_ratio) as avg_sharpe,
    COUNT(*) as sample_count
FROM parameter_sensitivity ps
JOIN backtest_runs br ON ps.run_id = br.run_id
WHERE br.strategy_name = 'MACD'
    AND br.symbol = 'BTCUSDT'
    AND br.interval = '1h'
GROUP BY parameter_name, parameter_value
HAVING COUNT(*) >= 3
ORDER BY parameter_name, avg_sharpe DESC;
```

#### Regime Performance Analysis
```sql
SELECT 
    regime_type,
    COUNT(*) as occurrence_count,
    AVG(net_profit_percent) as avg_profit,
    AVG(win_rate) as avg_win_rate,
    SUM(trades_count) as total_trades
FROM market_regime_performance mrp
JOIN backtest_runs br ON mrp.run_id = br.run_id
WHERE br.strategy_name = 'MACD'
    AND br.symbol = 'BTCUSDT'
GROUP BY regime_type
ORDER BY avg_profit DESC;
```

**Grafana Dashboards**:
- **Strategy Performance Matrix**: Compare across symbols/intervals
- **Parameter Heatmaps**: Visualize parameter sensitivity
- **Market Regime Analysis**: Performance by market condition
- **Walk-Forward Validation**: In-sample vs out-of-sample

### Phase 5: Insight Generation

**Objective**: Transform data into actionable insights

**Key Questions**:
1. Which parameters perform best across datasets?
2. Are there consistent patterns in winning/losing configurations?
3. Does performance vary by market regime?
4. Is the strategy overfitting to specific conditions?
5. What are the risk characteristics (drawdown, volatility)?

**Insight Templates**:

#### Parameter Optimization Insight
```
Finding: fastEMA=10 outperforms fastEMA=12 by 15% in Sharpe ratio
Evidence: Tested across 25 datasets (5 symbols × 5 intervals)
Context: Improvement consistent in bull trending markets (avg Sharpe 1.2 vs 1.0)
Risk: Slightly higher drawdown in ranging markets (12% vs 10%)
Recommendation: Use fastEMA=10 with regime detection to avoid ranging markets
```

#### Market Regime Insight
```
Finding: Strategy fails in ranging markets (35% win rate vs 58% overall)
Evidence: Analyzed 50 regime periods across 20 backtests
Context: MACD generates false signals in low-volatility sideways markets
Impact: Ranging markets represent 30% of test period but account for 60% of losses
Recommendation: Implement regime detection to pause trading during ranging conditions
```

#### Robustness Insight
```
Finding: Strategy shows consistent performance across time periods
Evidence: Walk-forward validation: in-sample Sharpe 1.1, out-of-sample Sharpe 1.05
Context: 90d and 180d datasets show similar metrics to 30d datasets
Risk: Slight degradation in very recent data (last 7 days)
Recommendation: Strategy is robust; proceed to testnet validation
```

### Phase 6: Optimization

**Objective**: Implement improvements based on insights

**Optimization Strategies**:

#### 1. Parameter Tuning
```java
// Before optimization
MACDConfig baseline = MACDConfig.builder()
    .fastEMA(12)
    .slowEMA(26)
    .signal(9)
    .build();

// After optimization (based on parameter sensitivity analysis)
MACDConfig optimized = MACDConfig.builder()
    .fastEMA(10)        // Improved from 12
    .slowEMA(24)        // Improved from 26
    .signal(8)          // Improved from 9
    .build();
```

#### 2. Risk Management Enhancement
```java
// Dynamic stop-loss based on market regime
BigDecimal stopLoss = switch (currentRegime) {
    case BULL_TRENDING -> new BigDecimal("0.97");   // Wider stops in trending
    case BEAR_TRENDING -> new BigDecimal("0.98");   // Tighter stops in bear
    case RANGING -> new BigDecimal("0.985");        // Very tight in ranging
    case VOLATILE -> new BigDecimal("0.975");       // Wider for volatility
    default -> new BigDecimal("0.98");
};
```

#### 3. Regime-Specific Logic
```java
// Pause trading in unfavorable regimes
boolean shouldTrade = switch (currentRegime) {
    case BULL_TRENDING -> true;      // Trade in bull trends
    case BEAR_TRENDING -> true;      // Trade in bear trends (short signals)
    case RANGING -> false;           // Skip ranging markets
    case VOLATILE -> true;           // Trade volatility with wider stops
    default -> true;
};

if (!shouldTrade) {
    log.info("Skipping trade signal - unfavorable regime: {}", currentRegime);
    return;
}
```

### Phase 7: Validation

**Objective**: Verify improvements before production deployment

**Validation Steps**:

1. **Out-of-Sample Testing**
   ```powershell
   # Collect fresh data not used in optimization
   .\scripts\collect-backtest-datasets.ps1 -TimeRange 7d -Force
   
   # Run backtests on new data
   # Compare results to optimization phase
   ```

2. **Cross-Validation**
   - Test on symbols not used in optimization
   - Test on different time periods
   - Verify consistency across market conditions

3. **Stress Testing**
   - Test during extreme market events
   - Verify risk management in high volatility
   - Confirm drawdown limits are respected

4. **Performance Comparison**
   ```sql
   -- Compare optimized vs baseline
   SELECT 
       CASE WHEN parameters->>'fastEMA' = '10' THEN 'Optimized' ELSE 'Baseline' END as version,
       AVG(net_profit_percent) as avg_profit,
       AVG(sharpe_ratio) as avg_sharpe,
       AVG(max_drawdown_percent) as avg_drawdown
   FROM v_backtest_metrics_summary
   WHERE strategy_name = 'MACD'
       AND created_at > NOW() - INTERVAL '7 days'
   GROUP BY version;
   ```

**Validation Criteria**:
- ✅ Out-of-sample Sharpe ratio > baseline Sharpe ratio
- ✅ Robustness score > 0.7 (consistent across datasets)
- ✅ No regime shows win rate < 35%
- ✅ Max drawdown < 15%
- ✅ Performance improvement statistically significant (p < 0.05)

### Phase 8: Deployment & Monitoring

**Objective**: Deploy to testnet and monitor real-world performance

**Deployment Process**:
1. Update strategy configuration with optimized parameters
2. Deploy to testnet environment
3. Enable observability (logs, metrics, alerts)
4. Start with small position sizes
5. Monitor closely for first 48 hours

**Monitoring Checklist**:
- [ ] Real-time metrics match backtest expectations
- [ ] No unexpected errors or exceptions
- [ ] Order execution functioning correctly
- [ ] Risk management limits respected
- [ ] Regime detection working as expected
- [ ] Performance tracking dashboard active

**Comparison: Backtest vs Live**
```sql
-- Compare testnet performance to backtest predictions
SELECT 
    'Backtest' as source,
    AVG(net_profit_percent) as avg_profit,
    AVG(win_rate) as win_rate,
    AVG(sharpe_ratio) as sharpe
FROM v_backtest_metrics_summary
WHERE strategy_name = 'MACD'
    AND symbol = 'BTCUSDT'
    AND created_at > NOW() - INTERVAL '30 days'
    
UNION ALL

SELECT 
    'Live' as source,
    AVG(net_profit_percent) as avg_profit,
    AVG(win_rate) as win_rate,
    AVG(sharpe_ratio) as sharpe
FROM portfolio_snapshots
WHERE strategy_name = 'MACD'
    AND symbol = 'BTCUSDT'
    AND snapshot_time > NOW() - INTERVAL '7 days';
```

## Research Best Practices

### 1. Version Control
- Tag strategy configurations with version numbers
- Document all parameter changes
- Keep backtest result snapshots for comparison

### 2. Statistical Rigor
- Use sufficient sample sizes (minimum 20 trades per test)
- Apply statistical significance testing
- Be wary of overfitting to historical data

### 3. Documentation
- Document hypothesis before testing
- Record all test configurations
- Note unexpected findings
- Maintain research journal

### 4. Collaboration
- Share insights with team
- Review findings with domain experts
- Cross-validate results with peers

### 5. Continuous Learning
- Review failed strategies to understand why
- Study successful strategies from other researchers
- Stay updated on market regime changes
- Regularly refresh datasets

## Common Research Patterns

### Pattern 1: Parameter Sweep
Test parameter across range to find optimum:
```java
for (int fastEMA = 8; fastEMA <= 16; fastEMA++) {
    for (int slowEMA = 20; slowEMA <= 30; slowEMA++) {
        runBacktest(fastEMA, slowEMA);
    }
}
```

### Pattern 2: Regime Analysis
Identify best market conditions for strategy:
```sql
-- Find most profitable regimes
SELECT regime_type, AVG(net_profit_percent)
FROM market_regime_performance
GROUP BY regime_type
ORDER BY AVG(net_profit_percent) DESC;
```

### Pattern 3: Walk-Forward Optimization
Avoid overfitting with rolling windows:
1. Train on months 1-3, test on month 4
2. Train on months 2-4, test on month 5
3. Train on months 3-5, test on month 6
... continue rolling

### Pattern 4: Monte Carlo Simulation
Assess robustness with randomized entry points:
- Shuffle historical data
- Run 1000 simulations with random start dates
- Analyze distribution of outcomes

## Troubleshooting Research Issues

### Issue: Inconsistent Results
**Symptoms**: Results vary significantly between runs
**Causes**: Non-deterministic logic, timing dependencies
**Solutions**: Add deterministic seed, verify data consistency

### Issue: Overfitting
**Symptoms**: Great in-sample, poor out-of-sample performance
**Causes**: Too many parameters, optimized on noise
**Solutions**: Simplify strategy, increase validation strictness

### Issue: Poor Performance Across All Datasets
**Symptoms**: Strategy unprofitable in most tests
**Causes**: Fundamental strategy flaw, wrong market conditions
**Solutions**: Re-examine hypothesis, try different markets

## Tools & Scripts

### Research Automation Scripts
- `scripts/collect-backtest-datasets.ps1` - Data collection
- `scripts/validate-datasets.ps1` - Data validation
- `scripts/generate-research-report.ps1` - Automated reporting
- `scripts/optimize-strategy-parameters.py` - Parameter optimization

### Database Views for Research
- `v_backtest_metrics_summary` - Performance overview
- `v_parameter_heatmap` - Parameter sensitivity
- `v_regime_performance_summary` - Regime analysis
- `v_best_parameters` - Top parameter values

### Grafana Dashboards
- Strategy Performance Matrix
- Parameter Heatmaps
- Market Regime Analysis
- Walk-Forward Validation

## Conclusion

This research framework provides a systematic, data-driven approach to trading strategy development. By following these processes and leveraging the comprehensive testability and observability infrastructure, you can:

1. Make evidence-based strategy decisions
2. Avoid common pitfalls like overfitting
3. Develop robust, profitable strategies
4. Continuously improve through feedback loops

Remember: **Good research takes time. Be patient, be thorough, and let the data guide you.**

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-18  
**Next Review**: 2025-02-18

