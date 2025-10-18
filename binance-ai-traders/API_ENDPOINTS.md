# REST API Endpoints Reference

Comprehensive REST API documentation for all Binance AI Traders microservices.

**Last Updated**: 2025-10-18

## Quick Navigation

- [binance-data-storage](#binance-data-storage)
- [binance-trader-macd](#binance-trader-macd)
- [binance-data-collection](#binance-data-collection-planned)
- [matrix-ui-portal](#matrix-ui-portal-planned)
- [Common Patterns](#common-patterns)

---

## binance-data-storage

**Base URL (Testnet)**: `http://localhost:8087`  
**Base URL (Dev)**: `http://localhost:8082`

### Kline Data API

#### GET `/api/v1/klines/recent`
Get recent klines for a symbol and interval.

**Parameters:**
- `symbol` (required): Trading pair (e.g., "BTCUSDT")
- `interval` (required): Kline interval (e.g., "1h", "4h", "1d")
- `limit` (optional): Number of klines (default: 100, max: 1000)

**Example:**
```bash
curl "http://localhost:8087/api/v1/klines/recent?symbol=BTCUSDT&interval=1h&limit=100"
```

**Response:** Array of `KlineItem` objects

---

#### GET `/api/v1/klines/range`
Get klines for a specific time range.

**Parameters:**
- `symbol` (required): Trading pair
- `interval` (required): Kline interval
- `startTime` (required): Start time in milliseconds
- `endTime` (required): End time in milliseconds

**Example:**
```bash
curl "http://localhost:8087/api/v1/klines/range?symbol=BTCUSDT&interval=1h&startTime=1697500000000&endTime=1697600000000"
```

**Response:** Array of `KlineItem` objects

---

#### GET `/api/v1/klines/count`
Count klines for a symbol and interval.

**Parameters:**
- `symbol` (required): Trading pair
- `interval` (required): Kline interval

**Example:**
```bash
curl "http://localhost:8087/api/v1/klines/count?symbol=BTCUSDT&interval=1h"
```

**Response:** `Long` (count)

---

#### GET `/api/v1/klines/health`
Health check for kline data API.

**Example:**
```bash
curl "http://localhost:8087/api/v1/klines/health"
```

**Response:** `"Kline Data API is healthy"`

---

### MACD Data API

#### POST `/api/v1/macd`
Upsert (insert or update) MACD indicator data.

**Body:** `MacdItem` JSON object
```json
{
  "symbol": "BTCUSDT",
  "interval": "1h",
  "timestamp": 1697500000000,
  "macd": 125.45,
  "signal": 120.30,
  "histogram": 5.15,
  "emaFast": 45000.50,
  "emaSlow": 44875.05
}
```

**Example:**
```bash
curl -X POST "http://localhost:8087/api/v1/macd" \
  -H "Content-Type: application/json" \
  -d '{"symbol":"BTCUSDT","interval":"1h",...}'
```

**Response:** `200 OK` on success

---

#### GET `/api/v1/macd/recent`
Get recent MACD indicators.

**Parameters:**
- `symbol` (required): Trading pair
- `interval` (required): Kline interval
- `limit` (optional): Number of records (default: 100, max: 1000)

**Example:**
```bash
curl "http://localhost:8087/api/v1/macd/recent?symbol=BTCUSDT&interval=1h&limit=50"
```

**Response:** Array of `MacdItem` objects

---

### Observability API

#### POST `/api/v1/observability/strategy-analysis`
Record strategy analysis event for observability.

**Body:** Strategy analysis data (flexible JSON)
```json
{
  "strategyId": "macd-btcusdt-1h",
  "timestamp": 1697500000000,
  "analysis": {...}
}
```

**Example:**
```bash
curl -X POST "http://localhost:8087/api/v1/observability/strategy-analysis" \
  -H "Content-Type: application/json" \
  -d '{"strategyId":"macd-btcusdt-1h",...}'
```

**Response:** `200 OK` on success

---

#### POST `/api/v1/observability/decision-log`
Record trading decision log.

**Body:** Decision log data (flexible JSON)

**Example:**
```bash
curl -X POST "http://localhost:8087/api/v1/observability/decision-log" \
  -H "Content-Type: application/json" \
  -d '{"decision":"buy","reason":"macd_crossover",...}'
```

**Response:** `200 OK` on success

---

#### POST `/api/v1/observability/portfolio-snapshot`
Record portfolio snapshot.

**Body:** Portfolio snapshot data (flexible JSON)

**Example:**
```bash
curl -X POST "http://localhost:8087/api/v1/observability/portfolio-snapshot" \
  -H "Content-Type: application/json" \
  -d '{"timestamp":1697500000000,"positions":[...],...}'
```

**Response:** `200 OK` on success

---

### Actuator Endpoints

#### GET `/actuator/health`
Spring Boot actuator health endpoint.

**Example:**
```bash
curl "http://localhost:8087/actuator/health"
```

**Response:**
```json
{
  "status": "UP",
  "components": {...}
}
```

---

#### GET `/actuator/metrics`
Get all available Micrometer metrics.

**Example:**
```bash
curl "http://localhost:8087/actuator/metrics"
```

**Response:** List of available metric names

---

#### GET `/actuator/prometheus`
Prometheus scrape endpoint.

**Example:**
```bash
curl "http://localhost:8087/actuator/prometheus"
```

**Response:** Prometheus-format metrics

---

## binance-trader-macd

**Base URL (Testnet)**: `http://localhost:8083`  
**Base URL (Dev)**: `http://localhost:8083`

### MACD Indicator Calculation API

#### GET `/api/v1/macd/indicator/{symbol}/{interval}`
Calculate MACD indicator with custom parameters.

**Path Parameters:**
- `symbol`: Trading pair (e.g., "BTCUSDT")
- `interval`: Kline interval (e.g., "5m", "1h", "1d")

**Query Parameters:**
- `fastPeriod` (optional): Fast EMA period (default: 12)
- `slowPeriod` (optional): Slow EMA period (default: 26)
- `signalPeriod` (optional): Signal line period (default: 9)

**Example:**
```bash
curl "http://localhost:8083/api/v1/macd/indicator/BTCUSDT/1h?fastPeriod=12&slowPeriod=26&signalPeriod=9"
```

**Response:** `MACDIndicator` object

---

#### GET `/api/v1/macd/indicator/{symbol}/{interval}/default`
Calculate MACD with default parameters (12-26-9).

**Path Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval

**Example:**
```bash
curl "http://localhost:8083/api/v1/macd/indicator/BTCUSDT/1h/default"
```

**Response:** `MACDIndicator` object

---

#### GET `/api/v1/macd/indicators/batch`
Get MACD indicators for multiple symbols in batch.

**Body:** Array of symbol/interval pairs
```json
[
  {"symbol": "BTCUSDT", "interval": "1h"},
  {"symbol": "ETHUSDT", "interval": "1h"}
]
```

**Example:**
```bash
curl -X GET "http://localhost:8083/api/v1/macd/indicators/batch" \
  -H "Content-Type: application/json" \
  -d '[{"symbol":"BTCUSDT","interval":"1h"}]'
```

**Response:** Array of `MACDIndicator` objects

---

#### GET `/api/v1/macd/cached`
Get all cached MACD indicators from metrics service.

**Example:**
```bash
curl "http://localhost:8083/api/v1/macd/cached"
```

**Response:** Map of indicator keys to `MACDIndicator` objects

---

#### POST `/api/v1/macd/update`
Trigger update of MACD indicators for all monitored symbols.

**Example:**
```bash
curl -X POST "http://localhost:8083/api/v1/macd/update"
```

**Response:** `"MACD indicators updated successfully"`

---

#### POST `/api/v1/macd/update/{symbol}/{interval}`
Update MACD indicator for specific symbol and interval.

**Path Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval

**Example:**
```bash
curl -X POST "http://localhost:8083/api/v1/macd/update/BTCUSDT/1h"
```

**Response:** `"MACD indicator updated for BTCUSDT 1h"`

---

#### GET `/api/v1/macd/stats`
Get MACD metrics statistics.

**Example:**
```bash
curl "http://localhost:8083/api/v1/macd/stats"
```

**Response:** Statistics object with metrics

---

#### GET `/api/v1/macd/health`
Health check for MACD API.

**Example:**
```bash
curl "http://localhost:8083/api/v1/macd/health"
```

**Response:** `"MACD API is healthy"`

---

### Trading Metrics

Available via `/actuator/metrics` and `/actuator/prometheus`:

- `binance.trader.active.positions` (gauge) - Number of active trading positions
- `binance.trader.realized.pnl` (gauge, tagged by `quote_asset`) - Realized profit/loss
- `binance.trader.signals` (counter, tagged by `direction`: total/buy/sell) - Trading signals processed

---

### Actuator Endpoints

Same as binance-data-storage service:
- `GET /actuator/health`
- `GET /actuator/metrics`
- `GET /actuator/prometheus`
- `GET /actuator/info`

---

## binance-data-collection (Planned)

**Base URL (Testnet)**: `http://localhost:8086`  
**Base URL (Dev)**: `http://localhost:8081`

**Status**: Not yet implemented. WebSocket and REST endpoints planned.

### Planned Endpoints

#### GET `/api/v1/collection/status`
Get collection status for all symbols/intervals.

**Response:** Status object with collection state

---

#### POST `/api/v1/collection/start/{symbol}/{interval}`
Start data collection for symbol/interval.

**Path Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval

---

#### POST `/api/v1/collection/stop/{symbol}/{interval}`
Stop data collection for symbol/interval.

**Path Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval

---

#### GET `/actuator/health`
Health check endpoint.

---

## matrix-ui-portal (Planned)

**Base URL**: `http://localhost:3000`

**Status**: Planned. Backend APIs need implementation in appropriate services.

### Required Endpoints

These endpoints need to be implemented in backend services:

#### GET `/api/health/summary`
Aggregate health dashboard data.

**Response:** Health summary for all services

---

#### GET `/api/operations/metrics`
Operational metrics for dashboard.

**Query Parameters:**
- `range`: Time range (15m, 1h, 24h, custom)
- `environment`: dev/testnet/production

**Response:** Operational metrics object

---

#### GET `/api/strategies`
List all trading strategies.

**Query Parameters:** Filters (symbol, type, status, interval)

**Response:** Array of strategy objects

---

#### POST `/api/strategies`
Create new trading strategy.

**Body:** Strategy configuration
```json
{
  "symbol": "BTCUSDT",
  "interval": "1h",
  "strategy_type": "macd",
  "parameters": {
    "fastPeriod": 12,
    "slowPeriod": 26,
    "signalPeriod": 9
  }
}
```

---

#### PUT `/api/strategies/{id}`
Update existing strategy.

**Path Parameters:**
- `id`: Strategy UUID

**Body:** Updated strategy fields

---

#### POST `/api/strategies/{id}/activate`
Activate (load) strategy.

**Path Parameters:**
- `id`: Strategy UUID

---

#### POST `/api/strategies/{id}/deactivate`
Deactivate (unload) strategy.

**Path Parameters:**
- `id`: Strategy UUID

---

#### GET `/api/strategies/{id}/history`
Get strategy performance history.

**Path Parameters:**
- `id`: Strategy UUID

**Response:** Historical performance data

---

#### GET `/api/market-data/klines`
Get kline data with filters.

**Query Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval
- `from`: Start timestamp
- `to`: End timestamp

---

#### GET `/api/market-data/macd`
Get MACD data with filters.

**Query Parameters:**
- `symbol`: Trading pair
- `interval`: Kline interval
- `from`: Start timestamp
- `to`: End timestamp

---

#### WS `/api/stream/market-data`
WebSocket stream for real-time market data.

**Subscription:** Send symbol/interval to subscribe

---

## Common Patterns

### API Versioning
All APIs use `/api/v1` prefix for version 1.

### Pagination
- Default limit: 100
- Maximum limit: 1000
- Use `limit` parameter for pagination

### Timestamps
All timestamps are in **milliseconds** since Unix epoch.

### Error Responses
HTTP status codes:
- `200 OK` - Success
- `400 Bad Request` - Invalid parameters
- `500 Internal Server Error` - Server error

### Health Checks
Every service exposes:
- `/actuator/health` - Spring Boot actuator
- Service-specific `/health` or `/{api}/health` endpoints

### Metrics
All Java services expose Prometheus metrics at `/actuator/prometheus`.

---

## Authentication

**Current Status**: Not implemented

**Planned**: JWT-based authentication for matrix-ui-portal and protected endpoints.

---

## Rate Limiting

**Current Status**: Not implemented

**Recommendation**: Implement rate limiting for production deployments.

---

## API Documentation

**Current Status**: This document provides REST API reference.

**Recommendation**: Add Swagger/OpenAPI specification to services.

---

## Related Documentation

- **Service Documentation**: `binance-ai-traders/services/`
- **Memory System**: `binance-ai-traders/memory/context/MEM-C009-rest-api-inventory.md`
- **Architecture**: `binance-ai-traders/AGENTS.md`
- **Where-is-what**: `binance-ai-traders/WHERE_IS_WHAT.md`

---

**Last Updated**: 2025-10-18  
**Status**: Living document - update as APIs evolve

