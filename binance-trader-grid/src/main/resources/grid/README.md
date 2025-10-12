This folder documents the intended grid strategy configuration. Files here are not loaded yet.

Example (grid-strategies.yml):

```
strategies:
  - id: btc-5m-grid
    symbol: BTCUSDT
    interval: 5m
    priceRange:
      lower: 95000
      upper: 115000
    levels: 20
    baseOrderSize: 0.001
    quoteAllocation: 2000
    rebalanceThresholdPct: 0.8
    takeProfitPct: 0.9
    stopLossPct: 3.0
    risk:
      dailyLossLimitPct: 5.0
      maxPositionSizeQuote: 2500
```
