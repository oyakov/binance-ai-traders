# Binance Data Storage Service

**Language**: Java 17, Spring Boot

## Purpose
Consumes `KlineEvent` records from Kafka, maps them into storage models, persists them in PostgreSQL and Elasticsearch, and emits lifecycle events.

## Current Implementation
- `BinanceDataStorageApplication` enables both JPA and Elasticsearch repositories, indicating dual persistence targets.
- `kafka/consumer/KafkaConsumerService` listens on a configurable topic/group and forwards events to the service layer.
- `service/impl/KlineDataService` performs the heavy lifting:
  - Maps Avro payloads to persistence models through `KlineMapper`.
  - Persists data to PostgreSQL via `KlinePostgresRepository.upsertKline` and to Elasticsearch via `KlineElasticRepository`.
  - Publishes `DataItemWrittenNotification` events on success or failure and supports compensating deletes.
  - Executes a `@PostConstruct` smoke test that writes & deletes a sample record against each configured `CrudRepository`.
- Repository packages exist for JPA, Elasticsearch, and JDBC access patterns, though entity and repository definitions require further review to confirm completeness.

## Missing Pieces & Risks
- The repository contains infrastructure for compensation events but no listeners or sagas that react to them.
- Database schema migrations (Liquibase/Flyway) are not present; deployment assumes the schema already exists.
- Exception handling in `KlineDataService` mixes log-and-suppress with rethrow semantics; compensating actions may leave stores out of sync if failures occur mid-transaction.
- Unit/integration tests are absent, so mapper correctness and repository behavior remain unverified.

## Recommendations
1. Add schema migration scripts and document expected table/index structures.
2. Introduce automated tests covering Avro-to-entity mapping, repository persistence, and compensation flows.
3. Review the `@PostConstruct` smoke test—consider replacing it with health indicators to avoid mutating production data.
4. Implement event listeners that react to `DataItemWrittenNotification` to close the loop on failure handling.
