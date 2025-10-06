Scripts Restructuring — January 2025

Summary

- Consolidated all PowerShell scripts into a top-level `scripts/` directory.
- Left Bash scripts in `docs/scripts/` to avoid breaking Linux/macOS workflows.
- Updated infrastructure docs to point to new PowerShell paths.
- Added `scripts/README.md` with categorized usage examples.

Why

- Consistent entry point for Windows operators and agents.
- Reduced confusion between operational scripts and documentation assets.
- Clear separation of platform-specific tooling.

What Moved

- To `scripts/` (PowerShell):
  - `test-kline-storage.ps1`, `test-kline-collection.ps1`, `test-dashboard-data.ps1`
  - `import-dashboards-simple.ps1`, `import-dashboards-api.ps1`, `import-kline-dashboards.ps1`
  - `start-grafana-monitoring.ps1`, `start-kline-monitoring.ps1`, `start-kline-monitoring-complete.ps1`, `simple-kline-monitor.ps1`
  - `monitor-kline-collection.ps1`, `generate-test-metrics.ps1`, `create-demo-dashboard.ps1`, `health-api.ps1`
  - From `docs/scripts/`: `health-monitor.ps1`, `monitor_testnet.ps1`, `testnet_long_term_monitor.ps1`, `launch_strategies.ps1`, `monitor_strategies.ps1`, `test-trading-functionality.ps1`, `test-api-keys.ps1`, `start-health-server.ps1`

- Remain in `docs/scripts/` (Bash):
  - `deploy-testnet.sh`, `docker-test.sh`, `run-enhanced-tests.sh`, `performance-test.sh`, `health-check-test.sh`, `test-api-keys.sh`

Updated References

- `docs/infrastructure/README.md`: use `./scripts/health-monitor.ps1`, `./scripts/monitor_testnet.ps1`.
- `docs/infrastructure/docker-compose-consolidation.md`: updated script paths in headings and examples.
- `docs/infrastructure/quick-reference.md`: updated monitoring and API key examples.
- `README.md`: added links to `scripts/README.md` (PowerShell) and kept `docs/scripts/README.md` (Bash).

How To Use (Windows)

- From repo root:
  - `./scripts/monitor_testnet.ps1 -IntervalSeconds 30`
  - `./scripts/import-kline-dashboards.ps1`
  - `./scripts/launch_strategies.ps1 -LaunchAll`

Notes

- Run PowerShell scripts from the repository root to ensure relative paths resolve correctly.
- If you had local shortcuts to `docs/scripts/*.ps1`, update them to `scripts/*.ps1`.
