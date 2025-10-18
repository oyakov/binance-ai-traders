# Grafana Dashboard Inventory

Comprehensive inventory of all Grafana dashboards in the Binance AI Traders project.

**Last Updated**: 2025-10-18  
**Location**: `monitoring/grafana/provisioning/dashboards/`

## Dashboard Count

**Total Dashboards**: 8 JSON files across 10 categories

## Dashboard Categories

### 01 - System Health
- **system-health-overview.json**
  - **Purpose**: Overall system health monitoring
  - **Panels**: Service status, uptime, error rates
  - **Datasource**: Prometheus

### 02 - Trading Overview
- **Status**: No dashboard files (directory exists)
- **Purpose**: High-level trading activity overview
- **Planned Panels**: Trading volume, order counts, win rates

### 03 - MACD Strategies
- **Status**: No dashboard files (directory exists)
- **Purpose**: MACD strategy-specific monitoring
- **Planned Panels**: MACD signals, strategy performance, position tracking

### 04 - Kline Data
- **kline-data-monitoring.json**
  - **Purpose**: Kline data collection and storage monitoring
  - **Panels**: Kline ingestion rates, data freshness, storage metrics
  - **Datasource**: Prometheus + PostgreSQL

- **kline-data-monitoring-v2.json**
  - **Purpose**: Enhanced kline data monitoring (v2)
  - **Panels**: Improved visualizations, additional metrics
  - **Datasource**: Prometheus + PostgreSQL

### 05 - Analytics
- **Status**: No dashboard files (directory exists)
- **Purpose**: Trading analytics and insights
- **Planned Panels**: Performance analytics, trend analysis

### 05 - MACD Indicators
- **Status**: No dashboard files (directory exists)
- **Purpose**: MACD indicator calculations and values
- **Planned Panels**: MACD line, signal line, histogram, EMA values

### 06 - Executive
- **Status**: No dashboard files (directory exists)
- **Purpose**: Executive-level summary dashboard
- **Planned Panels**: Key metrics, high-level performance, alerts summary

### 07 - Trading Performance
- **order-profitability-dashboard.json**
  - **Purpose**: Order and profitability monitoring
  - **Panels**: 
    - Active positions stat
    - Realized PnL stat
    - Trading signals counter
    - MACD upserts counter
    - PnL over time chart
    - Recent orders table (PostgreSQL)
    - Orders by symbol/status pie charts
    - Buy vs sell volume pie chart
    - Order volume over time bars
    - Total/filled orders stats
    - Trading volume stat
    - Win rate gauge
  - **Datasources**: Prometheus (metrics) + PostgreSQL (orders table)
  - **Access**: `http://localhost:3001/d/order-profitability-dashboard`
  - **Status**: Currently shows 0 orders (testnet not actively trading)

### 08 - Observability
- **strategy-observability-dashboard.json**
  - **Purpose**: Strategy observability and decision tracking
  - **Panels**: Strategy analysis logs, decision logs, portfolio snapshots
  - **Datasource**: PostgreSQL (observability tables)

### 09 - Risk Monitoring
- **risk-dashboard.json**
  - **Purpose**: Risk management monitoring
  - **Panels**: Position sizes, exposure, stop-loss tracking, risk metrics
  - **Datasource**: Prometheus + PostgreSQL

### 10 - Strategy Comparison
- **comparison-dashboard.json**
  - **Purpose**: Side-by-side strategy performance comparison
  - **Panels**: Comparative metrics, performance rankings, strategy benchmarking
  - **Datasource**: PostgreSQL

### Binance Trading (Legacy/Consolidated)
- **comprehensive-metrics-dashboard.json**
  - **Purpose**: Comprehensive metrics dashboard (may be legacy)
  - **Panels**: Various trading and system metrics
  - **Status**: May be consolidated into other dashboards

## Dashboard Provisioning

### Configuration File
- **Location**: `monitoring/grafana/provisioning/dashboards/testnet-dashboards.yml`
- **Purpose**: Defines dashboard provisioning for Grafana
- **Auto-load**: Dashboards automatically loaded on Grafana startup

### Datasources Configuration
- **Location**: `monitoring/grafana/provisioning/datasources/prometheus.yml`
- **Datasources**:
  - Prometheus (uid: prometheus-testnet, url: http://prometheus-testnet:9090)
  - PostgreSQL (uid: postgres-testnet, url: postgres-testnet:5432, database: binance_trader_testnet)

## Dashboard Access

### Testnet Grafana
- **URL**: `http://localhost:3001`
- **Username**: admin
- **Password**: Check docker-compose configuration

### Dev/Test Grafana
- **URL**: `http://localhost:3000`
- **Username**: admin
- **Password**: Check docker-compose configuration

## Dashboard Development

### Creating New Dashboards

1. **Via Grafana UI**:
   - Create dashboard in Grafana UI
   - Export as JSON
   - Save to appropriate category folder
   - Add to provisioning configuration

2. **Via JSON**:
   - Copy existing dashboard as template
   - Modify panels and queries
   - Save to category folder
   - Test with Grafana reload

### Dashboard Structure
```
monitoring/grafana/provisioning/dashboards/
├── 01-system-health/
│   └── system-health-overview.json
├── 02-trading-overview/
├── 03-macd-strategies/
├── 04-kline-data/
│   ├── kline-data-monitoring.json
│   └── kline-data-monitoring-v2.json
├── 05-analytics/
├── 05-macd-indicators/
├── 06-executive/
├── 07-trading-performance/
│   └── order-profitability-dashboard.json
├── 08-observability/
│   └── strategy-observability-dashboard.json
├── 09-risk-monitoring/
│   └── risk-dashboard.json
├── 10-strategy-comparison/
│   └── comparison-dashboard.json
├── binance-trading/
│   └── comprehensive-metrics-dashboard.json
└── testnet-dashboards.yml
```

## Dashboard Metrics Sources

### Prometheus Metrics
- **Service**: binance-trader-macd-testnet:8080/actuator/prometheus
- **Metrics**: 
  - `binance_trader_active_positions`
  - `binance_trader_realized_pnl_quote_asset`
  - `binance_trader_signals_total`
  - `macd_upserts_total`

### PostgreSQL Tables
- **Database**: binance_trader_testnet
- **Tables**:
  - `orders` - Trading orders
  - `klines` - Kline/candlestick data
  - `macd` - MACD indicators
  - `observability.strategy_analysis` - Strategy analysis logs
  - `observability.decision_logs` - Decision tracking
  - `observability.portfolio_snapshots` - Portfolio snapshots

## Dashboard Maintenance

### Updating Dashboards

1. **Stop Grafana**:
   ```bash
   docker compose stop grafana-testnet
   ```

2. **Remove Volume** (if needed for re-provisioning):
   ```bash
   docker volume rm binance-ai-traders_grafana_testnet_data
   ```

3. **Update Dashboard Files**:
   - Edit JSON files in provisioning/dashboards/

4. **Restart Grafana**:
   ```bash
   docker compose up -d grafana-testnet
   ```

### Dashboard Fixes

Use provided scripts:
- `scripts/fix-grafana-dashboards.ps1` - Fix broken dashboards
- `scripts/fix-dashboard-json.ps1` - Fix JSON syntax
- `scripts/verify-grafana-dashboards.ps1` - Verify integrity

## Common Issues

### Dashboard Not Loading
1. Check JSON syntax
2. Verify datasource UIDs match configuration
3. Check Grafana logs: `docker logs grafana-testnet`
4. Verify provisioning path in docker-compose

### Data Not Showing
1. Verify datasource connectivity
2. Check Prometheus scrape targets
3. Verify PostgreSQL connection
4. Check query syntax in panel definitions

### Duplicate Dashboards
- Run `scripts/consolidate-dashboards.ps1` to consolidate

## Dashboard Best Practices

### Naming Conventions
- Use descriptive names
- Include version numbers for iterations (v2, v3)
- Prefix with category number when in numbered folders

### Panel Organization
- Group related metrics
- Use rows for logical sections
- Add panel descriptions
- Set appropriate refresh intervals

### Query Optimization
- Use query caching
- Set appropriate time ranges
- Use variables for flexibility
- Optimize PostgreSQL queries

### Datasource Configuration
- Use datasource UIDs consistently
- Configure in provisioning for automation
- Document required permissions

## Related Documentation

- **Dashboard Structure**: `monitoring/grafana/DASHBOARD_STRUCTURE.md`
- **Monitoring Guide**: `binance-ai-traders/monitoring/MONITORING_GUIDE.md`
- **Metrics Testing**: `binance-ai-traders/monitoring/METRICS_TESTING_SUMMARY.md`
- **Grafana Setup**: `binance-ai-traders/monitoring/GRAFANA_DASHBOARD_SETUP.md`
- **Scripts Index**: `scripts/INDEX.md`

## Scripts for Dashboard Management

### Import & Setup
- `scripts/import-kline-dashboards.ps1`
- `scripts/import-grafana-dashboards.ps1`
- `scripts/monitoring/setup-comprehensive-dashboard.ps1`

### Verification
- `scripts/verify-grafana-dashboards.ps1`
- `scripts/test-dashboard-data.ps1`

### Enhancement
- `scripts/enhance-grafana-dashboards.ps1`
- `scripts/analyze-dashboards.ps1`

---

**Status**: 8 dashboards active, 7 categories awaiting dashboard creation  
**Priority**: Complete dashboards for categories 02, 03, 05-macd-indicators, 06  
**Next Steps**: Create dashboards for empty categories, consolidate legacy dashboards

