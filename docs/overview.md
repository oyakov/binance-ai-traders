# System Overview

This repository hosts a collection of Binance-focused services that share market data and trading signals over Kafka. The codebase mixes Java/Spring Boot microservices with a Python Telegram frontend. The current state of the project is uneven: several services contain scaffolding or partial implementations, while the data storage and MACD trader components show more complete logic. The January 2025 roadmap update formalizes an expansion path that keeps the small-account growth objective front and center while preparing the stack for multi-exchange support and an AI-assisted operator experience.

## Major Domains
- **Market Data Ingestion** – Collects raw candlestick (kline) data from Binance and publishes it to Kafka topics.
- **Persistence** – Normalizes and writes kline events into PostgreSQL and Elasticsearch for downstream analysis.
- **Trading Strategies** – Implements (or plans) automated strategies such as a MACD-driven trader and a grid trader.
- **Client Integrations** – Exposes functionality through a Telegram bot that is intended to orchestrate subsystems and surface signals to end users.
- **Shared Contracts** – Provides Avro schemas used to serialize kline events across services.
- **Infrastructure** – Docker Compose definitions stand up Kafka, Schema Registry, PostgreSQL, and Elasticsearch alongside services during local development.

## Current Capabilities Snapshot
- **Backtesting Engine (MACD)** – Mature implementation with >2,400 historical scenarios executed and documented profitability (e.g., XRP/USDT MACD 30-60-15 delivering ~413% annualized return in the reference report).
- **Data Persistence Layer** – PostgreSQL/Elasticsearch pipelines function end-to-end for klines and derived indicators when supplied data.
- **Testnet Strategy Harness** – Configuration scaffolding exists for conservative/aggressive/balanced MACD variants, but only BTC/ETH configs run without manual babysitting because of upstream data gaps.
- **Agent & Monitoring Foundations** – Grafana/Prometheus stacks are wired up and the Mechanicus agent UI can be layered in to supply operator guidance once the trading services emit consistent telemetry.

## Gaps Blocking Roadmap Progress
- **Real-Time Data Collection** – The Binance WebSocket collectors and Kafka publishers remain unimplemented, preventing reliable live feeds for MACD/grid strategies.
- **Live Strategy Execution** – The MACD trader’s signal-to-order pipeline is incomplete; no trades have been generated in recent multi-day testnet runs. The grid trader still duplicates storage boilerplate instead of housing grid logic, and swing/arbitrage strategies are not started.
- **Operator Experience** – The Telegram frontend lacks required modules and dependency wiring, so strategy state cannot be surfaced or controlled outside of logs.
- **Multi-Exchange Readiness** – Exchange abstraction layers and connector plugins outlined in the roadmap are not yet in the repository, leaving the system Binance-only.

## High-Level Findings
- The **data storage** and **MACD trader** modules contain substantive Spring services, repositories, and Kafka consumers; however, they rely on yet-to-be-documented database schemas and some missing collaborators.
- The **data collection** module currently stops at configuration wiring and does not implement REST endpoints, WebSocket consumers, or Kafka publishers.
- The **grid trader** directory duplicates the storage service’s bootstrap classes instead of strategy-specific logic, suggesting the intended implementation has not been committed.
- Several services referenced in the README—such as an *indicator calculator*—are absent from the repository.
- The **Telegram frontend** includes extensive package scaffolding, but numerous imports point to modules that do not exist, so the bot is not runnable without additional code.
- Docker Compose files target modern Kafka-without-ZooKeeper setups but leave service-specific environment configuration to be completed.

## Near-Term Execution Priorities
1. **Finish Testnet Readiness (M1)** – Implement Binance WebSocket ingestion, complete MACD order execution with risk controls, replace the grid trader duplication with a working sideways-market bot, and ship the Telegram UI so operators can observe performance during the multi-week soak tests.
2. **Harden Production Foundations (M2)** – Lock down API key management, document emergency kill-switch flows, and prepare AI-authored daily runbooks that summarize production trading, aligning with the roadmap’s emphasis on transparency for a $300 starter account.
3. **Lay the Groundwork for M3** – Define the exchange interface contract, prioritize Coinbase/Kraken connectors, and capture requirements for swing trading plus arbitrage modules so the system can diversify once Binance production stability is proven.

Consult the service-specific notes in `docs/services/` and the integration notes in `docs/clients/` and `docs/infrastructure/` for detailed findings.
