# Parameter Optimization Guide

## Overview

This guide provides detailed methodologies for optimizing trading strategy parameters using data-driven backtesting and statistical analysis. The goal is to find parameter configurations that deliver robust, profitable performance across diverse market conditions.

## Parameter Optimization Principles

### 1. Start Simple
- Begin with default/standard parameters
- Establish baseline performance
- Optimize one parameter at a time initially
- Combine optimizations carefully

### 2. Use Sufficient Data
- Minimum 30 days of historical data
- Test across multiple symbols
- Include diverse market conditions
- Validate with out-of-sample data

### 3. Avoid Overfitting
- Don't optimize on noise
- Use walk-forward validation
- Require statistical significance
- Test on unseen data

### 4. Consider Trade-offs
- Profit vs Risk (drawdown)
- Win rate vs Profit factor
- Trade frequency vs Average win
- Complexity vs Robustness

## MACD Strategy Parameters

### Core Parameters

| Parameter | Description | Standard Value | Optimization Range | Impact |
|-----------|-------------|----------------|-------------------|---------|
| `fastEMA` | Fast EMA period | 12 | 8-16 | Signal sensitivity |
| `slowEMA` | Slow EMA period | 26 | 20-32 | Trend confirmation |
| `signal` | Signal line period | 9 | 7-12 | Signal filtering |
| `stopLoss` | Stop loss percentage | 0.98 (2%) | 0.95-0.99 | Risk per trade |
| `takeProfit` | Take profit percentage | 1.05 (5%) | 1.03-1.10 | Reward per trade |

### Parameter Interdependencies

```
fastEMA + slowEMA → Signal Generation Frequency
    Lower values = More signals (sensitive)
    Higher values = Fewer signals (conservative)

stopLoss + takeProfit → Risk/Reward Ratio
    Wider stops + Higher targets = Swing trading
    Tighter stops + Lower targets = Scalping
```

## Optimization Methodologies

### Method 1: Grid Search

**Description**: Test all combinations within parameter ranges

**Advantages**:
- Comprehensive coverage
- Finds global optimum
- Easy to understand

**Disadvantages**:
- Computationally expensive
- Curse of dimensionality
- Risk of overfitting

**Implementation**:

```java
// Grid search for MACD parameters
ParameterSensitivityAnalyzer analyzer = new ParameterSensitivityAnalyzer();

GridSearchConfig config = GridSearchConfig.builder()
    .parameter("fastEMA", List.of(8, 10, 12, 14, 16))
    .parameter("slowEMA", List.of(20, 23, 26, 29, 32))
    .parameter("signal", List.of(7, 8, 9, 10, 11))
    .metric("sharpeRatio")  // Optimize for Sharpe ratio
    .build();

List<BacktestDataset> datasets = loadDatasets("BTCUSDT", "1h", "30d");

GridSearchResult result = analyzer.gridSearch(config, datasets);

// Best parameters
Map<String, Object> bestParams = result.getBestParameters();
System.out.println("Optimal parameters: " + bestParams);
System.out.println("Expected Sharpe Ratio: " + result.getBestScore());
```

**When to Use**:
- Few parameters (< 3)
- Small search space
- Initial exploration

### Method 2: Random Search

**Description**: Test random combinations within ranges

**Advantages**:
- Faster than grid search
- Better for high-dimensional spaces
- Less prone to overfitting

**Disadvantages**:
- May miss optimal combination
- Needs many iterations
- Non-deterministic

**Implementation**:

```python
# scripts/optimize-strategy-parameters.py
import random
import numpy as np

def random_search(n_iterations=100):
    results = []
    
    for i in range(n_iterations):
        params = {
            'fastEMA': random.randint(8, 16),
            'slowEMA': random.randint(20, 32),
            'signal': random.randint(7, 12),
            'stopLoss': round(random.uniform(0.95, 0.99), 3),
            'takeProfit': round(random.uniform(1.03, 1.10), 3)
        }
        
        # Run backtest
        result = run_backtest(params)
        results.append((params, result.sharpe_ratio))
    
    # Find best
    best = max(results, key=lambda x: x[1])
    return best[0], best[1]

best_params, best_sharpe = random_search(n_iterations=200)
print(f"Best parameters: {best_params}")
print(f"Sharpe Ratio: {best_sharpe}")
```

**When to Use**:
- Many parameters (> 3)
- Large search space
- Limited computation time

### Method 3: Walk-Forward Optimization

**Description**: Optimize on training window, test on validation window, roll forward

**Advantages**:
- Prevents overfitting
- Simulates real trading
- More robust results

**Disadvantages**:
- Computationally intensive
- Requires long history
- Complex to implement

**Implementation**:

```java
WalkForwardValidator validator = new WalkForwardValidator();

WalkForwardConfig config = WalkForwardConfig.builder()
    .trainingWindowDays(60)      // Train on 60 days
    .validationWindowDays(30)    // Test on 30 days
    .stepDays(15)                // Roll forward 15 days
    .optimizationMetric("sharpeRatio")
    .build();

List<KlineEvent> klines = loadKlines("BTCUSDT", "1h", 180); // 180 days

WalkForwardResult result = validator.validate(config, klines);

// Analyze results
System.out.println("In-Sample Sharpe: " + result.getAvgInSampleSharpe());
System.out.println("Out-of-Sample Sharpe: " + result.getAvgOutOfSampleSharpe());
System.out.println("Robustness Score: " + result.getRobustnessScore());
```

**When to Use**:
- Final validation
- Production deployment
- Robustness testing

### Method 4: Bayesian Optimization

**Description**: Use probabilistic model to guide search toward promising regions

**Advantages**:
- Efficient exploration
- Handles noise well
- Fewer iterations needed

**Disadvantages**:
- Complex implementation
- Computationally expensive per iteration
- Requires specialized libraries

**Implementation**: (Python with scikit-optimize)

```python
from skopt import gp_minimize
from skopt.space import Integer, Real

def objective_function(params):
    fastEMA, slowEMA, signal, stopLoss, takeProfit = params
    
    config = {
        'fastEMA': fastEMA,
        'slowEMA': slowEMA,
        'signal': signal,
        'stopLoss': stopLoss,
        'takeProfit': takeProfit
    }
    
    result = run_backtest(config)
    return -result.sharpe_ratio  # Minimize negative Sharpe (maximize Sharpe)

# Define search space
space = [
    Integer(8, 16, name='fastEMA'),
    Integer(20, 32, name='slowEMA'),
    Integer(7, 12, name='signal'),
    Real(0.95, 0.99, name='stopLoss'),
    Real(1.03, 1.10, name='takeProfit')
]

# Run optimization
result = gp_minimize(
    objective_function,
    space,
    n_calls=50,
    random_state=42
)

print(f"Best parameters: {result.x}")
print(f"Best Sharpe Ratio: {-result.fun}")
```

**When to Use**:
- Expensive backtest evaluations
- Continuous parameter spaces
- Advanced optimization needs

## Optimization Workflow

### Step 1: Define Objective Function

Choose what to optimize:

| Metric | Use When | Formula |
|--------|----------|---------|
| Sharpe Ratio | General purpose | `(Return - RiskFreeRate) / Std Dev` |
| Sortino Ratio | Focus on downside risk | `Return / Downside Deviation` |
| Calmar Ratio | Minimize drawdown | `Annual Return / Max Drawdown` |
| Win Rate × Avg Win | High-frequency trading | `Win% × Average Win Size` |
| Custom Composite | Multiple objectives | `w1×Sharpe + w2×WinRate - w3×Drawdown` |

**Example Composite Objective**:
```java
BigDecimal objectiveScore = 
    sharpeRatio.multiply(BigDecimal.valueOf(0.5))
    .add(winRate.multiply(BigDecimal.valueOf(0.3)))
    .subtract(maxDrawdownPercent.multiply(BigDecimal.valueOf(0.2)));
```

### Step 2: Select Dataset(s)

Choose datasets that represent target trading conditions:

```sql
-- Find datasets with desired characteristics
SELECT 
    dataset_name,
    symbol,
    interval,
    AVG(volatility_percent) as avg_volatility,
    COUNT(DISTINCT regime_type) as regime_diversity
FROM market_regime_performance mrp
JOIN backtest_runs br ON mrp.run_id = br.run_id
GROUP BY dataset_name, symbol, interval
HAVING AVG(volatility_percent) BETWEEN 2.0 AND 5.0  -- Moderate volatility
    AND COUNT(DISTINCT regime_type) >= 3            -- Diverse regimes
ORDER BY regime_diversity DESC, avg_volatility;
```

### Step 3: Run Optimization

Execute chosen optimization method:

```powershell
# Using parameter optimization script
python scripts/optimize-strategy-parameters.py `
    --method grid_search `
    --symbol BTCUSDT `
    --interval 1h `
    --time-range 30d `
    --metric sharpe_ratio `
    --output results/optimization-run-001.json
```

### Step 4: Analyze Results

Examine optimization results:

```sql
-- View parameter performance
SELECT 
    parameter_name,
    parameter_value,
    AVG(sharpe_ratio) as avg_sharpe,
    STDDEV(sharpe_ratio) as sharpe_stddev,
    COUNT(*) as test_count
FROM parameter_sensitivity
WHERE run_id IN (
    SELECT run_id FROM backtest_runs 
    WHERE created_at > NOW() - INTERVAL '1 day'
)
GROUP BY parameter_name, parameter_value
ORDER BY parameter_name, avg_sharpe DESC;
```

**Visualization**: Use Grafana Parameter Heatmaps dashboard

### Step 5: Validate Results

Test optimized parameters on unseen data:

```java
// Collect fresh validation data
BacktestDataset validationDataset = dataFetcher.fetchHistoricalData(
    "BTCUSDT", "1h",
    startTime, endTime,
    "validation-dataset"
);

// Test with optimized parameters
BacktestResult validationResult = backtestEngine.run(
    validationDataset,
    optimizedParameters
);

// Compare to baseline
System.out.println("Baseline Sharpe: " + baselineResult.getSharpeRatio());
System.out.println("Optimized Sharpe: " + validationResult.getSharpeRatio());
System.out.println("Improvement: " + calculateImprovement(baseline, optimized));
```

### Step 6: Document & Deploy

Document optimization results and deploy if validated:

```markdown
## Optimization Run: 2025-01-18

### Hypothesis
Test if faster EMAs improve performance in recent market conditions

### Method
Grid search over fastEMA [8-16], slowEMA [20-32]
Dataset: BTCUSDT 1h 30d (720 klines)
Metric: Sharpe Ratio

### Results
Best Parameters:
- fastEMA: 10 (was 12)
- slowEMA: 24 (was 26)
- signal: 9 (unchanged)

Performance Improvement:
- Sharpe Ratio: 1.15 → 1.32 (+14.8%)
- Win Rate: 56% → 61% (+5 points)
- Max Drawdown: 12.5% → 11.2% (-1.3 points)

### Validation
Out-of-sample test (7d fresh data):
- Sharpe Ratio: 1.28 (vs 1.32 in-sample) ✅
- Robustness confirmed

### Decision
✅ APPROVED for testnet deployment
Deploy Date: 2025-01-20
Monitoring Period: 7 days
```

## Advanced Optimization Techniques

### Multi-Objective Optimization

Optimize for multiple goals simultaneously:

```python
from pymoo.algorithms.moo.nsga2 import NSGA2
from pymoo.optimize import minimize

class TradingProblem(Problem):
    def _evaluate(self, x, out, *args, **kwargs):
        # x contains parameter values
        result = run_backtest(x)
        
        # Objectives to MINIMIZE (negate for maximize)
        out["F"] = [
            -result.sharpe_ratio,      # Maximize Sharpe
            result.max_drawdown,       # Minimize drawdown
            -result.win_rate           # Maximize win rate
        ]

algorithm = NSGA2(pop_size=100)
result = minimize(
    TradingProblem(),
    algorithm,
    termination=('n_gen', 50),
    verbose=True
)

# Get Pareto optimal solutions
pareto_front = result.F
```

### Adaptive Parameter Selection

Change parameters based on market regime:

```java
public Map<String, Object> getAdaptiveParameters(MarketRegime regime) {
    return switch (regime) {
        case BULL_TRENDING -> Map.of(
            "fastEMA", 10,        // Faster in trends
            "slowEMA", 24,
            "stopLoss", 0.97,     // Wider stops
            "takeProfit", 1.06    // Higher targets
        );
        case BEAR_TRENDING -> Map.of(
            "fastEMA", 10,
            "slowEMA", 24,
            "stopLoss", 0.98,     // Tighter stops
            "takeProfit", 1.04
        );
        case RANGING -> Map.of(
            "fastEMA", 14,        // Slower in range
            "slowEMA", 28,
            "stopLoss", 0.985,    // Very tight stops
            "takeProfit", 1.03    // Quick profits
        );
        case VOLATILE -> Map.of(
            "fastEMA", 12,
            "slowEMA", 26,
            "stopLoss", 0.96,     // Wider for volatility
            "takeProfit", 1.08
        );
        default -> getDefaultParameters();
    };
}
```

### Portfolio-Level Optimization

Optimize across multiple symbols:

```sql
-- Find parameter set that works best across all symbols
SELECT 
    parameters,
    AVG(net_profit_percent) as avg_profit,
    MIN(net_profit_percent) as worst_profit,
    STDDEV(net_profit_percent) as profit_stddev,
    COUNT(DISTINCT symbol) as symbols_tested
FROM backtest_runs
WHERE strategy_name = 'MACD'
    AND created_at > NOW() - INTERVAL '7 days'
GROUP BY parameters
HAVING COUNT(DISTINCT symbol) >= 5
ORDER BY avg_profit DESC, profit_stddev ASC
LIMIT 10;
```

## Common Optimization Pitfalls

### Pitfall 1: Overfitting to Noise

**Problem**: Parameters optimized on random fluctuations  
**Solution**: Use walk-forward validation, require statistical significance  
**Check**: Out-of-sample performance >> in-sample - 20%

### Pitfall 2: Insufficient Data

**Problem**: Optimization on too few trades or short period  
**Solution**: Minimum 50 trades, 30 days, multiple market conditions  
**Check**: `SELECT COUNT(*) FROM trades WHERE ...` >= 50

### Pitfall 3: Parameter Correlation Ignored

**Problem**: Optimizing correlated parameters independently  
**Solution**: Understand relationships, optimize jointly  
**Example**: fastEMA and slowEMA should maintain minimum gap (e.g., slowEMA >= fastEMA + 10)

### Pitfall 4: Ignoring Transaction Costs

**Problem**: Optimal on paper, unprofitable with fees  
**Solution**: Include realistic fees in backtest (0.1% per trade)  
**Check**: Profit with fees > Profit without fees * 0.8

### Pitfall 5: Single Metric Optimization

**Problem**: Optimizing Sharpe ignores drawdown  
**Solution**: Use composite objective or multi-objective optimization  
**Check**: Monitor multiple metrics, set constraints

## Monitoring Optimized Strategies

### Performance Tracking

```sql
-- Compare optimized strategy to baseline
CREATE VIEW v_strategy_comparison AS
SELECT 
    'Baseline' as version,
    AVG(net_profit_percent) as avg_profit,
    AVG(sharpe_ratio) as avg_sharpe,
    AVG(max_drawdown_percent) as avg_drawdown
FROM backtest_runs
WHERE strategy_name = 'MACD'
    AND parameters->>'fastEMA' = '12'  -- Baseline
    
UNION ALL

SELECT 
    'Optimized' as version,
    AVG(net_profit_percent) as avg_profit,
    AVG(sharpe_ratio) as avg_sharpe,
    AVG(max_drawdown_percent) as avg_drawdown
FROM backtest_runs
WHERE strategy_name = 'MACD'
    AND parameters->>'fastEMA' = '10';  -- Optimized
```

### Regression Detection

Alert if performance degrades:

```sql
-- Check if recent performance is worse than expected
SELECT 
    symbol,
    interval,
    AVG(net_profit_percent) as recent_profit,
    (SELECT AVG(net_profit_percent) 
     FROM backtest_runs br2
     WHERE br2.symbol = br.symbol
       AND br2.interval = br.interval
       AND br2.created_at BETWEEN NOW() - INTERVAL '30 days' 
                              AND NOW() - INTERVAL '7 days'
    ) as historical_profit
FROM backtest_runs br
WHERE strategy_name = 'MACD'
    AND created_at > NOW() - INTERVAL '7 days'
GROUP BY symbol, interval
HAVING AVG(net_profit_percent) < historical_profit * 0.7  -- 30% degradation
;
```

## Tools & Resources

### Optimization Scripts
- `scripts/optimize-strategy-parameters.py` - Main optimization script
- `scripts/validate-optimization-results.ps1` - Validation utility
- `scripts/generate-parameter-heatmap.py` - Visualization

### SQL Queries
- `queries/parameter-performance.sql` - Parameter analysis
- `queries/walk-forward-validation.sql` - Robustness checks
- `queries/regime-specific-parameters.sql` - Adaptive parameters

### Dashboards
- Grafana > Backtesting Research > Parameter Heatmaps
- Grafana > Backtesting Research > Optimization Results

## Conclusion

Effective parameter optimization is a balance between:
- **Thoroughness**: Test comprehensively
- **Rigor**: Validate statistically
- **Pragmatism**: Keep it simple
- **Caution**: Avoid overfitting

Remember: **The best parameters are those that work well across diverse conditions, not just on historical data.**

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-18  
**Next Review**: 2025-02-18

