# Matrix UI Portal Service

**Language**: TypeScript, React 18.2.0, Vite 5.4.8

## Purpose
Matrix-themed web portal serving as unified user interface and control center for the Binance AI Traders platform. Provides monitoring, operations management, strategy control, and live trading visualization.

## Current Implementation Status

**Status**: 🔴 **Planned** - Specification complete, implementation pending

### Existing Files
- `matrix-ui-portal/package.json` - React 18.2.0 + Vite 5.4.8 dependencies
- `matrix-ui-portal/index.html` - Entry HTML file
- `matrix-ui-portal/src/main.tsx` - React application entry point
- `matrix-ui-portal/Dockerfile` - Container build configuration
- `matrix-ui-portal/vite.config.ts` - Vite build configuration
- `matrix-ui-portal/tsconfig.json` - TypeScript configuration

### Missing Components
- **UI Components**: No React components implemented
- **API Integration**: No backend API clients
- **Authentication**: No auth implementation
- **State Management**: No Redux/Zustand setup
- **Backend APIs**: Required endpoints not implemented
- **Database Schema**: Strategies table not created
- **Docker Integration**: Not in compose files

## Architecture

### Frontend Stack
- **Framework**: React 18.2.0 with functional components and hooks
- **Build Tool**: Vite 5.4.8 for fast development and optimized builds
- **Language**: TypeScript for type safety
- **Styling**: Matrix theme (dark #050607, neon green #00FF7F)
- **State Management**: Recommended: React Query or Zustand
- **Charting**: Recommended: Lightweight Charts or Recharts

### Deployment
- **Container**: Docker standalone service
- **Port**: 3000 (default, configurable)
- **Base Path**: `/` (root)
- **Build**: Multi-stage Docker build

## Key Features

### 1. System Health Dashboard
Monitor infrastructure component health.

**Panels**:
- Cluster status tiles (all services with status/latency)
- Alerts stream (Prometheus/Grafana alerts)
- Resource gauges (CPU, memory, disk usage)
- Connectivity heatmap (inter-service connections)

**Datasources**: Prometheus, service health endpoints, PostgreSQL heartbeat

### 2. System Operational Dashboard
Track trading throughput and pipeline performance.

**Panels**:
- Throughput timeline (orders executed, messages processed, alerts)
- Latency & lag panel (Kafka consumer lag, API response times)
- Job status table (ETL/backfill jobs with progress)
- Environment selector (dev/testnet/production toggle)

**Datasources**: PostgreSQL aggregated views, Kafka metrics, application telemetry

### 3. Control Board
Manage trading strategies dynamically.

**Features**:
- List strategies from PostgreSQL `trading.strategies` table
- Enable/disable strategies with API calls
- Create/edit strategy configurations with validation
- Bulk actions (enable all, disable all)
- Activity audit logging (who changed what, when)

**UI Elements**:
- Strategies table (filterable, searchable, sortable)
- Strategy detail drawer (full parameter set, controls)
- Create/edit wizard (multi-step modal)

### 4. Live Chart Board
Visualize live market data per strategy.

**Features**:
- Candlestick charts with MACD overlays
- Real-time updates via WebSocket/SSE (≤5s refresh)
- Multi-chart grid with drag-and-drop
- Crosshair inspection (OHLC, MACD values)
- Data freshness indicators
- Export options (PNG, CSV)

**Charting Library**: Lightweight Charts or Recharts with Matrix theme

## Data Integration

### PostgreSQL Tables Required

#### `trading.strategies`
```sql
CREATE TABLE trading.strategies (
  id UUID PRIMARY KEY,
  symbol TEXT NOT NULL,
  interval TEXT NOT NULL,
  strategy_type TEXT NOT NULL,  -- 'macd', 'grid', etc.
  parameters JSONB NOT NULL,
  status TEXT NOT NULL,  -- 'active', 'inactive', 'error'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(symbol, interval, strategy_type)
);
```

### API Endpoints Required

These endpoints need to be implemented in backend services:

#### Health & Operations
- `GET /api/health/summary` - Aggregate health data
- `GET /api/operations/metrics` - Operational metrics (range, environment params)

#### Strategy Management
- `GET /api/strategies` - List strategies (with filters)
- `POST /api/strategies` - Create new strategy
- `PUT /api/strategies/{id}` - Update strategy
- `POST /api/strategies/{id}/activate` - Activate strategy
- `POST /api/strategies/{id}/deactivate` - Deactivate strategy
- `GET /api/strategies/{id}/history` - Performance history

#### Market Data
- `GET /api/market-data/klines` - Kline data (symbol, interval, from, to)
- `GET /api/market-data/macd` - MACD data (symbol, interval, from, to)
- `WS /api/stream/market-data` - Real-time market data stream

**Full API Specification**: See `binance-ai-traders/UI_PORTAL_SPECIFICATION.md`

## User Roles & Permissions

### Role Definitions
- **Viewer**: Read-only access to dashboards and charts
- **Operator**: Viewer + enable/disable strategies
- **Strategist**: Operator + create/edit strategy configurations
- **Admin**: Strategist + system settings and audit logs

### Implementation
- JWT-based authentication (to be implemented)
- Role-based authorization with permission checks
- Disabled controls show tooltip explanations
- Session timeout warnings

## Accessibility & UX

### Requirements
- Keyboard navigation for all interactive components
- ARIA roles and descriptive labels for screen readers
- Focus states with neon outlines
- Light/dark toggle option (Matrix theme default)
- Session timeout warnings
- Autosave drafts for strategy edits

### Performance
- Initial load time ≤3 seconds (20 Mbps connection)
- Client-side routing for instant navigation
- Support ≥50 concurrent sessions
- Graceful offline handling with retry

## Development Setup

### Prerequisites
- Node.js 18+ and npm/yarn
- Docker for containerization
- Access to backend APIs (local or testnet)

### Local Development
```bash
cd matrix-ui-portal
npm install
npm run dev
# Access at http://localhost:3000
```

### Build for Production
```bash
npm run build
npm run preview
```

### Docker Build
```bash
docker build -f matrix-ui-portal/Dockerfile -t matrix-ui-portal .
docker run -p 3000:3000 matrix-ui-portal
```

## Integration Requirements

### Backend Services
1. Implement required API endpoints in appropriate services
2. Configure CORS to allow matrix-ui-portal origin
3. Set up JWT authentication provider
4. Create PostgreSQL `trading.strategies` table

### Docker Compose Integration
```yaml
matrix-ui-portal:
  build:
    context: .
    dockerfile: matrix-ui-portal/Dockerfile
  container_name: matrix-ui-portal
  ports:
    - "3000:3000"
  environment:
    - VITE_API_BASE_URL=http://localhost:8083
    - VITE_WS_URL=ws://localhost:8083
  depends_on:
    - binance-trader-macd
    - binance-data-storage
  networks:
    - app-network
```

### Frontend Configuration
Environment variables (via Vite):
- `VITE_API_BASE_URL` - Base URL for REST APIs
- `VITE_WS_URL` - WebSocket URL for real-time data
- `VITE_ENVIRONMENT` - dev/testnet/production

## Monitoring & Telemetry

### Frontend Telemetry
- OpenTelemetry JS or custom logging
- Capture navigation events, API errors, user interactions
- Forward to centralized logging (ELK/Loki)

### Health Endpoint
- `GET /healthz` - Container health check
- `GET /metrics` - Frontend metrics (page loads, errors, latency)

## Known Issues & Limitations

### Current Limitations
- No components implemented
- Backend APIs not available
- Authentication not implemented
- Database schema not created
- Not integrated into compose stacks

### Blockers for Implementation
1. Backend API endpoints must be implemented first
2. PostgreSQL schema for strategies table
3. JWT authentication infrastructure
4. WebSocket support for real-time updates
5. CORS configuration in backend services

## Recommendations

### Implementation Priority
1. **Phase 1**: Implement backend APIs and database schema
2. **Phase 2**: Create basic UI shell with navigation
3. **Phase 3**: Implement System Health Dashboard
4. **Phase 4**: Implement Control Board with strategy management
5. **Phase 5**: Add Live Chart Board with real-time updates
6. **Phase 6**: Implement authentication and authorization
7. **Phase 7**: Polish UX, accessibility, and performance

### Best Practices
- Use TypeScript strict mode for type safety
- Implement comprehensive error boundaries
- Add loading states and skeleton screens
- Use React Query for server state management
- Implement optimistic updates for better UX
- Add end-to-end tests with Playwright or Cypress
- Configure CDN for static assets in production

## Related Documentation

- **UI Specification**: `binance-ai-traders/UI_PORTAL_SPECIFICATION.md`
- **API Endpoints**: `binance-ai-traders/API_ENDPOINTS.md`
- **Memory System**: `binance-ai-traders/memory/context/MEM-I007-matrix-ui-portal.md`
- **Service Index**: `binance-ai-traders/services/README.md`
- **Architecture**: `binance-ai-traders/AGENTS.md`

---

**Last Updated**: 2025-10-18  
**Status**: Planned - Specification complete, awaiting backend APIs  
**Priority**: Medium - After critical service implementations

