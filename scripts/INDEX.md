# Scripts Index

Comprehensive index of all automation scripts in the Binance AI Traders project.

**Total Scripts**: 87 PowerShell (.ps1), 7 SQL (.sql), 6 Python (.py)

**Location**: All scripts are in the `scripts/` directory at repository root.

**Usage**: Run from repository root to ensure relative paths work correctly.

## Quick Navigation

- [Monitoring & Health](#monitoring--health)
- [Dashboards & Grafana](#dashboards--grafana)
- [Testing & Validation](#testing--validation)
- [Kline Data Operations](#kline-data-operations)
- [Backfill Operations](#backfill-operations)
- [Metrics & Metrics Validation](#metrics--metrics-validation)
- [Build & Development](#build--development)
- [Strategy Operations](#strategy-operations)
- [Storage Operations](#storage-operations)
- [SQL Diagnostics](#sql-diagnostics)
- [Cleanup & Maintenance](#cleanup--maintenance)

## Monitoring & Health

### General Monitoring
- `health-monitor.ps1` - Continuous health checks for all services
- `monitor_testnet.ps1` - Comprehensive testnet monitoring
- `system-health-monitor.ps1` - System-wide health monitoring
- `comprehensive-health-metrics.ps1` - Aggregate health metrics collection
- `start-health-server.ps1` - Start standalone health metrics server
- `health-api.ps1` - Health API interaction utility
- `health-api-service.ps1` - Health API service wrapper

### Health Check Variants
- `working-health-check.ps1` - Known working health check implementation
- `health-check-simple.ps1` - Simplified health check
- `health-check-corrected.ps1` - Corrected health check version
- `health-check-final.ps1` - Final health check implementation
- `final-health-check.ps1` - Alternative final health check
- `final-health-solution.ps1` - Comprehensive health solution
- `http-health-check.ps1` - HTTP-based health checking
- `health-check-postgres-kafka.ps1` - PostgreSQL and Kafka health checks

### Specialized Monitoring
- `monitoring/open-monitoring.ps1` - Open all monitoring dashboards
- `monitoring/start-grafana-monitoring.ps1` - Start Grafana monitoring stack
- `start-kline-monitoring.ps1` - Start kline-specific monitoring
- `start-kline-monitoring-complete.ps1` - Complete kline monitoring stack
- `simple-kline-monitor.ps1` - Lightweight kline monitor
- `monitor-kline-collection.ps1` - Monitor kline collection process
- `monitor-trading-data.ps1` - Monitor trading data flow
- `health-monitoring-final.ps1` - Final health monitoring solution
- `start-complete-health-monitoring.ps1` - Start complete health monitoring

## Dashboards & Grafana

### Dashboard Management
- `import-kline-dashboards.ps1` - Import curated kline dashboards
- `import-dashboards-simple.ps1` - Simple dashboard import (datasource + hints)
- `import-dashboards-api.ps1` - API-focused dashboard imports
- `import-grafana-dashboards.ps1` - General Grafana dashboard import
- `import-grafana-dashboards-simple.ps1` - Simplified Grafana import
- `create-demo-dashboard.ps1` - Create demonstration dashboard
- `test-dashboard-data.ps1` - Smoke test dashboard data ingestion

### Dashboard Setup & Enhancement
- `monitoring/setup-dashboard-simple.ps1` - Simple dashboard setup
- `monitoring/setup-comprehensive-dashboard.ps1` - Comprehensive dashboard setup
- `enhance-grafana-dashboards.ps1` - Enhance existing dashboards
- `enhance-grafana-dashboards-simple.ps1` - Simple dashboard enhancements

### Dashboard Utilities
- `analyze-dashboards.ps1` - Analyze dashboard configurations
- `consolidate-dashboards.ps1` - Consolidate duplicate dashboards
- `fix-grafana-dashboards.ps1` - Fix broken dashboard definitions
- `fix-dashboard-json.ps1` - Fix dashboard JSON syntax
- `fix-all-dashboards.ps1` - Bulk dashboard fixes
- `cleanup-grafana-folders.ps1` - Clean up Grafana folder structure
- `verify-grafana-dashboards.ps1` - Verify dashboard integrity
- `verify-grafana-simple.ps1` - Simple dashboard verification
- `test-grafana-table.ps1` - Test Grafana table panels

## Testing & Validation

### Comprehensive Test Suites
- `run-comprehensive-tests.ps1` - Run Newman/Postman comprehensive test suites
- `run-comprehensive-health-tests.ps1` - Comprehensive health test suite
- `run-postgres-kafka-tests.ps1` - PostgreSQL and Kafka integration tests

### Simple Tests
- `tests/quick-test.ps1` - Quick smoke test (working)
- `tests/test-simple.ps1` - Simple system test (working)
- `tests/test-basic.ps1` - Basic test suite (has syntax errors)
- `run-tests-basic.ps1` - Basic test runner
- `run-tests-simple.ps1` - Simple test runner
- `run-tests-fixed.ps1` - Fixed test runner

### API & Functionality Tests
- `test-api-keys.ps1` - Validate Binance API keys (Windows)
- `test-trading-functionality.ps1` - Test trading functionality
- `test-postgres-kafka.ps1` - PostgreSQL/Kafka connectivity tests

## Kline Data Operations

### Kline Testing
- `kline/test-kline-api.ps1` - Test kline API endpoints
- `kline/test-kline-final.ps1` - Final kline test implementation
- `kline/test-kline-simple.ps1` - Simple kline tests
- `kline/test-kline-system.ps1` - System-wide kline tests
- `kline/test-kline-working.ps1` - Known working kline tests
- `kline/simple-kline-test.ps1` - Minimal kline test
- `test-kline-collection.ps1` - Test kline collection process
- `test-kline-storage.ps1` - Test kline storage functionality
- `check-kline-data.ps1` - Check kline data integrity

## Backfill Operations

### Backfill Scripts (backfill/)
- `backfill/backfill_klines.py` - Python script to backfill kline data
- `backfill/generate_sample_dataset.ps1` - Generate sample datasets
- `backfill/load_csv_to_postgres.py` - Load CSV data into PostgreSQL

### Root Level Backfill
- `backfill_rest.ps1` - REST-based backfill operations
- `backfill-historical-klines.ps1` - PowerShell historical kline backfill
- `backfill-historical-klines.py` - Python historical kline backfill
- `quick-backfill.ps1` - Quick backfill utility

## Metrics & Metrics Validation

### Metrics Validation (metrics/)
- `metrics/check-metrics.ps1` - Check metrics endpoints
- `metrics/verify-metrics-simple.ps1` - Simple metrics verification
- `metrics/verify-metrics-config.ps1` - Verify metrics configuration

### Metrics Generation
- `generate-test-metrics.ps1` - Generate test metrics data
- `metrics/generate-test-metrics-services.ps1` - Generate service-specific test metrics
- `simple-health-metrics.ps1` - Simple health metrics collection
- `infrastructure-metrics-exporter.ps1` - Export infrastructure metrics

## Build & Development

### Build Acceleration (build/)
- `build/build-data-collection-fast.ps1` - Fast build for data-collection service

### Testing Environment
- `setup-testing-environment.ps1` - Set up complete testing environment

## Strategy Operations

### Strategy Management
- `launch_strategies.ps1` - Launch trading strategies
- `monitor_strategies.ps1` - Monitor running strategies
- `disable-adausdt-strategy.ps1` - Disable specific ADAUSDT strategy

### Long-term Monitoring
- `testnet_long_term_monitor.ps1` - Long-term testnet monitoring

## Storage Operations

### Storage Testing (storage/)
- `storage/test-storage-fix.ps1` - Test storage fixes

## SQL Diagnostics

### SQL Scripts (sql-diagnostics/)
- `sql-diagnostics/01-database-health-check.sql` - Database health check queries
- `sql-diagnostics/02-kline-data-analysis.sql` - Kline data analysis queries
- `sql-diagnostics/03-performance-monitoring.sql` - Performance monitoring queries
- `sql-diagnostics/README.md` - SQL diagnostics documentation
- `sql-diagnostics/run-all-diagnostics.ps1` - Run all SQL diagnostic scripts

### SQL Backfill (sql/)
- `sql/_rest_backfill.sql` - REST backfill SQL operations
- `sql/backfill_1d.sql` - 1-day interval backfill
- `sql/backfill_1w.sql` - 1-week interval backfill
- `sql/backfill_3d.sql` - 3-day interval backfill

## Cleanup & Maintenance

### Cleanup Operations
- `quick-cleanup.ps1` - Quick cleanup utility
- `cleanup-and-restart.ps1` - Cleanup and restart services
- `cleanup-grafana-folders.ps1` - Clean up Grafana folders

## Python Utilities

### Health & Metrics
- `health-metrics-server.py` - Standalone health metrics server
- `health-metrics-server-docker.py` - Docker-compatible health metrics server

### Dashboard Management
- `fix_dashboards.py` - Python script to fix dashboard issues

### Memory Management
- `binance-ai-traders/memory/memory-manager.py` - Memory system management utility

## Configuration Files

### Docker & NGINX
- `Dockerfile.health-metrics` - Dockerfile for health metrics server
- `health-exporter-nginx.conf` - NGINX configuration for health exporter

### Documentation
- `quick-fixes.md` - Quick fixes and workarounds documentation
- `health-metrics.txt` - Health metrics documentation
- `health-metrics.sh` - Bash script for health metrics (legacy)

## Usage Examples

### Start Monitoring Stack
```powershell
# From repository root
./scripts/monitoring/open-monitoring.ps1
```

### Run Comprehensive Tests
```powershell
./scripts/run-comprehensive-tests.ps1
```

### Monitor Testnet
```powershell
./scripts/monitor_testnet.ps1 -IntervalSeconds 30
```

### Backfill Historical Data
```powershell
./scripts/quick-backfill.ps1
```

### Verify Metrics
```powershell
./scripts/metrics/verify-metrics-simple.ps1
```

## Notes

- **Working Scripts**: Most scripts are functional, but `tests/test-basic.ps1` has known syntax errors
- **Run Location**: Always run from repository root for correct path resolution
- **Bash Scripts**: Linux/macOS bash scripts are in `docs/scripts/` directory
- **Dependencies**: Some scripts require Newman (Postman CLI), Docker, PowerShell 7+
- **Environment**: Scripts support dev, testnet, and production environments

## Related Documentation

- **Main Scripts README**: `scripts/README.md`
- **Deployment Scripts**: `docs/scripts/README.md` (bash)
- **Monitoring Guide**: `binance-ai-traders/monitoring/MONITORING_GUIDE.md`
- **Testing Guide**: `binance-ai-traders/test-plan-comprehensive-system-testing.md`

---

**Last Updated**: 2025-10-18  
**Total Count**: 100+ files (87 PS1, 7 SQL, 6 Python, plus configs and docs)

