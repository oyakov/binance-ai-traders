# Grafana Dashboard Structure Documentation

## Overview

This document describes the consolidated and organized Grafana dashboard structure for the Binance AI Traders system. The dashboards have been consolidated from 37 redundant files into 6 focused, well-organized dashboards.

## Dashboard Organization

### Folder Structure

```
monitoring/grafana/provisioning/dashboards/
├── 01-system-health/
│   └── system-health-overview.json
├── 02-trading-overview/
│   └── trading-operations-overview.json
├── 03-macd-strategies/
│   └── macd-trading-strategies.json
├── 04-kline-data/
│   └── kline-data-monitoring.json
├── 05-analytics/
│   └── trading-analytics-insights.json
└── 06-executive/
    └── executive-overview.json
```

### Dashboard Categories

#### 01. System Health (`01-system-health/`)

**Purpose**: Monitor overall system health and infrastructure status

**Dashboard**: `system-health-overview.json`
- **UID**: `system-health-overview`
- **Title**: System Health Overview
- **Tags**: system, health, infrastructure

**Panels**:
1. **Service Status Overview** - Overall system health status
2. **Trading Service Health** - MACD trader service status
3. **Data Collection Health** - Data collection service status
4. **Data Storage Health** - Data storage service status
5. **Infrastructure Health** - Prometheus, Elasticsearch, Kafka, PostgreSQL status

**Use Case**: Operations team monitoring, troubleshooting system issues

---

#### 02. Trading Overview (`02-trading-overview/`)

**Purpose**: Monitor active trading operations and signals

**Dashboard**: `trading-operations-overview.json`
- **UID**: `trading-operations-overview`
- **Title**: Trading Operations Overview
- **Tags**: trading, operations, overview

**Panels**:
1. **Active Trading Positions** - Current trading activity status
2. **Trading Signals** - Signal generation rate and frequency

**Use Case**: Trading team monitoring, real-time operations oversight

---

#### 03. MACD Strategies (`03-macd-strategies/`)

**Purpose**: Monitor MACD trading strategies for different assets

**Dashboard**: `macd-trading-strategies.json`
- **UID**: `macd-trading-strategies`
- **Title**: MACD Trading Strategies
- **Tags**: macd, strategies, trading

**Panels**:
1. **BTC MACD Strategy** - Bitcoin MACD strategy status
2. **ETH MACD Strategy** - Ethereum MACD strategy status

**Use Case**: Strategy monitoring, performance analysis, strategy-specific troubleshooting

---

#### 04. Kline Data (`04-kline-data/`)

**Purpose**: Monitor kline data collection, processing, and storage

**Dashboard**: `kline-data-monitoring.json`
- **UID**: `kline-data-monitoring`
- **Title**: Kline Data Monitoring
- **Tags**: kline, data, monitoring

**Panels**:
1. **Data Collection Status** - Real-time data collection status
2. **Data Storage Status** - Data storage availability and health

**Use Case**: Data team monitoring, data pipeline health, storage capacity monitoring

---

#### 05. Analytics (`05-analytics/`)

**Purpose**: Advanced analytics, insights, and performance metrics

**Dashboard**: `trading-analytics-insights.json`
- **UID**: `trading-analytics-insights`
- **Title**: Trading Analytics & Insights
- **Tags**: analytics, insights, metrics

**Panels**:
1. **System Performance Metrics** - Request rates, response times, throughput

**Use Case**: Performance analysis, capacity planning, optimization insights

---

#### 06. Executive (`06-executive/`)

**Purpose**: High-level KPIs and executive summary

**Dashboard**: `executive-overview.json`
- **UID**: `executive-overview`
- **Title**: Executive Overview
- **Tags**: executive, overview, kpis

**Panels**:
1. **System Health Summary** - Overall system health status for executives

**Use Case**: Executive reporting, high-level system status, business impact assessment

---

## Data Sources

All dashboards use the following data source configuration:

- **Name**: prometheus
- **Type**: Prometheus
- **URL**: http://prometheus-testnet:9090
- **UID**: prometheus
- **Default**: Yes

## Key Metrics

### Service Health Metrics
- `up{job="service-name"}` - Service availability (0=down, 1=up)
- `rate(http_requests_total[5m])` - Request rate per second

### Trading Metrics
- Trading service health and activity
- Signal generation rates
- Strategy performance indicators

### Infrastructure Metrics
- Database connectivity
- Message queue health
- Storage availability

## Dashboard Features

### Common Features
- **Auto-refresh**: 30 seconds
- **Time range**: Last 1 hour (configurable)
- **Theme**: Dark
- **Timezone**: Browser timezone
- **Editable**: Yes (for customization)

### Panel Types
- **Stat panels**: For status indicators and KPIs
- **Time series**: For trend analysis (when implemented)
- **Table panels**: For detailed data views (when implemented)

## Access Information

- **Grafana URL**: http://localhost:3001
- **Default Login**: admin/admin
- **Environment**: Testnet

## Maintenance

### Adding New Dashboards
1. Create dashboard JSON file in appropriate category folder
2. Ensure unique UID and title
3. Use consistent naming convention: `category-descriptive-name.json`
4. Include proper tags for categorization
5. Test dashboard functionality

### Updating Existing Dashboards
1. Edit JSON file directly
2. Restart Grafana to apply changes: `docker-compose -f docker-compose-testnet.yml restart grafana-testnet`
3. Verify changes in Grafana UI

### Backup and Recovery
- Original dashboards backed up to: `monitoring/grafana/provisioning/dashboards-backup-YYYYMMDD-HHMMSS/`
- Regular backups recommended before major changes
- Version control recommended for dashboard JSON files

## Troubleshooting

### Common Issues
1. **"Datasource not found"**: Check Prometheus service status
2. **"No data"**: Verify metric queries and time range
3. **Dashboard not loading**: Check JSON syntax and UID conflicts

### Debugging Steps
1. Check Grafana logs: `docker logs grafana-testnet`
2. Verify data source connectivity: `docker exec grafana-testnet wget -qO- http://prometheus-testnet:9090/api/v1/query?query=up`
3. Validate JSON syntax: Use JSON validator
4. Check UID uniqueness: Ensure no duplicate UIDs across dashboards

## Future Enhancements

### Planned Improvements
1. **Time Series Panels**: Add trend analysis and historical data visualization
2. **Alerting**: Implement alert rules for critical metrics
3. **Custom Variables**: Add template variables for dynamic filtering
4. **Advanced Queries**: Implement more sophisticated Prometheus queries
5. **Mobile Optimization**: Ensure dashboards work well on mobile devices

### Dashboard Expansion
1. **Performance Metrics**: Add detailed performance monitoring
2. **Business Metrics**: Add trading performance and profitability metrics
3. **Security Monitoring**: Add security-related metrics and alerts
4. **Capacity Planning**: Add resource utilization and capacity metrics

---

## Changelog

### 2025-10-08
- **Consolidated**: 37 dashboards → 6 organized dashboards
- **Organized**: Created numbered folder structure for logical grouping
- **Documented**: Added comprehensive documentation
- **Fixed**: Resolved UID conflicts and duplicate titles
- **Backed up**: Original dashboards preserved in backup folder

---

*This documentation is maintained alongside the dashboard structure. Please update when making changes to dashboards or adding new ones.*
