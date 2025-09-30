# Binance Grid Trader Service

**Language**: Java 17, Spring Boot (intended)

## Purpose
Planned to execute a grid trading strategy that places layered buy/sell orders around the current market price.

## Current Implementation
- The module contains only two Java files, both copied from the data storage service (`BinanceDataStorageApplication` and `config/ElasticsearchConfig`).
- No grid strategy logic, domain models, or Kafka integrations are present.
- Build files (`pom.xml`, Maven wrapper, Dockerfile) exist, implying the module was scaffolded but never implemented.

## Missing Pieces & Risks
- There is zero functionality specific to grid trading; attempting to build/deploy would only start an empty Spring application configured for storage duties.
- The absence of Kafka listeners means the service cannot receive market data or indicators.
- Duplicated Elasticsearch configuration indicates the module was forked from storage without updates.

## Recommendations
1. Replace the copied classes with grid-trading-specific components: strategy services, order management, and Kafka integration.
2. Define configuration properties tailored to grid behavior (grid spacing, order counts, rebalance rules).
3. Add tests that simulate price movements and verify the strategy issues the expected ladder of orders.
4. Remove or refactor shared infrastructure classes into a common library to avoid duplication.
