# Quick Fixes for Immediate Issues

## Issue 1: ADAUSDT Strategy Failing (CRITICAL)

### Problem
The ADAUSDT 1d strategy is failing continuously with:
```
WARN: Insufficient data for MACD calculation: 9 (need 35)
```

### Root Cause
- Strategy uses MACD(7, 14, 7) on daily timeframe
- Requires minimum 21 daily klines (14 slow period + 7 signal period)
- Only 9 daily klines available (data collection started Oct 1, 2025)

### Quick Fix Options

#### Option A: Disable the Strategy (Recommended for Now)
```bash
# Run the disable script
cd C:\Projects\binance-ai-traders
.\scripts\disable-adausdt-strategy.ps1

# Rebuild and restart
docker-compose -f docker-compose-testnet.yml build binance-trader-macd-testnet
docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet
```

#### Option B: Change to Shorter Timeframe
Edit `binance-trader-macd/src/main/resources/testnet-strategies.yml`:
```yaml
balanced-ada:
  name: "Balanced ADA Strategy"
  symbol: ADAUSDT
  timeframe: 4h  # Changed from 1d
  macd-params:
    fast-period: 12  # Changed from 7
    slow-period: 26  # Changed from 14
    signal-period: 9  # Changed from 7
```

Then rebuild:
```bash
docker-compose -f docker-compose-testnet.yml build binance-trader-macd-testnet
docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet
```

#### Option C: Backfill Historical Data (Long-term Solution)
Create a script to fetch 30+ days of historical daily klines from Binance API and insert into database.

---

## Issue 2: Docker Health Check False Alarm

### Problem
`binance-data-collection-testnet` shows "unhealthy" but service is actually working fine.

### Root Cause
Health check tries to use `curl` but it's not installed in the container image.

### Quick Fix Option 1: Change Health Check to wget
Edit `docker-compose-testnet.yml`:
```yaml
binance-data-collection-testnet:
  healthcheck:
    test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 3
```

Then restart:
```bash
docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet
```

### Quick Fix Option 2: Install curl in Dockerfile
Edit `binance-data-collection/Dockerfile`, add before the `CMD` instruction:
```dockerfile
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
```

Then rebuild:
```bash
docker-compose -f docker-compose-testnet.yml build binance-data-collection-testnet
docker-compose -f docker-compose-testnet.yml up -d binance-data-collection-testnet
```

---

## Issue 3: No Trading Signals Generated

### Problem
0 buy/sell signals generated in 3 days of operation.

### Possible Causes
1. Market conditions haven't triggered MACD crossovers
2. Strategies are too conservative
3. Signal detection logic issue

### Investigation Steps

1. **Check MACD values manually:**
```bash
docker exec postgres-testnet psql -U testnet_user -d binance_trader_testnet -c "SELECT * FROM macd ORDER BY timestamp DESC LIMIT 20;"
```

2. **Monitor for crossovers:**
Look for histogram changing sign (positive to negative = sell signal, negative to positive = buy signal)

3. **Check trader logs for signal detection:**
```bash
docker logs binance-trader-macd-testnet 2>&1 | Select-String -Pattern "signal|crossover|buy|sell" -CaseSensitive:$false
```

4. **Verify test order mode:**
```bash
docker exec binance-trader-macd-testnet env | Select-String -Pattern "TEST_ORDER"
```

### Quick Test: Simulate a Signal
If needed, you can manually insert test data to verify signal processing works.

---

## Verification After Fixes

### 1. Check ADAUSDT Strategy Status
```bash
# Should NOT see "Insufficient data" errors anymore
docker logs binance-trader-macd-testnet --tail 100 | Select-String -Pattern "ADAUSDT"
```

### 2. Check Health Status
```bash
docker ps -a
# binance-data-collection-testnet should show "healthy"
```

### 3. Monitor for Trading Signals
```bash
# Check metrics
curl http://localhost:8083/actuator/metrics/binance.trader.signals

# Watch logs
docker logs binance-trader-macd-testnet -f
```

---

## Rollback Procedures

### If ADAUSDT Fix Causes Issues
```bash
# Find the backup file
cd binance-trader-macd/src/main/resources
ls testnet-strategies.yml.backup-*

# Restore from backup
copy testnet-strategies.yml.backup-YYYYMMDD-HHMMSS testnet-strategies.yml

# Rebuild and restart
docker-compose -f docker-compose-testnet.yml build binance-trader-macd-testnet
docker-compose -f docker-compose-testnet.yml restart binance-trader-macd-testnet
```

---

## Summary

**Do This Now:**
1. Run `.\scripts\disable-adausdt-strategy.ps1`
2. Rebuild trader service
3. Restart trader service
4. Verify no more "Insufficient data" errors in logs

**Do This Soon:**
1. Fix Docker health check (non-critical but good practice)
2. Monitor BTC/ETH strategies for signal generation
3. Plan for historical data backfill

**Do This Eventually:**
1. Implement comprehensive backtesting
2. Tune MACD parameters based on performance
3. Enable Telegram notifications
4. Add more comprehensive monitoring

