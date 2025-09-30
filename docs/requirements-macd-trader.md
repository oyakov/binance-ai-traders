# MACD Trader Service Requirements

## Functional Scope
- Consume Binance kline events and maintain a sliding processing window sized by configuration (`binance.trader.slidingWindowSize`).
- Derive MACD-based trade signals (BUY/SELL) using 12/26-period EMAs and a 9-period signal line computed with precision scale 10.
- When the sliding window lacks sufficient klines (`< 35`), skip trading decisions.
- On each full window:
  - Request a trade signal from `MACDSignalAnalyzer`.
  - If a signal is produced, execute trade-side handling (currently logging and future order orchestration).
  - If no signal, treat the kline as an update and inspect active orders for SL/TP handling.
- Manage Binance order lifecycle via `OrderServiceImpl`, which must:
  - Reject new order groups when an active order already exists for a symbol.
  - Place a primary LIMIT order plus OCO stop-loss/take-profit contingent orders.
  - Persist order metadata to PostgreSQL/Elasticsearch via `OrderPostgresRepository`.
  - Close orders by cancelling them on Binance and updating stored state.

## Non-Functional Requirements
- Guard `TraderServiceImpl` sliding window with locking to avoid concurrent mutation.
- Use Spring-managed configuration properties for REST/websocket endpoints and trader thresholds.
- Ensure repository methods are transactional and use pessimistic locks where needed.
- Converter logic must translate Binance API responses into internal `OrderItem` records using enum mappings.

## External Dependencies
- Relies on Binance REST API via `BinanceOrderClient` using API key/secret signing.
- Uses Kafka Avro `KlineEvent` schema from `binance-shared-model` for market data interchange.
- Persists and queries orders through Spring Data JPA/Elasticsearch repositories.
