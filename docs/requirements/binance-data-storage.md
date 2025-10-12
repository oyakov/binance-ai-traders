# binance-data-storage Service Requirements

## Service overview
The data-storage service consumes normalized kline events from Kafka, persists them to PostgreSQL and optionally Elasticsearch, and exposes REST APIs for downstream consumers to query historical data. It also publishes detailed metrics covering ingestion, persistence, and compensation workflows.

## Functional scope
- **Kafka ingestion**: `KafkaConsumerService` listens to the configured kline topic, records per-message metrics, and forwards each event to the storage pipeline with Kafka retry semantics on failure.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/kafka/consumer/KafkaConsumerService.java†L16-L38】
- **Persistence orchestration**: `KlineDataService` maps Avro events to storage models, writes them to PostgreSQL (upsert) and Elasticsearch, emits storage metrics, and publishes `DataItemWrittenNotification` events for audit/compensation.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L22-L159】
- **Compensation & rollback**: Failed writes or compensating events trigger deletion from both datastores to keep replicas consistent, incrementing compensation metrics.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L160-L220】
- **REST APIs for kline retrieval**: `KlineDataController` provides endpoints for recent klines, ranged queries, latest candle lookup, count, and health status; pagination and validation guardrails enforce bounded queries.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/controller/KlineDataController.java†L18-L123】
- **MACD storage facade**: MACD-specific repositories/controllers support storing indicator calculations and exposing them through dedicated endpoints (see `MacdController` and `MacdDataService`).【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/controller/MacdController.java†L1-L160】
- **Event bridging**: Internal application events (new kline written, etc.) are observed by `KlineEventBroker` to trigger persistence without tight coupling between Kafka and the service layer.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/kafka/service/KlineEventBroker.java†L13-L37】

## Configuration contract
- Expects `binance.data.kline.kafka-topic` and `binance.data.kline.kafka-consumer-group` settings for Kafka listeners.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/kafka/consumer/KafkaConsumerService.java†L20-L22】
- Relies on Spring Data repositories for PostgreSQL (`KlinePostgresRepository`, `MacdPostgresRepository`) and optionally Elasticsearch (`KlineElasticRepository`); connection availability controls are auto-detected via `ObjectProvider` injection.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L34-L64】
- Requires Micrometer to be configured so metrics emitted by `DataStorageMetrics` are scraped by Prometheus.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/metrics/DataStorageMetrics.java†L21-L126】

## Observability requirements
- Emit counters, timers, and gauges for ingestion, storage success/failure, retry behavior, repository connectivity, and Kafka consumer health through `DataStorageMetrics` for each symbol/interval combination.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/metrics/DataStorageMetrics.java†L21-L209】
- Provide `/api/v1/klines/health` as a quick readiness probe for orchestrators and dashboards.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/controller/KlineDataController.java†L116-L122】
- Log all persistence attempts with enough context (symbol, interval, repository name) to support incident response, while rethrowing to ensure upstream retries are triggered.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L83-L159】

## External dependencies
- Kafka cluster (same Avro schema as data-collection) for inbound events.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/kafka/consumer/KafkaConsumerService.java†L16-L38】
- PostgreSQL database for canonical storage; relies on custom upsert logic and fingerprint-based deletes.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L72-L150】
- Optional Elasticsearch index for analytics queries.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L94-L142】

## Known gaps & TODOs
- Elasticsearch repository is optional; when absent the service logs warnings but cannot satisfy search-heavy use cases. Plan cluster provisioning and enablement tests before promoting to production.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L103-L141】
- Compensation events currently rely on application memory; introduce durable retry queues if cross-service sagas are required.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/service/impl/KlineDataService.java†L160-L220】
- Review controller error responses and add structured error bodies for client consumption; present implementation returns generic 500 responses.【F:binance-data-storage/src/main/java/com/oyakov/binance_data_storage/controller/KlineDataController.java†L44-L115】
