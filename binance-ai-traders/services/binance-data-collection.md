# Binance Data Collection Service

**Language**: Java 17, Spring Boot

## Purpose
Intended to stream candlestick (kline) data from Binance and publish normalized events to Kafka for downstream consumers.

## Current Implementation
- `BinanceDataCollectionApplication` only bootstraps Spring without additional configuration.
- `config/BinanceDataCollectionConfig` exposes hierarchical configuration properties for REST and WebSocket endpoints as well as Kafka topic metadata.
- `config/KafkaConfig` defines producers/consumers for the shared `KlineEvent` Avro schema but is currently commented out with `//@Configuration`, preventing the beans from loading.
- `config/RestTemplateConfig` registers a plain `RestTemplate`.
- `rest/DataCollectionRest` is an empty `@RestController` with no routes.
- No WebSocket listeners, schedulers, or Kafka publishing logic exist in the repository.

## Missing Pieces & Risks
- Without WebSocket clients or REST endpoints the service does not collect data.
- The Kafka configuration has a `TODO` to delete the class; if removed without replacement the service would lose all Kafka connectivity.
- No tests are present to validate configuration binding or future data processing logic.

## Recommendations
1. Implement a WebSocket listener that uses the configured intervals/symbols to subscribe to Binance streams and publish `KlineEvent` messages via `KafkaTemplate`.
2. Decide whether Kafka beans should live here or in a shared auto-configuration module, and either re-enable the class or replace it.
3. Add integration tests that mock Binance responses and verify serialized Avro payloads.
