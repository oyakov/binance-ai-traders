# MEM-C009: REST API Endpoints Inventory

## Type
Context Entry | API Documentation

## Last Updated
2025-10-18

## Status
**Active** | **Scope**: All Services

## Summary
Comprehensive inventory of REST API endpoints across all microservices in the Binance AI Traders platform.

## binance-data-storage (Port 8087 Testnet, 8082 Dev)

### Kline Data API (`/api/v1/klines`)
- `GET /api/v1/klines/recent` - Get recent klines for symbol/interval (limit: 1-1000)
  - Params: `symbol`, `interval`, `limit` (default: 100)
- `GET /api/v1/klines/range` - Get klines for specific time range
  - Params: `symbol`, `interval`, `startTime`, `endTime` (milliseconds)
- `GET /api/v1/klines/count` - Count klines for symbol/interval
  - Params: `symbol`, `interval`
- `GET /api/v1/klines/health` - Health check

### MACD Data API (`/api/v1/macd`)
- `POST /api/v1/macd` - Upsert MACD item
  - Body: `MacdItem` (symbol, interval, macd values)
- `GET /api/v1/macd/recent` - Get recent MACD indicators
  - Params: `symbol`, `interval`, `limit` (default: 100, max: 1000)

### Observability API (`/api/v1/observability`)
- `POST /api/v1/observability/strategy-analysis` - Record strategy analysis
  - Body: Strategy analysis data (JSON)
- `POST /api/v1/observability/decision-log` - Record decision log
  - Body: Decision log data (JSON)
- `POST /api/v1/observability/portfolio-snapshot` - Record portfolio snapshot
  - Body: Portfolio snapshot data (JSON)

### Actuator Endpoints
- `GET /actuator/health` - Service health status
- `GET /actuator/metrics` - Micrometer metrics
- `GET /actuator/prometheus` - Prometheus scrape endpoint
- `GET /actuator/info` - Application info

## binance-trader-macd (Port 8083 Testnet, 8083 Dev)

### MACD Indicator API (`/api/v1/macd`)
- `GET /api/v1/macd/indicator/{symbol}/{interval}` - Get MACD indicator with custom parameters
  - Path: `symbol`, `interval`
  - Params: `fastPeriod` (default: 12), `slowPeriod` (default: 26), `signalPeriod` (default: 9)
- `GET /api/v1/macd/indicator/{symbol}/{interval}/default` - Get MACD with default parameters (12-26-9)
- `GET /api/v1/macd/indicators/batch` - Get MACD indicators for multiple symbols
  - Body: List of symbol/interval pairs
- `GET /api/v1/macd/cached` - Get all cached MACD indicators from metrics service
- `POST /api/v1/macd/update` - Update MACD indicators for all monitored symbols
- `POST /api/v1/macd/update/{symbol}/{interval}` - Update MACD for specific symbol/interval
- `GET /api/v1/macd/stats` - Get MACD metrics statistics
- `GET /api/v1/macd/health` - Health check

### Actuator Endpoints
- `GET /actuator/health` - Service health status
- `GET /actuator/metrics` - Micrometer metrics including:
  - `binance.trader.active.positions` - Active positions gauge
  - `binance.trader.realized.pnl` - Realized PnL by quote_asset
  - `binance.trader.signals{direction}` - Signal counters (total/buy/sell)
- `GET /actuator/prometheus` - Prometheus scrape endpoint
- `GET /actuator/info` - Application info

## binance-data-collection (Port 8086 Testnet, 8081 Dev)

### Status
**Not Implemented** - WebSocket and REST endpoints planned but not yet developed

### Planned Endpoints
- `GET /api/v1/collection/status` - Collection status for symbols/intervals
- `POST /api/v1/collection/start/{symbol}/{interval}` - Start collection
- `POST /api/v1/collection/stop/{symbol}/{interval}` - Stop collection
- `GET /actuator/health` - Health check
- `GET /actuator/prometheus` - Metrics

## matrix-ui-portal (Port 3000 - Planned)

### Status
**Planned** - Backend APIs need to be implemented in appropriate services

### Required Endpoints (to be implemented)
- `GET /api/health/summary` - Aggregate health dashboard
- `GET /api/operations/metrics` - Operational metrics (range, environment params)
- `GET /api/strategies` - List trading strategies
- `POST /api/strategies` - Create new strategy
- `PUT /api/strategies/{id}` - Update strategy
- `POST /api/strategies/{id}/activate` - Activate strategy
- `POST /api/strategies/{id}/deactivate` - Deactivate strategy
- `GET /api/strategies/{id}/history` - Strategy performance history
- `GET /api/market-data/klines` - Klines with filters (symbol, interval, from, to)
- `GET /api/market-data/macd` - MACD data with filters
- `WS /api/stream/market-data` - Real-time market data stream

## API Design Patterns

### Common Patterns
1. **Versioning**: All APIs use `/api/v1` prefix
2. **Health Checks**: Each service has `/actuator/health` and dedicated `/health` endpoints
3. **Pagination**: Limit parameters with sensible defaults (100) and maximums (1000)
4. **Time Ranges**: Millisecond timestamps for startTime/endTime
5. **Error Handling**: HTTP status codes with log-and-return patterns

### Metrics Exposure
- All Java services expose Micrometer metrics at `/actuator/metrics`
- Prometheus format at `/actuator/prometheus`
- Custom business metrics (positions, PnL, signals, kline events)

### Missing Patterns
- No authentication/authorization (JWT planned for matrix-ui-portal)
- No rate limiting
- No API documentation (Swagger/OpenAPI)
- Inconsistent error response formats

## Related Entries
- **MEM-C004**: Microservices Detailed Analysis
- **MEM-I007**: Matrix UI Portal Specification
- **MEM-005**: Telegram Frontend Dependencies

## Recommendations
1. Add Swagger/OpenAPI documentation to all REST controllers
2. Implement consistent error response format across services
3. Add authentication layer (Spring Security + JWT)
4. Implement rate limiting for public-facing endpoints
5. Create API gateway for unified entry point
6. Document expected request/response schemas
7. Add API versioning strategy documentation

## Usage Examples

### Get Recent Klines
```bash
curl "http://localhost:8087/api/v1/klines/recent?symbol=BTCUSDT&interval=1h&limit=100"
```

### Calculate MACD
```bash
curl "http://localhost:8083/api/v1/macd/indicator/BTCUSDT/1h?fastPeriod=12&slowPeriod=26&signalPeriod=9"
```

### Update MACD Indicators
```bash
curl -X POST "http://localhost:8083/api/v1/macd/update/BTCUSDT/1h"
```

---

**Created**: 2025-10-18  
**Scope**: global-api-inventory  
**Impact**: Integration, Development

