# Services Documentation

Comprehensive documentation for all microservices in the Binance AI Traders platform.

## Backend Services (Java 21, Spring Boot 3.3.9)

### Data Layer
- **[Binance Data Collection](binance-data-collection.md)** - WebSocket data collection and Kafka publishing
  - Status: 🔴 Skeleton (WebSocket implementation needed)
  - HELP: [binance-data-collection/HELP.md](../../binance-data-collection/HELP.md)

- **[Binance Data Storage](binance-data-storage.md)** - PostgreSQL + Elasticsearch persistence
  - Status: 🟢 Complete
  - REST API: `/api/v1/klines`, `/api/v1/macd`, `/api/v1/observability`
  - HELP: [binance-data-storage/HELP.md](../../binance-data-storage/HELP.md)

### Trading Strategies
- **[Binance MACD Trader](binance-trader-macd.md)** - MACD strategy + backtesting engine
  - Status: 🟡 Partial (Backtesting ✅, Strategy logic needed)
  - REST API: `/api/v1/macd/indicator`, `/api/v1/macd/update`
  - Backtesting: [BACKTESTING_ENGINE.md](../../binance-trader-macd/BACKTESTING_ENGINE.md)
  - HELP: [binance-trader-macd/HELP.md](../../binance-trader-macd/HELP.md)

- **[Binance Grid Trader](binance-trader-grid.md)** - Grid trading strategy
  - Status: 🔴 Duplicate/Incomplete
  - HELP: [binance-trader-grid/HELP.md](../../binance-trader-grid/HELP.md)

### Supporting Services
- **[Indicator Calculator](indicator-calculator.md)** - Technical indicator calculations
  - Status: ⚠️ Documentation only (service missing)

## Frontend Services

### User Interfaces
- **[Matrix UI Portal](matrix-ui-portal.md)** - React/Vite web control center
  - Status: 🔴 Planned
  - Tech: React 18, Vite, TypeScript
  - Specification: [UI_PORTAL_SPECIFICATION.md](../UI_PORTAL_SPECIFICATION.md)
  - Port: 3000

- **Telegram Frontend** - FastAPI + Telegram bot
  - Status: 🔴 Scaffolding (dependencies missing, not runnable)
  - Tech: Python 3.11, FastAPI, aiogram
  - Location: `telegram-frontend-python/`

## Shared Libraries

- **Binance Shared Model** - Avro schemas and shared types
  - Status: 🟢 Complete
  - Tech: Java 21, Avro
  - Location: `binance-shared-model/`

## Service Status Legend
- 🟢 **Complete**: Fully implemented and operational
- 🟡 **Partial**: Some components complete, others in progress
- 🔴 **Skeleton/Planned**: Basic structure or not yet implemented
- ⚠️ **Missing**: Documentation exists but service not implemented

## API Documentation
For complete REST API reference, see [API_ENDPOINTS.md](../API_ENDPOINTS.md)

## Architecture
For system architecture and service dependencies, see [AGENTS.md](../AGENTS.md)
