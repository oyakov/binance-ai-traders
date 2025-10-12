# binance-trader-macd Service Requirements

## Service overview
The MACD trader consumes kline events, evaluates MACD-based trading signals, orchestrates Binance order groups, and persists indicator telemetry for monitoring and analytics. It exposes REST endpoints for MACD calculations and integrates with storage services to archive computed values.

## Functional scope
- **Kline event processing**: `TraderServiceImpl` maintains a sliding window of klines sized by configuration, locks access to prevent concurrent mutation, and either executes trade signals or performs position management when the window is full.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L32-L99】
- **Signal execution**: When `MACDSignalAnalyzer` returns a BUY/SELL signal, the trader enforces single-active-order rules, calculates stop-loss/take-profit thresholds, and delegates order placement to the order service. Non-signal updates trigger MACD recalculation storage and stop-loss/take-profit checks on active positions.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L100-L196】
- **Order lifecycle management**: `OrderServiceImpl` places a main LIMIT order and companion OCO orders (SL/TP), persists all order items to PostgreSQL, checks for active-order conflicts, and cancels orders while updating state when stop conditions are met.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/OrderServiceImpl.java†L18-L121】
- **MACD analytics API**: `MACDController` exposes endpoints to calculate indicators with custom or default parameters, fetch historical MACD values, query multiple symbols at once, retrieve cached indicators, and trigger metric refreshes.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/controller/MACDController.java†L18-L149】
- **Indicator metrics pipeline**: `MACDMetricsService` maintains a cache of MACD indicators across default symbol/interval combinations, publishes them as Prometheus gauges, and persists valid calculations to the storage service for historical reference.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/metrics/MACDMetricsService.java†L21-L139】
- **Configuration binding**: All REST, WebSocket, Kafka, and trader thresholds are injected through `MACDTraderConfig`, enabling environment-specific overrides for testnet versus production usage.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L11-L56】

## Configuration contract
- `binance.trader.slidingWindowSize`, `binance.trader.stopLossPercentage`, `binance.trader.takeProfitPercentage`, and `binance.trader.orderQuantity` determine the window size and risk thresholds enforced by the trader service.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L43-L56】【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L41-L63】
- Kafka consumer properties mirror the data-collection topic configuration (`binance.data.kline.*`) so the trader consumes the same `KlineEvent` stream as storage.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L25-L41】
- REST credentials are required for Binance API access; test-order mode can be toggled via configuration for non-production environments.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L17-L24】【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L43-L54】

## Observability requirements
- Micrometer counters track total/buy/sell signals processed, enabling Grafana dashboards to monitor trading frequency.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L52-L73】
- `MACDMetricsService` publishes gauge series for MACD line, signal line, histogram, price, signal strength, data points, and validity flags for each monitored symbol/interval.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/metrics/MACDMetricsService.java†L43-L107】
- Logging covers every order placement, cancellation attempt, and MACD update, supplying enough context to trace trade decisions across the pipeline.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/OrderServiceImpl.java†L35-L121】【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L70-L195】

## External dependencies
- Binance REST endpoints for order placement/management via `BinanceOrderClient` (not shown here) and WebSocket/REST endpoints for market data, sharing configuration with the data-collection service.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L17-L41】
- PostgreSQL persistence for order state through `OrderPostgresRepository` and downstream storage APIs for MACD persistence via `MacdStorageClient`.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/OrderServiceImpl.java†L20-L121】【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L121-L149】
- `binance-shared-model` Avro schemas for interpreting kline events consumed from Kafka.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L21-L33】

## Known gaps & TODOs
- Strategy execution currently logs successful signal detection but lacks integration with actual Binance WebSocket listeners in this module; ensure Kafka wiring is finalized and unit-tested end-to-end.
- TODOs in `TraderServiceImpl` highlight missing cancellation logic for OCO companion orders when signals invert; implement grouped order closure to avoid orphaned positions.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/service/impl/TraderServiceImpl.java†L170-L188】
- Test-order toggle defaults to true; define environment-specific profiles to prevent accidental real trades in production.【F:binance-trader-macd/src/main/java/com/oyakov/binance_trader_macd/config/MACDTraderConfig.java†L43-L54】
