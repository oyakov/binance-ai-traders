# Observability System - Quick Reference Guide

Quick commands and queries for accessing observability metrics.

---

## Check System Status

### View Recent Analysis Events
```powershell
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT instance_id, symbol, interval, signal_strength, signal_detected, TO_CHAR(analysis_time, 'HH24:MI:SS') as time FROM strategy_analysis_events ORDER BY analysis_time DESC LIMIT 10;"
```

### Count Events by Instance
```powershell
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT instance_id, COUNT(*) as total_events, MAX(analysis_time) as latest FROM strategy_analysis_events GROUP BY instance_id;"
```

### View Recent Portfolio Snapshots
```powershell
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT instance_id, total_balance, position_value, total_trades, TO_CHAR(snapshot_time, 'HH24:MI:SS') as time FROM portfolio_snapshots ORDER BY snapshot_time DESC LIMIT 5;"
```

---

## Analysis Queries

### MACD Histogram Analysis
```sql
-- View MACD histogram trends
SELECT 
    instance_id,
    symbol,
    TO_CHAR(analysis_time, 'YYYY-MM-DD HH24:MI') as time,
    ROUND(histogram::numeric, 2) as histogram,
    signal_strength
FROM strategy_analysis_events
WHERE instance_id = 'conservative-btc'
ORDER BY analysis_time DESC
LIMIT 20;
```

### Signal Strength Distribution
```sql
-- Count signal strengths
SELECT 
    instance_id,
    signal_strength,
    COUNT(*) as count
FROM strategy_analysis_events
GROUP BY instance_id, signal_strength
ORDER BY instance_id, signal_strength;
```

### Find Strong Signals
```sql
-- Find when strong signals occurred
SELECT 
    instance_id,
    symbol,
    analysis_time,
    histogram,
    signal_detected,
    signal_reason
FROM strategy_analysis_events
WHERE signal_strength = 'STRONG'
ORDER BY analysis_time DESC;
```

---

## Trading Decision Analysis

### View All Decisions
```sql
SELECT 
    instance_id,
    TO_CHAR(decision_time, 'YYYY-MM-DD HH24:MI:SS') as time,
    signal_detected,
    trade_allowed,
    trade_executed,
    decision_reason
FROM trading_decision_logs
ORDER BY decision_time DESC
LIMIT 10;
```

### Why Trades Were Blocked
```sql
SELECT 
    instance_id,
    COUNT(*) as blocked_count,
    blocked_reason
FROM trading_decision_logs
WHERE trade_allowed = false
GROUP BY instance_id, blocked_reason;
```

---

## Performance Tracking

### Portfolio Value Over Time
```sql
SELECT 
    instance_id,
    TO_CHAR(snapshot_time, 'YYYY-MM-DD HH24:MI') as time,
    total_balance,
    position_value,
    total_realized_pnl,
    total_trades
FROM portfolio_snapshots
WHERE instance_id = 'aggressive-eth'
ORDER BY snapshot_time;
```

### Win Rate Analysis
```sql
SELECT 
    instance_id,
    total_trades,
    winning_trades,
    CASE 
        WHEN total_trades > 0 THEN ROUND((winning_trades::numeric / total_trades * 100), 2)
        ELSE 0 
    END as win_rate_pct
FROM portfolio_snapshots
WHERE total_trades > 0
ORDER BY snapshot_time DESC;
```

---

## Real-time Monitoring

### Check Last 10 Minutes Activity
```sql
SELECT 
    instance_id,
    COUNT(*) as events_last_10min
FROM strategy_analysis_events
WHERE analysis_time > NOW() - INTERVAL '10 minutes'
GROUP BY instance_id;
```

### Current Signal Strength
```sql
SELECT DISTINCT ON (instance_id)
    instance_id,
    symbol,
    signal_strength,
    histogram,
    analysis_time
FROM strategy_analysis_events
ORDER BY instance_id, analysis_time DESC;
```

---

## Debugging

### Check for Data Gaps
```sql
-- Find gaps in data collection (should be ~1 event per minute per instance)
SELECT 
    instance_id,
    analysis_time,
    LAG(analysis_time) OVER (PARTITION BY instance_id ORDER BY analysis_time) as prev_time,
    EXTRACT(EPOCH FROM (analysis_time - LAG(analysis_time) OVER (PARTITION BY instance_id ORDER BY analysis_time)))/60 as gap_minutes
FROM strategy_analysis_events
WHERE analysis_time > NOW() - INTERVAL '1 hour'
ORDER BY gap_minutes DESC NULLS LAST
LIMIT 10;
```

### View Error Patterns
```powershell
# Check trader logs for observability errors
docker logs binance-trader-macd-testnet 2>&1 | Select-String -Pattern "Failed to record"
```

---

## Maintenance

### Clean Old Data (if needed)
```sql
-- Delete data older than 90 days (for strategy_analysis_events)
DELETE FROM strategy_analysis_events 
WHERE analysis_time < NOW() - INTERVAL '90 days';

-- Delete data older than 1 year (for portfolio_snapshots)
DELETE FROM portfolio_snapshots 
WHERE snapshot_time < NOW() - INTERVAL '1 year';
```

### Check Table Sizes
```sql
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
    AND tablename IN ('strategy_analysis_events', 'trading_decision_logs', 'portfolio_snapshots')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

---

## Export Data

### Export to CSV (from inside container)
```bash
# Export strategy analysis events
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "\COPY (SELECT * FROM strategy_analysis_events WHERE analysis_time > NOW() - INTERVAL '1 day') TO '/tmp/analysis_events.csv' CSV HEADER"

# Copy file from container
docker cp postgres-testnet:/tmp/analysis_events.csv ./analysis_events.csv
```

---

## Prometheus Metrics

### Check Observability Metrics
```powershell
# Get all observability metrics
curl http://localhost:8083/actuator/prometheus | Select-String "observability"
```

**Key Metrics**:
- `binance_trader_observability_strategy_analysis_total` - Total events sent
- `binance_trader_observability_strategy_analysis_failed` - Failed events
- `binance_trader_observability_decision_log_total` - Total decisions logged
- `binance_trader_observability_portfolio_snapshot_total` - Total snapshots

---

## Common Scenarios

### Scenario 1: "Why no trading signals?"
```sql
-- Check recent MACD values and signal strength
SELECT 
    symbol,
    analysis_time,
    ROUND(macd_line::numeric, 2) as macd,
    ROUND(signal_line::numeric, 2) as signal,
    ROUND(histogram::numeric, 2) as histogram,
    signal_strength,
    signal_reason
FROM strategy_analysis_events
WHERE instance_id = 'aggressive-eth'
ORDER BY analysis_time DESC
LIMIT 20;
```

### Scenario 2: "Is the system collecting data?"
```sql
-- Verify recent activity
SELECT 
    instance_id,
    MAX(analysis_time) as last_event,
    COUNT(*) as events_last_hour
FROM strategy_analysis_events
WHERE analysis_time > NOW() - INTERVAL '1 hour'
GROUP BY instance_id;
```

### Scenario 3: "How is my strategy performing?"
```sql
-- Latest performance snapshot
SELECT 
    instance_id,
    strategy_name,
    total_balance,
    total_trades,
    winning_trades,
    ROUND((winning_trades::numeric / NULLIF(total_trades, 0) * 100), 2) as win_rate,
    total_realized_pnl,
    max_drawdown,
    snapshot_time
FROM portfolio_snapshots
WHERE snapshot_time = (SELECT MAX(snapshot_time) FROM portfolio_snapshots WHERE instance_id = portfolio_snapshots.instance_id)
ORDER BY instance_id;
```

---

## Troubleshooting

### Problem: No data in tables
1. Check services are running:
   ```powershell
   docker ps | Select-String "testnet"
   ```

2. Check trader logs:
   ```powershell
   docker logs binance-trader-macd-testnet --tail 50
   ```

3. Check storage logs:
   ```powershell
   docker logs binance-data-storage-testnet --tail 50
   ```

### Problem: Data stopped appearing
1. Check last event time:
   ```sql
   SELECT MAX(analysis_time) FROM strategy_analysis_events;
   ```

2. Restart trader:
   ```powershell
   docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet
   ```

### Problem: Too much data
1. Check current data volume:
   ```sql
   SELECT COUNT(*) FROM strategy_analysis_events;
   ```

2. Clean old data (see Maintenance section)

---

## Quick Reference Card

| What I Want | Command |
|-------------|---------|
| Latest events | `SELECT * FROM strategy_analysis_events ORDER BY analysis_time DESC LIMIT 10;` |
| Event count | `SELECT instance_id, COUNT(*) FROM strategy_analysis_events GROUP BY instance_id;` |
| Strong signals | `SELECT * FROM strategy_analysis_events WHERE signal_strength = 'STRONG';` |
| Latest portfolio | `SELECT * FROM portfolio_snapshots ORDER BY snapshot_time DESC LIMIT 5;` |
| Decision logs | `SELECT * FROM trading_decision_logs ORDER BY decision_time DESC LIMIT 10;` |
| Check logs | `docker logs binance-trader-macd-testnet --tail 50` |
| Restart trader | `docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet` |

---

*For complete documentation, see: `docs/OBSERVABILITY_DESIGN.md` and `OBSERVABILITY-IMPLEMENTATION-SUMMARY.md`*

