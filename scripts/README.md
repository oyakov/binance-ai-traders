Scripts Overview

- Location: PowerShell scripts live in `scripts/` (Windows). Bash scripts remain in `docs/scripts/` (Linux/macOS).
- Usage: Run from repo root (paths inside scripts assume repo root).

Common tasks

- Health and monitoring
  - `scripts/health-monitor.ps1` — Continuous health checks
  - `scripts/monitor_testnet.ps1` — Testnet monitoring
  - `scripts/start-grafana-monitoring.ps1` — Start standalone Grafana+Prometheus
  - `scripts/start-kline-monitoring.ps1` — Start monitoring essentials
  - `scripts/start-kline-monitoring-complete.ps1` — Start full monitoring stack
  - `scripts/simple-kline-monitor.ps1` — Minimal monitoring
  - `scripts/monitor-kline-collection.ps1` — Watch kline collection

- Dashboards
  - `scripts/import-kline-dashboards.ps1` — Import curated kline dashboards
  - `scripts/import-dashboards-simple.ps1` — Create basic datasource + hints
  - `scripts/import-dashboards-api.ps1` — API-focused dashboards
  - `scripts/create-demo-dashboard.ps1` — Demo dashboard
  - `scripts/test-dashboard-data.ps1` — Smoke test dashboard ingress

- Testing and utilities
  - `scripts/test-kline-collection.ps1` — Validate kline collection
  - `scripts/test-kline-storage.ps1` — Validate storage path
  - `scripts/generate-test-metrics.ps1` — Emit sample metrics
  - `scripts/health-api.ps1` — Hit health endpoints
  - `scripts/test-api-keys.ps1` — Validate Binance keys (Windows)

- Operations — strategies and testnet
  - `scripts/launch_strategies.ps1` — Launch strategies
  - `scripts/monitor_strategies.ps1` — Monitor strategies
  - `scripts/testnet_long_term_monitor.ps1` — Long horizon monitoring
  - `scripts/monitor_testnet.ps1` — Testnet monitor
  - `scripts/start-health-server.ps1` — Start health server helper

Examples

- Start testnet stack and import dashboards
  - `docker-compose -f docker-compose-testnet.yml up -d`
  - `./scripts/import-kline-dashboards.ps1`

- Monitor testnet continuously
  - `./scripts/monitor_testnet.ps1 -IntervalSeconds 30`

Notes

- Run from repo root to keep relative paths valid.
- Bash scripts remain under `docs/scripts/` (e.g., `deploy-testnet.sh`).
