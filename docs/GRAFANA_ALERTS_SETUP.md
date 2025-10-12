# Grafana Alerts Setup Guide

## Overview
This guide shows you how to set up alerts for your trading system to get notified when important events occur.

---

## Alert Scenarios

### 1. **Signal Detection Alert** 🔔
Get notified when a BUY or SELL signal is generated

### 2. **Portfolio Risk Alert** ⚠️
Get notified when portfolio value drops below threshold

### 3. **No Data Alert** 🚨
Get notified when system stops collecting data

---

## Setup Instructions

### Step 1: Configure Notification Channel

1. Go to **Grafana** → http://localhost:3001
2. Click **Alerting** (bell icon) → **Contact points**
3. Click **+ Add contact point**
4. Configure your preferred method:

#### Option A: Email
```
Name: Email Notifications
Type: Email
Addresses: your-email@example.com
```

#### Option B: Slack
```
Name: Slack Notifications
Type: Slack
Webhook URL: [Your Slack Webhook URL]
```

#### Option C: Discord
```
Name: Discord Notifications
Type: Discord
Webhook URL: [Your Discord Webhook URL]
```

5. Click **Test** to verify it works
6. Click **Save contact point**

---

### Step 2: Create Alert Rules

#### Alert 1: Trading Signal Detected

1. Go to **Alerting** → **Alert rules**
2. Click **+ Create alert rule**
3. Configure:

**Rule name**: `Trading Signal Detected`

**Query A**:
```sql
SELECT COUNT(*) as signals
FROM strategy_analysis_events
WHERE signal_detected IS NOT NULL
  AND analysis_time > NOW() - INTERVAL '5 minutes'
```

**Condition**: `WHEN last() OF A IS ABOVE 0`

**Set evaluation**:
- Folder: Trading Alerts
- Evaluation interval: 1m
- Pending period: 0m

**Add annotations**:
- Summary: `Trading signal detected: {{ $labels.instance_id }}`
- Description: `A {{ $values.signal_detected }} signal was detected for {{ $labels.symbol }}`

**Notification**: Select your contact point

4. Click **Save rule and exit**

---

#### Alert 2: Portfolio Value Drop

1. Go to **Alerting** → **Alert rules**
2. Click **+ Create alert rule**
3. Configure:

**Rule name**: `Portfolio Value Warning`

**Query A**:
```sql
SELECT total_balance
FROM portfolio_snapshots
WHERE snapshot_time = (SELECT MAX(snapshot_time) FROM portfolio_snapshots)
  AND instance_id = 'conservative-btc'
```

**Condition**: `WHEN last() OF A IS BELOW 9500`

**Set evaluation**:
- Folder: Risk Alerts
- Evaluation interval: 5m
- Pending period: 5m

**Add annotations**:
- Summary: `Portfolio value dropped below threshold`
- Description: `Conservative BTC portfolio: ${{ $values.A }}`

**Notification**: Select your contact point

4. Click **Save rule and exit**

---

#### Alert 3: No Data Received

1. Go to **Alerting** → **Alert rules**
2. Click **+ Create alert rule**
3. Configure:

**Rule name**: `Strategy Analysis Stopped`

**Query A**:
```sql
SELECT COUNT(*) as recent_events
FROM strategy_analysis_events
WHERE analysis_time > NOW() - INTERVAL '5 minutes'
```

**Condition**: `WHEN last() OF A IS BELOW 5`

**Set evaluation**:
- Folder: System Health
- Evaluation interval: 5m
- Pending period: 10m

**Add annotations**:
- Summary: `Trading system may have stopped`
- Description: `Only {{ $values.A }} events received in last 5 minutes`

**Notification**: Select your contact point

4. Click **Save rule and exit**

---

## Advanced Alert: Daily P&L Summary

Create a report that sends daily P&L summary:

**Rule name**: `Daily Performance Report`

**Query A**:
```sql
SELECT 
  instance_id,
  COALESCE(total_realized_pnl, 0) as pnl,
  total_trades,
  winning_trades
FROM portfolio_snapshots
WHERE snapshot_time = (SELECT MAX(snapshot_time) FROM portfolio_snapshots WHERE instance_id = portfolio_snapshots.instance_id)
```

**Schedule**: Daily at 00:00 UTC

**Notification template**:
```
Daily Trading Summary for {{ $labels.instance_id }}:
- Total P&L: ${{ $values.pnl }}
- Total Trades: {{ $values.total_trades }}
- Winning Trades: {{ $values.winning_trades }}
- Win Rate: {{ div $values.winning_trades $values.total_trades | mul 100 }}%
```

---

## Testing Alerts

### Test Signal Alert
```sql
-- Manually trigger a test by inserting a signal
UPDATE strategy_analysis_events 
SET signal_detected = 'BUY' 
WHERE id = (SELECT MAX(id) FROM strategy_analysis_events);

-- Wait 1-2 minutes for alert to fire

-- Revert the test
UPDATE strategy_analysis_events 
SET signal_detected = NULL 
WHERE id = (SELECT MAX(id) FROM strategy_analysis_events);
```

### Test Portfolio Alert
Temporarily adjust threshold to trigger alert, then change it back.

---

## Alert Notification Examples

### Email Example:
```
Subject: [ALERT] Trading Signal Detected

A BUY signal was detected for BTCUSDT on conservative-btc strategy.

Time: 2025-10-12 03:45:00
Symbol: BTCUSDT
Interval: 4h
Histogram: +306.35
Signal Strength: STRONG

View Dashboard: http://localhost:3001/d/strategy-observability
```

### Slack Example:
```
🔔 Trading Alert

Signal Detected: BUY
Strategy: Conservative BTC
Symbol: BTCUSDT
Timeframe: 4h
Histogram: +306.35
Strength: STRONG

Dashboard | Silence
```

---

## Alert Management

### Silence Alerts Temporarily
1. Go to **Alerting** → **Silences**
2. Click **+ Add silence**
3. Configure:
   - Duration: 1 hour / 4 hours / 1 day
   - Matchers: Select specific alerts
4. Click **Create silence**

### Mute Specific Alert
1. Go to **Alerting** → **Alert rules**
2. Find the rule
3. Click **Edit** → Set to **Paused**

### View Alert History
1. Go to **Alerting** → **Alert history**
2. Filter by:
   - Time range
   - Alert rule
   - State (firing, resolved, pending)

---

## Best Practices

### 1. **Start with Few Alerts**
- Begin with 2-3 critical alerts
- Add more as you understand the system

### 2. **Avoid Alert Fatigue**
- Don't alert on every minor event
- Use appropriate thresholds
- Group related alerts

### 3. **Test Regularly**
- Test notification channels weekly
- Verify alert conditions are still relevant
- Update thresholds based on experience

### 4. **Document Alert Response**
For each alert, know:
- What it means
- What to check
- What action to take

---

## Alert Response Playbook

### Signal Detected Alert
**What it means**: A trading opportunity was identified

**Actions**:
1. Check dashboard for signal details
2. Review MACD charts
3. Verify risk metrics
4. Monitor for trade execution

### Portfolio Drop Alert
**What it means**: Portfolio value below threshold

**Actions**:
1. Check current positions
2. Review recent trades
3. Assess market conditions
4. Consider stopping trading if severe

### No Data Alert
**What it means**: System may be down

**Actions**:
1. Check Docker containers: `docker ps`
2. Check trader logs: `docker logs binance-trader-macd-testnet`
3. Check database: `docker logs postgres-testnet`
4. Restart services if needed

---

## Quick Setup Script

For Email notifications, add to `.env` file:
```bash
# Grafana SMTP Configuration
GF_SMTP_ENABLED=true
GF_SMTP_HOST=smtp.gmail.com:587
GF_SMTP_USER=your-email@gmail.com
GF_SMTP_PASSWORD=your-app-password
GF_SMTP_FROM_ADDRESS=your-email@gmail.com
GF_SMTP_FROM_NAME=Trading System Alerts
```

Then restart Grafana:
```powershell
docker-compose -f docker-compose-testnet.yml restart grafana-testnet
```

---

## Troubleshooting

### Alerts Not Firing
1. Check evaluation interval (may be too long)
2. Verify query returns data
3. Check condition threshold
4. Review alert state in Grafana

### Notifications Not Received
1. Test contact point
2. Check spam folder (for email)
3. Verify webhook URL (for Slack/Discord)
4. Check Grafana logs for errors

### Too Many Alerts
1. Increase pending period
2. Adjust thresholds
3. Add conditions to reduce noise
4. Use alert grouping

---

## Example: Complete Alert Setup

Here's a complete working example for Signal Detection:

```yaml
# Alert Rule: BUY Signal Detected
Query:
  SELECT 
    instance_id,
    symbol,
    signal_detected,
    histogram
  FROM strategy_analysis_events
  WHERE signal_detected = 'BUY'
    AND analysis_time > NOW() - INTERVAL '2 minutes'
  
Condition: 
  WHEN count() OF A IS ABOVE 0

Evaluation:
  Every: 1m
  For: 0m (immediate)

Notification:
  Contact Point: Email
  Message: |
    🚀 BUY Signal Detected!
    
    Strategy: {{ $labels.instance_id }}
    Symbol: {{ $labels.symbol }}
    Histogram: {{ $values.histogram }}
    
    Check dashboard: http://localhost:3001/d/strategy-observability
```

---

## Next Steps

1. ✅ Set up at least one contact point
2. ✅ Create Signal Detection alert
3. ✅ Test the alert
4. ⏳ Add more alerts as needed
5. ⏳ Create alert response procedures

---

*For more information, see: [Grafana Alerting Documentation](https://grafana.com/docs/grafana/latest/alerting/)*

