# MEM-I007: Matrix UI Portal Specification and Status

## Type
Infrastructure | Context Entry

## Last Updated
2025-10-18

## Status
**Planned** | **Priority**: Medium

## Summary
Matrix-themed web portal (React/Vite) designed as unified user interface for Binance AI Traders platform. Provides control center for monitoring and operating automated trading services.

## Location
- **Source Code**: `matrix-ui-portal/`
- **Specification**: `binance-ai-traders/UI_PORTAL_SPECIFICATION.md`
- **Service Documentation**: `binance-ai-traders/services/matrix-ui-portal.md`

## Technical Stack
- **Framework**: React 18.2.0 with Vite 5.4.8
- **Language**: TypeScript
- **Styling**: Matrix theme (dark background #050607, neon green #00FF7F)
- **Container**: Docker (standalone service in compose stack)
- **Port**: 3000 (default)

## Key Features

### 1. System Health Dashboard
- Cluster status tiles for all services
- Alerts stream from Prometheus/Grafana
- Resource gauges (CPU, memory, disk)
- Connectivity heatmap

### 2. System Operational Dashboard
- Throughput timeline (orders, messages, alerts)
- Latency & lag panel (Kafka, API response times)
- Job status table (ETL/backfill jobs)
- Environment selector (dev/testnet/production)

### 3. Control Board
- Manage trading strategies from PostgreSQL `strategies` table
- Enable/disable strategies dynamically
- Create/edit strategy configurations
- Bulk actions with confirmation dialogues
- Activity audit logging

### 4. Live Chart Board
- Candlestick charts with MACD overlays
- Real-time updates (WebSocket/SSE)
- Multi-chart grid layout with drag-and-drop
- Crosshair inspection with OHLC values
- Export options (PNG, CSV)

## Data Integration

### PostgreSQL Tables
- `trading.strategies`: Strategy management (id, symbol, interval, strategy_type, parameters JSONB, status)
- `market_data.klines`: Candlestick data
- `market_data.macd`: MACD indicators

### Required API Endpoints
- `GET /api/health/summary` - health dashboard aggregate
- `GET /api/operations/metrics` - operational metrics
- `GET /api/strategies` - list strategies
- `POST /api/strategies` - create strategy
- `PUT /api/strategies/{id}` - update strategy
- `POST /api/strategies/{id}/activate` - load strategy
- `POST /api/strategies/{id}/deactivate` - unload strategy
- `GET /api/strategies/{id}/history` - performance history
- `GET /api/market-data/klines` - kline data
- `GET /api/market-data/macd` - MACD data
- `WS /api/stream/market-data` - real-time updates

## Current Implementation Status
- **Code**: Basic React scaffold with package.json
- **Files**: index.html, src/main.tsx, Dockerfile, vite.config.ts
- **Backend APIs**: Not yet implemented
- **Database Schema**: Strategies table not yet created
- **Deployment**: Not included in compose files

## Integration Requirements
1. Add `matrix-ui-portal` service to docker-compose.yml
2. Implement backend APIs in appropriate services
3. Create PostgreSQL schema for strategies table
4. Configure CORS for backend services
5. Implement JWT authentication
6. Set up WebSocket connections

## User Roles
- **Viewer**: Read-only access
- **Operator**: Enable/disable strategies
- **Strategist**: Create/edit configurations
- **Admin**: Full access including system settings

## Accessibility & UX
- Keyboard navigation for all components
- ARIA roles for screen readers
- Light/dark toggle option (Matrix theme default)
- Session timeout warnings
- Autosave drafts for strategy edits

## Related Entries
- **MEM-C004**: Microservices Detailed Analysis
- **MEM-C005**: Infrastructure and Monitoring Overview
- **MEM-C009**: REST API Endpoints Inventory

## Recommendations
1. Implement required backend APIs before UI development
2. Create database migrations for strategies table
3. Add matrix-ui-portal to docker-compose-testnet.yml first
4. Use existing monitoring stack for telemetry
5. Integrate with Grafana for data visualization

---

**Created**: 2025-10-18  
**Scope**: infrastructure-ui-portal  
**Impact**: User Experience, Operations

