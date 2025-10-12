# Binance Trader Grid - Scaffold

This module currently contains code copied from the data-storage service. The goal of this scaffold is to introduce clean, self-contained grid-trading domain classes without changing the current runtime wiring. No beans are auto-registered and no application properties are consumed yet.

What is included now:
- Pure Java domain model for grid strategy configuration and levels
- Strategy planning and risk interfaces with a simple reference implementation
- Example YAML (commented) to show the intended config format

What is NOT included yet:
- Spring wiring, REST/Kafka integration, or trade execution
- Database persistence

## Next Steps (implementation plan)
1. Add Spring configuration and REST API for grid strategies (behind a feature flag)
2. Connect to market data (Kafka/WS) and order execution (Binance client)
3. Persist strategy state and executed orders in PostgreSQL
4. Add risk/throttle limits and backtest harness

## Example config (for documentation only)
```yaml
# src/main/resources/grid/grid-strategies.yml (example only - not loaded)
strategies:
  - id: btc-5m-grid
    symbol: BTCUSDT
    interval: 5m
    priceRange:
      lower: 95000
      upper: 115000
    levels: 20
    baseOrderSize: 0.001   # in base asset
    quoteAllocation: 2000  # in USDT
    rebalanceThresholdPct: 0.8
    takeProfitPct: 0.9
    stopLossPct: 3.0
    risk:
      dailyLossLimitPct: 5.0
      maxPositionSizeQuote: 2500
```

This file is provided as a reference for the UI and storage/APIs. It is intentionally not imported by Spring to avoid side effects until the full implementation lands.
