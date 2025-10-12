# Matrix Portal UI Specification

## 1. Purpose and Scope
This document defines the requirements for the Matrix-themed web portal that will serve as the unified user interface for the Binance AI Traders platform. The specification covers visual design, information architecture, functional modules, data integrations, and deployment expectations so the UI team can deliver an implementation-ready design. The portal must run as a dedicated JavaScript-based service within the wider Docker Compose ecosystem.

## 2. High-Level Goals
- Provide a cohesive control center for monitoring and operating all automated trading services.
- Surface real-time health, operational, and market data sourced from existing platform databases and services.
- Allow authorized users to dynamically manage trading strategies persisted in PostgreSQL without manual database edits or service restarts.
- Maintain a consistent dark theme with neon green highlights, evoking the "Matrix" aesthetic while prioritizing readability and accessibility.

## 3. Deployment & Technology Requirements
- **Service Container**: Package the UI as a standalone container (e.g., `matrix-ui-portal`) that can be added to the primary `docker-compose.yml`. The container must expose the web app on port 3000 by default.
- **Runtime**: Use a JavaScript SPA framework (React with Vite or Next.js in static export mode preferred). Styling can be implemented with Tailwind CSS, Chakra UI, or custom SCSS, provided theme guidelines are satisfied.
- **State Management**: Utilize a predictable state layer (Redux Toolkit, Zustand, or React Query) to handle shared data and server synchronization.
- **API Integration**: Communicate with backend services through REST or WebSocket endpoints exposed inside the Compose network. All endpoints must be configurable via environment variables injected at container runtime.
- **Security**: Support JWT-based authentication headers and provide a stub for role-based authorization to gate control actions.

## 4. Information Architecture & Navigation
- **Global Layout**: Full-width application with fixed top navigation, collapsible left-side context panel (optional), and a primary content canvas. The background should be near-black (#050607) with subtle animated matrix code or particle effects that can be toggled for performance.
- **Top Menu Pane**: Horizontal menu with selectable tabs for the four primary views. Active tab should glow neon green (#00FF7F) with a soft outer glow. Hover states should lighten text and reveal underline accent.
    1. **System Health Dashboard**
    2. **System Operational Dashboard**
    3. **Control Board**
    4. **Live Chart Board**
- **Responsive Behavior**: Provide responsive breakpoints for desktop (≥1280px), tablet (768–1279px), and mobile (≤767px). On smaller screens, convert the top menu to a hamburger-triggered drawer while preserving color scheme and quick navigation.

## 5. Visual & Branding Guidelines
- **Primary Colors**: 
  - Background: #050607
  - Primary Glow: #00FF7F
  - Secondary Accents: #14B866, #0B8F4D
  - Text: #E8FFE8 for headings, #9EF4C7 for body text, #6CCF99 for muted text
- **Typography**: Use a monospaced or techno-styled font (e.g., "IBM Plex Mono", "Fira Code") for headings, paired with a clean sans-serif (e.g., "Inter") for body content. Ensure WCAG AA contrast compliance.
- **Effects**: Subtle glows, radial gradients, and animated lines may be used sparingly. Provide a global toggle for reduced motion to accommodate accessibility needs.
- **Iconography**: Utilize thin-line neon icons. Prefer SVG assets with green strokes and transparent backgrounds.

## 6. Functional Modules
### 6.1 System Health Dashboard
- **Purpose**: Summarize the overall health of infrastructure components.
- **Data Sources**: Prometheus/Grafana exporters, service health endpoints, PostgreSQL heartbeat tables.
- **Widgets**:
  - *Cluster Status Tiles*: For each core service (data collection, storage, trader-macd, trader-grid, messaging, DB), display status (Healthy, Degraded, Offline) with timestamp and latency metrics.
  - *Alerts Stream*: Scrollable list of the latest Prometheus or Grafana alerts with severity badges.
  - *Resource Gauges*: CPU, memory, disk usage gauges for critical hosts/containers with warning thresholds.
  - *Connectivity Heatmap*: Visualizing inter-service connectivity or Kafka topic lag indicators.
- **Interactions**: Hover to reveal metadata, click to expand into detailed modal containing historical trends and troubleshooting links.

### 6.2 System Operational Dashboard
- **Purpose**: Provide visibility into trading throughput, data pipeline performance, and task execution.
- **Data Sources**: PostgreSQL aggregated views, Kafka metrics, application telemetry APIs.
- **Widgets**:
  - *Throughput Timeline*: Line charts for orders executed, messages processed, and alerts triggered over selected periods.
  - *Latency & Lag Panel*: Real-time Kafka consumer lag, API response times, and queue depths.
  - *Job Status Table*: Current ETL/backfill jobs with progress, ETA, and operator notes.
  - *Environment Selector*: Dropdown to toggle between dev/testnet/production metrics (assuming backend support).
- **Interactions**: Time range picker (15m, 1h, 24h, custom), auto-refresh controls, drill-down modals referencing raw records.

### 6.3 Control Board
- **Purpose**: Manage trading strategies that are persisted in PostgreSQL and orchestrated by backend services.
- **Functional Requirements**:
  - Fetch list of deployed strategies from a dedicated API backed by the `strategies` table. Each record must include strategy ID, symbol, kline interval, strategy type (`grid` | `macd` | future extensions), deployment status, and strategy-specific parameters stored as JSONB.
  - Provide controls to enable/disable (load/unload) individual strategies. Trigger backend API calls to update strategy state; UI must optimistically update while showing loading indicators.
  - Support creation and editing flows with form validation. Parameters should be dynamically rendered based on strategy type (e.g., grid spacing, MACD fast/slow EMA lengths).
  - Include bulk actions (enable all, disable all) with confirmation dialogues and audit logging integration.
  - Surface activity logs referencing who made changes and when (requires integration with auth metadata).
- **UI Elements**:
  - *Strategies Table*: Filterable, searchable, and sortable by symbol, type, status, and interval.
  - *Strategy Detail Drawer*: Slide-over panel with full parameter set, historical performance snapshots, and control buttons.
  - *Create/Edit Wizard*: Multi-step modal collecting symbol selection, interval selection (1m, 5m, 15m, etc.), strategy type, and parameter inputs.

### 6.4 Live Chart Board
- **Purpose**: Visualize live market data per deployed strategy.
- **Requirements**:
  - For each active strategy, render a chart card containing kline candlestick data and MACD overlay derived from the PostgreSQL datasets. Charts should update in near real-time (≤5s refresh) using WebSockets or server-sent events when available.
  - Allow multi-chart grid layout with drag-and-drop repositioning and the ability to pin favorites to top.
  - Provide crosshair inspection showing OHLC values, MACD line, signal line, and histogram at the hovered timestamp.
  - Include data freshness indicator (timestamp, color-coded staleness) and fallback messaging when data lags.
  - Offer export options (PNG, CSV of displayed range) and quick links to corresponding strategy detail drawer.
- **Charting Library**: Recommend `Lightweight Charts`, `Recharts`, or `ECharts` with custom theme overrides matching the Matrix palette.

## 7. Data Integration & Contracts
- **PostgreSQL**:
  - Strategies stored in `trading.strategies` table: fields include `id (UUID)`, `symbol (TEXT)`, `interval (TEXT)`, `strategy_type (TEXT)`, `parameters (JSONB)`, `status (TEXT)`, `created_at`, `updated_at`.
  - Market data accessible via `market_data.klines` and `market_data.macd` views filtered by symbol + interval.
- **API Endpoints** (to be exposed by backend services; UI must support configurable base URLs):
  - `GET /api/health/summary` → health dashboard aggregate
  - `GET /api/operations/metrics` with query params for `range`, `environment`
  - `GET /api/strategies` → list strategies with query filters
  - `POST /api/strategies` → create strategy
  - `PUT /api/strategies/{id}` → update strategy metadata or parameters
  - `POST /api/strategies/{id}/activate` → load strategy
  - `POST /api/strategies/{id}/deactivate` → unload strategy
  - `GET /api/strategies/{id}/history` → historical performance snapshot
  - `GET /api/market-data/klines` with `symbol`, `interval`, `from`, `to`
  - `GET /api/market-data/macd` with `symbol`, `interval`, `from`, `to`
  - `WS /api/stream/market-data` → push updates for klines + MACD per subscribed strategy
- **Caching & Refresh**: Implement client-side caching with invalidation triggered after control actions or when data staleness exceeds configured threshold.

## 8. User Roles & Permissions
- **Viewer**: Read-only access to dashboards and live charts.
- **Operator**: Viewer permissions plus ability to enable/disable strategies.
- **Strategist**: Operator permissions plus create/edit strategy configurations.
- **Admin**: Strategist permissions plus access to system settings and audit logs.
- UI must reflect permissions by disabling or hiding controls the user lacks rights for, showing tooltip explanations when disabled.

## 9. Accessibility & UX Considerations
- Provide keyboard navigation for all interactive components. Ensure focus states are clearly visible with neon outlines.
- Support screen readers with ARIA roles and descriptive labels for all charts, buttons, and status indicators.
- Offer light/dark toggle fallback (optional) while keeping Matrix theme default.
- Include session timeout warnings and autosave drafts for unfinished strategy edits.

## 10. Telemetry & Observability
- Instrument the UI with front-end telemetry (e.g., OpenTelemetry JS or custom logging) to capture navigation events, API error rates, and user interactions with control actions.
- Expose health endpoint (`/healthz`) and metrics endpoint (`/metrics`) from the UI container for uptime monitoring.
- Log critical user actions (strategy activation/deactivation, creations, edits) with timestamps and user IDs to forward to centralized logging.

## 11. Non-Functional Requirements
- **Performance**: Initial load time ≤3 seconds on a 20 Mbps connection; subsequent navigation should be instant due to client-side routing.
- **Scalability**: Architecture should accommodate ≥50 concurrent sessions with minimal degradation.
- **Reliability**: Handle backend downtime gracefully with retry messaging, offline banners, and queued actions where possible.
- **Localization**: Prepare UI strings for future i18n by storing text in a translation layer (e.g., i18next).

## 12. Open Questions & Follow-Up Tasks
- Confirm authentication provider and obtain token exchange flow requirements.
- Determine whether backend services already expose required endpoints or if new APIs must be built.
- Validate chart data retention periods and maximum lookback window per strategy.
- Align on audit logging schema shared between UI and backend for strategy lifecycle events.
- Decide whether the Matrix visual effects should be user-configurable profiles stored per account.

---
**Last Updated**: 2025-01-12
**Owner**: UI/UX Working Group
