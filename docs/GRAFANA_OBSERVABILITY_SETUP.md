# Grafana Observability Dashboard Setup Guide

## Quick Access

**Dashboard Name**: "Trading Strategy Observability"  
**URL**: http://localhost:3001/d/strategy-observability  
**Auto-Refresh**: Every 30 seconds

---

## What You'll See

The new dashboard includes:

### 1. **Summary Stats (Top Row)**
- Events collected in the last hour
- Portfolio snapshots in the last hour

### 2. **MACD Charts (Middle Row)**
- **Left Panel**: Conservative BTC (4h timeframe)
  - Blue line: MACD
  - Orange line: Signal
  - Green area: Histogram
- **Right Panel**: Aggressive ETH (1h timeframe)
  - Same MACD components

### 3. **Portfolio & Events (Bottom Row)**
- **Left Panel**: Portfolio value over time for both strategies
- **Right Panel**: Recent analysis events table with:
  - Signal strength (color-coded: STRONG=green, MODERATE=yellow, WEAK=orange, NONE=red)
  - Histogram values
  - Signal detections
  - Timestamps

---

## Setup Steps

### Option 1: Dashboard Should Auto-Load (Recommended)
1. Wait 10-15 seconds for Grafana to restart
2. Navigate to: **http://localhost:3001**
3. Click "Dashboards" → "Browse"
4. Look for "Trading Strategy Observability"
5. Click to open

### Option 2: Manual Import (If Auto-Load Fails)
1. Go to http://localhost:3001
2. Click the "+" icon → "Import dashboard"
3. Upload the file: `monitoring/grafana/provisioning/dashboards/08-observability/strategy-observability-dashboard.json`
4. Select datasource: "PostgreSQL - Testnet"
5. Click "Import"

---

## PostgreSQL Datasource Configuration

If the dashboard shows "No data" or datasource errors, verify the PostgreSQL connection:

### 1. Check Datasource Exists
- Go to: **Configuration** → **Data Sources**
- Look for: "PostgreSQL - Testnet" or "postgres-testnet"

### 2. Create Datasource (If Missing)
1. Click "Add data source"
2. Select "PostgreSQL"
3. Configure:
   ```
   Name: PostgreSQL - Testnet
   Host: postgres-testnet:5432
   Database: binance_trader_testnet
   User: testnet_user
   Password: testnet_password
   SSL Mode: disable
   ```
4. Click "Save & Test"

---

## Troubleshooting

### Problem: Dashboard not visible
**Solution**:
```powershell
# Verify file exists
Get-ChildItem "monitoring/grafana/provisioning/dashboards/08-observability/"

# Check Grafana logs
docker logs grafana-testnet --tail 50
```

### Problem: "No data" in panels
**Possible causes**:
1. **Wrong datasource UID**: Edit dashboard, check datasource is "postgres-testnet"
2. **No data yet**: Wait a few minutes for more events to accumulate
3. **Time range**: Try changing time range to "Last 1 hour" or "Last 6 hours"

**Verify data exists**:
```powershell
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT COUNT(*) FROM strategy_analysis_events;"
```

### Problem: Connection refused
**Solution**:
```powershell
# Restart Grafana and PostgreSQL
docker-compose -f docker-compose-testnet.yml restart grafana-testnet postgres-testnet
```

---

## Dashboard Customization

### Change Time Range
- Top-right corner → Select "Last 1 hour", "Last 6 hours", "Last 24 hours", etc.

### Add More Instances
If you add more trading strategies, edit the panels:
1. Click panel title → "Edit"
2. Duplicate query "A" or "B"
3. Change `instance_id` to your new strategy (e.g., 'balanced-ada')
4. Click "Apply"

### Change Refresh Rate
- Top-right corner → Click refresh icon → Select interval (5s, 10s, 30s, 1m, etc.)

---

## Advanced Queries

### Custom Panel for Signal Strength Distribution
```sql
SELECT 
  signal_strength,
  COUNT(*) as count
FROM strategy_analysis_events
WHERE $__timeFilter(analysis_time)
GROUP BY signal_strength
ORDER BY signal_strength;
```

### Custom Panel for Histogram Range
```sql
SELECT 
  analysis_time as "time",
  MAX(histogram) as "Max Histogram",
  MIN(histogram) as "Min Histogram",
  AVG(histogram) as "Avg Histogram"
FROM strategy_analysis_events
WHERE instance_id = 'conservative-btc'
  AND $__timeFilter(analysis_time)
GROUP BY analysis_time
ORDER BY analysis_time;
```

---

## What the Data Means

### MACD Line (Blue)
- Shows momentum trend
- Crossing above Signal = potential BUY
- Crossing below Signal = potential SELL

### Signal Line (Orange)
- Smoothed average of MACD
- Acts as trigger line for signals

### Histogram (Green)
- Difference between MACD and Signal
- **Positive & growing** = bullish momentum
- **Negative & growing** = bearish momentum
- **Near zero** = weak signal

### Signal Strength
- **STRONG**: |histogram| > 100 (high confidence)
- **MODERATE**: |histogram| 50-100 (medium confidence)
- **WEAK**: |histogram| 10-50 (low confidence)
- **NONE**: |histogram| < 10 (no clear signal)

---

## Current Data Status

As of now, you have:
- ✅ **30 strategy analysis events**
- ✅ **6 portfolio snapshots**
- ✅ **2 active strategies** (conservative-btc, aggressive-eth)
- ✅ **Data refreshing every 60 seconds**

---

## Next Steps

1. **Access the dashboard**: http://localhost:3001/d/strategy-observability
2. **Set time range**: "Last 1 hour" to see recent data
3. **Enable auto-refresh**: Set to 30s or 1m
4. **Monitor**: Watch MACD trends and signal strengths
5. **Wait for signals**: Dashboard will show when BUY/SELL signals are detected

---

## Screenshots Expected

You should see:
- **MACD charts with data** (not "No data" or "Data outside time range")
- **Green histogram bars** showing momentum
- **Table with recent events** showing your strategies
- **Portfolio value line** (currently flat at $10,000 since no trades yet)

---

## Support

If you still see "No data":
1. Check time range includes current time
2. Verify PostgreSQL datasource is working: Configuration → Data Sources → Test
3. Run this to verify data exists:
   ```powershell
   docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT instance_id, COUNT(*), MAX(analysis_time) FROM strategy_analysis_events GROUP BY instance_id;"
   ```
4. Share screenshot and I'll help troubleshoot

---

*Dashboard created: October 12, 2025*

