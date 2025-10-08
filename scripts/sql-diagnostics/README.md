# SQL Diagnostic Tools Documentation

## Overview

This directory contains comprehensive SQL diagnostic tools for monitoring, analyzing, and troubleshooting the Binance AI Traders database system. These tools provide insights into database health, performance, data quality, and system optimization.

## Tools Available

### 1. Database Health Check (`01-database-health-check.sql`)

**Purpose**: Comprehensive database health monitoring and system overview

**Key Features**:
- Database size and configuration analysis
- Table statistics and row counts
- Index usage efficiency
- Connection monitoring
- Lock analysis
- Query performance metrics
- Vacuum and maintenance statistics
- Disk usage analysis
- System resource monitoring
- Overall health summary

**Usage**:
```bash
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/01-database-health-check.sql
```

### 2. Kline Data Analysis (`02-kline-data-analysis.sql`)

**Purpose**: Deep analysis of kline data for monitoring and validation

**Key Features**:
- Basic kline data statistics
- Symbol and interval breakdown
- Data quality checks (missing/invalid data)
- Price analysis and volatility
- Volume analysis
- Time-based data collection analysis
- Data gap detection
- Price movement analysis
- Recent data validation
- Data completeness assessment
- Performance metrics

**Usage**:
```bash
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/02-kline-data-analysis.sql
```

### 3. Performance Monitoring (`03-performance-monitoring.sql`)

**Purpose**: Database performance analysis and optimization insights

**Key Features**:
- Query performance analysis
- Index efficiency analysis
- Table scan analysis
- Cache hit ratios
- Connection monitoring
- Lock analysis
- Vacuum and maintenance analysis
- Disk I/O analysis
- Memory usage monitoring
- Performance recommendations

**Usage**:
```bash
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/03-performance-monitoring.sql
```

## Quick Start Guide

### Running All Diagnostics

```bash
# Run all diagnostic scripts
for script in 01-database-health-check.sql 02-kline-data-analysis.sql 03-performance-monitoring.sql; do
    echo "=== Running $script ==="
    docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/$script
    echo ""
done
```

### Running Specific Diagnostics

```bash
# Health check only
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/01-database-health-check.sql

# Kline data analysis only
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/02-kline-data-analysis.sql

# Performance monitoring only
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f /path/to/03-performance-monitoring.sql
```

## Database Connection Information

- **Host**: postgres-testnet
- **Port**: 5432
- **Database**: binance_trader_testnet
- **Username**: testnet_user
- **Password**: testnet_password

## Key Metrics to Monitor

### Database Health Metrics
- **Connection Count**: Monitor active connections
- **Lock Status**: Check for blocked queries
- **Cache Hit Ratio**: Should be > 90%
- **Dead Tuple Ratio**: Should be < 10%
- **Query Performance**: Monitor slow queries

### Kline Data Metrics
- **Data Freshness**: Last update time
- **Data Completeness**: Missing time periods
- **Data Quality**: Invalid or missing values
- **Volume Trends**: Trading volume patterns
- **Price Volatility**: Market volatility analysis

### Performance Metrics
- **Query Execution Time**: Monitor slow queries
- **Index Usage**: Ensure indexes are being used
- **Disk I/O**: Monitor read/write performance
- **Memory Usage**: Buffer cache utilization
- **Vacuum Frequency**: Maintenance schedule

## Troubleshooting Common Issues

### 1. High Connection Count
```sql
-- Check active connections
SELECT state, COUNT(*) FROM pg_stat_activity 
WHERE datname = 'binance_trader_testnet' 
GROUP BY state;
```

### 2. Slow Queries
```sql
-- Find slow queries
SELECT query, calls, total_time, mean_time 
FROM pg_stat_statements 
ORDER BY total_time DESC 
LIMIT 10;
```

### 3. Data Quality Issues
```sql
-- Check for data quality problems
SELECT 
    COUNT(*) as total_klines,
    SUM(CASE WHEN open IS NULL OR high IS NULL OR low IS NULL OR close IS NULL THEN 1 ELSE 0 END) as null_prices,
    SUM(CASE WHEN volume IS NULL OR volume <= 0 THEN 1 ELSE 0 END) as invalid_volumes
FROM kline;
```

### 4. Missing Data
```sql
-- Check for data gaps
WITH time_gaps AS (
    SELECT 
        symbol,
        interval,
        display_time,
        LAG(display_time) OVER (PARTITION BY symbol, interval ORDER BY display_time) as prev_time
    FROM kline
    WHERE symbol = 'BTCUSDT' AND interval = '5m'
)
SELECT symbol, interval, COUNT(*) as gaps
FROM time_gaps 
WHERE display_time - prev_time > INTERVAL '10 minutes'
GROUP BY symbol, interval;
```

## Performance Optimization Recommendations

### 1. Index Optimization
- Monitor index usage with `pg_stat_user_indexes`
- Remove unused indexes
- Add indexes for frequently queried columns

### 2. Query Optimization
- Use `EXPLAIN ANALYZE` for slow queries
- Optimize WHERE clauses
- Use appropriate JOIN strategies

### 3. Maintenance
- Regular VACUUM operations
- ANALYZE statistics updates
- Monitor dead tuple ratios

### 4. Configuration Tuning
- Adjust `shared_buffers` based on available memory
- Configure `effective_cache_size`
- Set appropriate `work_mem` values

## Monitoring Alerts

### Critical Alerts
- Database unavailable
- High connection count (> 80% of max)
- Long-running queries (> 5 minutes)
- Data freshness issues (> 1 hour old)

### Warning Alerts
- Low cache hit ratio (< 90%)
- High dead tuple ratio (> 5%)
- Unused indexes
- Slow query performance

## Data Source Integration

These SQL tools are designed to work with Grafana dashboards:

1. **Prometheus Metrics**: Database metrics can be exported to Prometheus
2. **Grafana Dashboards**: Use SQL queries in Grafana panels
3. **Alerting**: Set up alerts based on query results

## File Structure

```
scripts/sql-diagnostics/
├── README.md                           # This documentation
├── 01-database-health-check.sql        # Database health monitoring
├── 02-kline-data-analysis.sql          # Kline data analysis
├── 03-performance-monitoring.sql       # Performance monitoring
└── examples/                           # Example usage scripts
    ├── quick-health-check.sh           # Quick health check script
    ├── daily-monitoring.sh             # Daily monitoring script
    └── performance-analysis.sh         # Performance analysis script
```

## Best Practices

### 1. Regular Monitoring
- Run health checks daily
- Monitor performance weekly
- Analyze data quality monthly

### 2. Documentation
- Document any custom queries
- Keep track of performance baselines
- Record optimization changes

### 3. Automation
- Set up automated monitoring scripts
- Configure alerts for critical issues
- Schedule regular maintenance tasks

### 4. Security
- Use read-only users for monitoring
- Limit access to diagnostic tools
- Audit query execution logs

## Support and Maintenance

### Updating Tools
- Review and update queries regularly
- Add new metrics as needed
- Optimize queries for better performance

### Customization
- Modify queries for specific needs
- Add new diagnostic categories
- Integrate with monitoring systems

### Troubleshooting
- Check database logs for errors
- Verify connection parameters
- Test queries individually

---

## Quick Reference

### Essential Commands
```bash
# Connect to database
docker exec -it postgres-testnet psql -U testnet_user -d binance_trader_testnet

# Run health check
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -f 01-database-health-check.sql

# Check kline data
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM kline;"

# Monitor connections
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT state, COUNT(*) FROM pg_stat_activity GROUP BY state;"
```

### Key Tables
- `kline`: Main kline data table
- `orders`: Trading orders
- `order_books`: Order book data
- `pg_stat_activity`: Active connections
- `pg_stat_user_tables`: Table statistics
- `pg_stat_user_indexes`: Index statistics

---

*This documentation is maintained alongside the SQL diagnostic tools. Please update when making changes to queries or adding new tools.*
