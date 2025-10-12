# binance-shared-model Module Requirements

## Module overview
The shared-model module provides the Avro schemas and serialization helpers used across all JVM services for inter-service communication. It ensures schema compatibility for Kafka payloads and backtesting datasets.

## Functional scope
- **Avro schema definitions**: `KlineEvent` captures Binance kline attributes (open/close times, OHLCV values, symbol metadata) and is the canonical payload for Kafka topics shared between data-collection, storage, and trading services.【F:binance-shared-model/src/main/java/com/oyakov/binance_shared_model/avro/KlineEvent.java†L11-L123】
- **Backtesting dataset model**: `BacktestDataset` aggregates a named collection of `KlineEvent` records plus metadata about collection time, enabling consistent serialization for historical simulation exports.【F:binance-shared-model/src/main/java/com/oyakov/binance_shared_model/backtest/BacktestDataset.java†L11-L65】
- **Kafka serializer/deserializer helpers**: Command marker serializer/deserializer utilities provide consistent wiring for Kafka command topics that exchange higher-level orchestration messages.【F:binance-shared-model/src/main/java/com/oyakov/binance_shared_model/kafka/serializer/CommandMarkerSerializer.java†L9-L55】【F:binance-shared-model/src/main/java/com/oyakov/binance_shared_model/kafka/deserializer/CommandMarkerDeserializer.java†L9-L61】

## Configuration contract
- Avro classes are generated and packaged so consuming services can depend on `binance-shared-model` via Maven; ensure the module version is bumped whenever schema-breaking changes are introduced.
- Schema registry compatibility must remain `BACKWARD` or stronger to avoid breaking downstream consumers when fields are added.

## Observability requirements
- Because this module lacks runtime components, observability is focused on schema evolution discipline: document schema changes in release notes and update consuming service metrics/validators accordingly.

## Known gaps & TODOs
- Formalize schema change management (e.g., define Avro compatibility tests) to prevent accidental breaking changes during local development.
- Extend shared models to cover trading commands and order responses as those domains stabilize, reducing duplication across services.
