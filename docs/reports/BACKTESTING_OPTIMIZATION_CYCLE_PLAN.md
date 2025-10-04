# Backtesting Optimization Cycle Plan

## 1. Baseline Context
- **Current engine status**: Comprehensive metrics, modular architecture, and real data integration are already available, but MACD profitability remains inconsistent across tests.【F:BACKTESTING_EVALUATION_REPORT.md†L1-L67】
- **Recent comprehensive study**: 120 MACD backtests highlight strong results for ETHUSDT on 4h data (e.g., MACD(7,14,7) delivered 193.49% profit) while BTCUSDT and the 1d timeframe underperformed.【F:COMPREHENSIVE_ANALYSIS_RESULTS.md†L1-L118】
- **Existing roadmap**: Additional indicators like RSI and Bollinger Bands are already identified as planned enhancements, confirming architectural readiness for multi-strategy evaluations.【F:BACKTESTING_README.md†L45-L78】

## 2. Expanded Data Scope
1. **Symbols**
   - Extend beyond BTC, ETH, and ADA to include BNB, SOL, XRP, MATIC, and LTC to cover diverse volatility regimes.
   - Use market-cap tiers (large, mid, emerging) to understand robustness across liquidity bands.
2. **Timeframes**
   - Complement existing 1h/4h/1d data with 15m (scalping), 2h/6h (mid), and 1w (macro) windows.
   - Perform walk-forward validation on overlapping windows (e.g., rolling 90d slices) to detect regime sensitivity.
3. **Historical Lengths**
   - Standardize backtests on 90d, 180d, 365d, and multi-year (720d) segments.
   - Tag datasets by market regime (bull/bear/sideways/high volatility) using realized volatility and trend filters for scenario-specific reporting.
4. **Data Quality Enhancements**
   - Enforce OHLCV integrity checks and outlier detection prior to runs.
   - Cache fetched klines per symbol/interval to accelerate combinatorial testing.

## 3. Optimization & Evaluation Workflow
1. **Parameter Search**
   - Start with systematic grids for each indicator, then transition to Bayesian optimization to shrink the search space.
   - Use nested evaluation: coarse global scan → refined local search around top performers → stress tests under alternative fee/slippage assumptions.
2. **Validation Cycle**
   - Adopt walk-forward analysis: train (optimize) on historical block A, validate on block B, roll forward.
   - Require strategies to beat buy-and-hold and maintain Sharpe > 0.5 and Sortino > 0.7 in validation before promotion.
3. **Risk-Aware Scoring**
   - Score each configuration with a composite metric weighting profit, drawdown, Sharpe/Sortino, win rate, and trade frequency.
   - Reject configurations with drawdown > 25% or profit factor < 1.2 irrespective of raw returns.
4. **Reporting**
   - Generate comparative dashboards summarizing top performers per symbol/timeframe and flagging unstable parameter sets.
   - Maintain a strategy registry documenting dataset ranges, optimal parameters, and live readiness status.

## 4. Additional Algorithms for Comparative Analysis
1. **RSI (Relative Strength Index)**
   - Use threshold-based entries (e.g., 30/70, with dynamic bands) and combine with confirmation filters (trend MA, volume spikes).
   - Optimize lookback periods (7–21) and exit rules; evaluate overbought/oversold whipsaw risk versus MACD.
2. **Bollinger Band Mean Reversion**
   - Deploy standard deviation envelopes around an SMA, testing pullback and breakout variations.
   - Optimize band width (1.5–3.0σ) and signal confirmation (volume, RSI); evaluate performance in range-bound markets.
3. **Stochastic Oscillator**
   - Implement %K/%D crossovers with smoothing; tune lookbacks (14, 21) and thresholds (20/80).
   - Compare responsiveness versus MACD, particularly on shorter timeframes.
4. **ATR-Driven Trend Following**
   - Combine longer-term EMA trend filters with ATR-based trailing stops (e.g., Chandelier Exit) for volatility-adjusted trend capture.
   - Evaluate risk-adjusted returns relative to MACD, especially during strong trends.
5. **Volume-Weighted Moving Average Cross (VWMA)**
   - Replace standard EMA inputs with VWMA pairs to incorporate liquidity into trend detection.
   - Assess whether volume weighting reduces false positives on thinly traded assets.
6. **Hybrid Ensemble**
   - Explore signal voting (MACD + RSI confirmation) and weighted scoring ensembles; require concordance before trade execution.
   - Measure ensemble stability compared to single-indicator systems.

## 5. Comparative Experiment Matrix
| Dimension | Values |
|-----------|--------|
| Symbols | BTC, ETH, ADA, BNB, SOL, XRP, MATIC, LTC |
| Timeframes | 15m, 1h, 2h, 4h, 6h, 1d, 1w |
| Periods | 90d, 180d, 365d, 720d |
| Strategies | MACD (baseline), RSI, Bollinger, Stochastic, ATR-trend, VWMA cross, Ensembles |
| Fees/Slippage | Binance spot (0.1%), maker/taker tiers, high-slippage stress (0.3%) |

Run all combinations where data suffices, prioritizing:
1. ETH/BNB/SOL @ 4h & 1h (continuity with prior success cases)
2. BTC/ETH multi-year 1d & 1w for macro regimes
3. High-volatility assets (SOL, MATIC) on 15m/1h for intraday strategies

## 6. Deliverables & Timeline
1. **Week 1**: Expand data ingestion scripts, implement caching, assemble datasets for new symbols/timeframes.
2. **Week 2**: Integrate RSI, Bollinger, and Stochastic strategies; set up shared optimization scaffolding.
3. **Week 3**: Run full experiment matrix for MACD + new indicators on 90–365d ranges; produce comparative dashboards.
4. **Week 4**: Add ATR-trend, VWMA cross, and ensemble logic; execute walk-forward validations and finalize ranking report.
5. **Week 5**: Consolidate results into strategy registry, document deployment recommendations, and schedule live-paper trading pilots.

## 7. Success Criteria
- Multi-strategy backtesting coverage spanning ≥ 8 symbols × 7 timeframes × 4 periods.
- Each strategy documented with optimal parameters, validation metrics, and risk flags.
- Identification of at least three non-MACD strategies whose Sharpe and Sortino meet or exceed MACD’s best validated results on ETHUSDT 4h datasets.
- Automated reporting pipeline producing side-by-side comparisons after each optimization cycle.

## 8. Future Extensions
- Introduce machine learning classifiers (e.g., gradient boosted trees on engineered features) once indicator suite is benchmarked.
- Incorporate regime detection to dynamically switch between trend-following and mean-reversion strategies.
- Explore reinforcement learning agents for adaptive position sizing once robust baselines are established.
