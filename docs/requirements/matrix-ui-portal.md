# matrix-ui-portal Application Requirements

## Application overview
Matrix UI Portal is a lightweight React + Vite frontend that surfaces operational dashboards for the trading system. It polls Prometheus for key metrics and provides tabbed navigation placeholders for future operational, control, and charting views.【F:matrix-ui-portal/src/main.tsx†L1-L62】

## Functional scope
- **Prometheus integration**: Queries configurable Prometheus endpoints (default `/prometheus`) for kline save rates and service health, updating the dashboard every five seconds.【F:matrix-ui-portal/src/main.tsx†L4-L34】
- **Tabbed workspace**: Renders tabs for System Health, Operations, Control Board, and Live Charts, each hosted within the same SPA layout to simplify expansion as backend capabilities grow.【F:matrix-ui-portal/src/main.tsx†L35-L55】
- **System health panel**: Displays storage status (UP/DOWN) and recent kline save throughput derived from Prometheus metrics, along with the effective Prometheus base URL for troubleshooting.【F:matrix-ui-portal/src/main.tsx†L45-L51】
- **Stub views**: Operations, Control Board, and Live Charts tabs currently render placeholder copy outlining intended future functionality (throughput/latency charts, strategy management forms, MACD overlays).【F:matrix-ui-portal/src/main.tsx†L52-L55】

## Configuration contract
- Accepts a `VITE_PROM_URL` build-time environment variable to override the default Prometheus base path; fallback `/prometheus` allows reverse-proxy setups without code changes.【F:matrix-ui-portal/src/main.tsx†L4-L8】
- Additional dashboards should follow the same tab pattern and fetch metrics via `promQuery` to centralize error handling.

## Observability requirements
- Frontend should surface fetch failures (currently swallowed) through user-facing alerts/logging when production-hardening the UI; consider integrating Sentry or browser console logging during development.
- Keep polling interval configurable if the dashboard expands to heavier queries.

## Known gaps & TODOs
- Replace stub content with actual components once backend APIs/metrics are available for operations, strategy control, and charting.
- Add authentication and role-based access controls before exposing in production environments.
- Implement responsive styling and error states for Prometheus connectivity issues.
