# System Overview

This repository hosts a collection of Binance-focused services that share market data and trading signals over Kafka. The codebase mixes Java/Spring Boot microservices with a Python Telegram frontend. The current state of the project is uneven: several services contain scaffolding or partial implementations, while the data storage and MACD trader components show more complete logic.

## Major Domains
- **Market Data Ingestion** – Collects raw candlestick (kline) data from Binance and publishes it to Kafka topics.
- **Persistence** – Normalizes and writes kline events into PostgreSQL and Elasticsearch for downstream analysis.
- **Trading Strategies** – Implements (or plans) automated strategies such as a MACD-driven trader and a grid trader.
- **Client Integrations** – Exposes functionality through a Telegram bot that is intended to orchestrate subsystems and surface signals to end users.
- **Shared Contracts** – Provides Avro schemas used to serialize kline events across services.
- **Infrastructure** – Docker Compose definitions stand up Kafka, Schema Registry, PostgreSQL, and Elasticsearch alongside services during local development.

## High-Level Findings
- The **data storage** and **MACD trader** modules contain substantive Spring services, repositories, and Kafka consumers; however, they rely on yet-to-be-documented database schemas and some missing collaborators.
- The **data collection** module currently stops at configuration wiring and does not implement REST endpoints, WebSocket consumers, or Kafka publishers.
- The **grid trader** directory duplicates the storage service’s bootstrap classes instead of strategy-specific logic, suggesting the intended implementation has not been committed.
- Several services referenced in the README—such as an *indicator calculator*—are absent from the repository.
- The **Telegram frontend** includes extensive package scaffolding, but numerous imports point to modules that do not exist, so the bot is not runnable without additional code.
- Docker Compose files target modern Kafka-without-ZooKeeper setups but leave service-specific environment configuration to be completed.

Consult the service-specific notes in `docs/services/` and the integration notes in `docs/clients/` and `docs/infrastructure/` for detailed findings.
