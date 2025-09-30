# Docker Compose Stacks

## `docker-compose.yml`
Provides a full local stack including:
- **Kafka (KRaft mode)** with internal/external listeners and auto topic creation enabled.
- **Schema Registry** for Avro serialization.
- **PostgreSQL** for relational persistence.
- **Elasticsearch** for search/analytics.
- **binance-data-collection** service build target.

### Observations
- Only the data collection service is wired into the compose file; data storage and trader services are absent.
- Kafka broker ID and controller quorum are configured for a single-node cluster suitable for development.
- The Compose file expects the application containers to handle schema creation/migration on startup.

## `docker-compose-kafka-kraft.yml`
Minimal stack that boots only the Kafka broker in KRaft mode with persistent volumes. Useful for testing producer/consumer code without other dependencies.

## Recommendations
1. Extend the main stack to include storage and trader services once they are runnable.
2. Parameterize sensitive configuration (API keys, database passwords) via `.env` files or secrets rather than inline literals.
3. Document topic names, partitions, and retention policies required for each service to operate.
