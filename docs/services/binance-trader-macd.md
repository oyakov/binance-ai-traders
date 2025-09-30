# Binance MACD Trader Service

**Language**: Java 17, Spring Boot

## Purpose
Implements a MACD-based automated trading strategy that reacts to Kafka-delivered signals and places orders through Binance while persisting order state.

## Current Implementation
- `BinanceMACDTraderApplication` enables both JPA and Elasticsearch repositories, mirroring the storage service’s dual persistence approach.
- `config/MACDTraderConfig` surfaces configuration sections for REST credentials, WebSocket connectivity, Kafka data ingestion, and trader-specific parameters (stop-loss/take-profit thresholds, order sizing, sliding window size, etc.).
- Domain enums model order metadata (`OrderSide`, `OrderType`, `TimeInForce`, `OrderState`, `TradeSignal`).
- Converter classes translate Binance REST responses into internal order models.
- Broker packages (`broker/kafka/consumer` & `broker/kafka/producer`) exist, signalling an intent to consume indicator signals and publish orders, but the concrete consumer/producer implementations are not present in the repository snapshot.
- REST client scaffolding under `rest/client` and DTOs under `rest/dto` suggest an HTTP-based interaction with Binance; implementation details need review to confirm completeness.

## Configuration

The MACD trader pulls REST credentials and runtime switches from environment variables (falling back to sensible defaults for URLs):

| Variable | Description |
| --- | --- |
| `BINANCE_REST_BASE_URL` | Binance REST API endpoint. Defaults to the testnet URL in the test profile and the production URL in the mainnet profile. |
| `BINANCE_API_KEY` | API key injected into the `X-MBX-APIKEY` header for authenticated REST calls. |
| `BINANCE_API_SECRET` | Secret key used to sign Binance REST requests. |
| `BINANCE_TRADER_TEST_ORDER_MODE_ENABLED` | When `true`, the trader submits orders to `/api/v3/order/test` and skips live OCO/cancel calls to support dry-run validation. |

## Missing Pieces & Risks
- Without visible Kafka consumer/producer classes it is unclear how signals enter or orders leave the system.
- Strategy logic (calculating MACD crossovers, managing open positions) is absent; the repository currently provides only configuration and model scaffolding.
- Testing is absent; critical trading logic will require deterministic simulations before live deployment.
- There is overlap with the data-storage module (duplicate Elasticsearch config) that could be factored into shared libraries.

## Recommendations
1. Implement the MACD computation pipeline, preferably consuming indicator streams and encapsulating state in dedicated services.
2. Flesh out Kafka listener and producer components with retry/backoff strategies and idempotency safeguards.
3. Centralize shared infrastructure beans (Elasticsearch, Kafka) to reduce duplication across services.
4. Create integration tests that mock Binance REST endpoints and assert order submission behavior in both test and live modes.
