# Trading System Observability Design

## Overview
Comprehensive historical metrics and observability system for testnet trading instances to enable debugging, analysis, and performance optimization.

## 1. Strategy Analysis Events
**Purpose**: Record every MACD calculation for historical analysis

### Table: `strategy_analysis_events`
```sql
CREATE TABLE strategy_analysis_events (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR NOT NULL,
    strategy_name VARCHAR NOT NULL,
    symbol VARCHAR NOT NULL,
    interval VARCHAR NOT NULL,
    
    -- Timestamps
    analysis_time TIMESTAMP NOT NULL,
    kline_timestamp BIGINT NOT NULL,
    kline_close_time TIMESTAMP NOT NULL,
    
    -- Market Data
    current_price DECIMAL(20, 8) NOT NULL,
    kline_count INTEGER NOT NULL,
    
    -- MACD Values
    macd_line DECIMAL(20, 8),
    signal_line DECIMAL(20, 8),
    histogram DECIMAL(20, 8),
    signal_strength VARCHAR, -- NONE, WEAK, MODERATE, STRONG
    
    -- Signal Detection
    signal_detected VARCHAR, -- NULL, BUY, SELL
    signal_reason TEXT,
    
    -- EMAs (optional for advanced analysis)
    ema_fast DECIMAL(20, 8),
    ema_slow DECIMAL(20, 8),
    
    -- Indexes
    INDEX idx_analysis_instance_time (instance_id, analysis_time),
    INDEX idx_analysis_symbol_interval_time (symbol, interval, analysis_time)
);
```

**Metrics Captured**:
- Every MACD calculation (every 60 seconds)
- Market price at analysis time
- Signal strength and detection
- Historical MACD trends

---

## 2. Decision Logs
**Purpose**: Understand why trades were or weren't executed

### Table: `trading_decision_logs`
```sql
CREATE TABLE trading_decision_logs (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR NOT NULL,
    strategy_name VARCHAR NOT NULL,
    symbol VARCHAR NOT NULL,
    
    -- Timestamps
    decision_time TIMESTAMP NOT NULL,
    
    -- Signal Info
    signal_detected VARCHAR, -- BUY, SELL
    signal_strength VARCHAR, -- WEAK, MODERATE, STRONG
    macd_histogram DECIMAL(20, 8),
    current_price DECIMAL(20, 8),
    
    -- Decision
    trade_allowed BOOLEAN NOT NULL,
    trade_executed BOOLEAN NOT NULL,
    
    -- Decision Factors
    has_active_position BOOLEAN,
    position_size_ok BOOLEAN,
    daily_loss_limit_ok BOOLEAN,
    risk_check_passed BOOLEAN,
    
    -- Reason Text
    decision_reason TEXT NOT NULL,
    blocked_reason TEXT,
    
    -- Trade Details (if executed)
    order_id VARCHAR,
    executed_price DECIMAL(20, 8),
    executed_quantity DECIMAL(20, 8),
    
    -- Indexes
    INDEX idx_decision_instance_time (instance_id, decision_time),
    INDEX idx_decision_executed (trade_executed, decision_time)
);
```

**Metrics Captured**:
- Why signals were accepted/rejected
- Risk checks performed
- Trade execution outcomes
- Blocking reasons

---

## 3. Portfolio Snapshots
**Purpose**: Track portfolio value and composition over time

### Table: `portfolio_snapshots`
```sql
CREATE TABLE portfolio_snapshots (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR NOT NULL,
    strategy_name VARCHAR NOT NULL,
    
    -- Timestamps
    snapshot_time TIMESTAMP NOT NULL,
    
    -- Portfolio Value
    total_balance DECIMAL(20, 8) NOT NULL,
    available_balance DECIMAL(20, 8) NOT NULL,
    position_value DECIMAL(20, 8) NOT NULL,
    
    -- Position Details
    symbol VARCHAR,
    position_size DECIMAL(20, 8),
    position_entry_price DECIMAL(20, 8),
    current_market_price DECIMAL(20, 8),
    unrealized_pnl DECIMAL(20, 8),
    
    -- Performance Metrics
    total_trades INTEGER NOT NULL,
    winning_trades INTEGER NOT NULL,
    total_realized_pnl DECIMAL(20, 8) NOT NULL,
    daily_pnl DECIMAL(20, 8),
    
    -- Risk Metrics
    current_drawdown DECIMAL(20, 8),
    max_drawdown DECIMAL(20, 8),
    
    -- Indexes
    INDEX idx_snapshot_instance_time (instance_id, snapshot_time),
    INDEX idx_snapshot_time (snapshot_time)
);
```

**Metrics Captured**:
- Portfolio value over time
- Position details
- P&L tracking
- Drawdown monitoring

---

## 4. Risk Metrics History
**Purpose**: Track risk metrics and exposure over time

### Table: `risk_metrics_history`
```sql
CREATE TABLE risk_metrics_history (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR NOT NULL,
    strategy_name VARCHAR NOT NULL,
    
    -- Timestamps
    metric_time TIMESTAMP NOT NULL,
    
    -- Risk Metrics
    portfolio_value DECIMAL(20, 8) NOT NULL,
    position_exposure DECIMAL(20, 8) NOT NULL,
    exposure_percentage DECIMAL(5, 2) NOT NULL,
    
    -- Loss Limits
    daily_pnl DECIMAL(20, 8) NOT NULL,
    max_daily_loss DECIMAL(20, 8) NOT NULL,
    daily_loss_remaining DECIMAL(20, 8) NOT NULL,
    
    -- Position Risk
    stop_loss_distance DECIMAL(20, 8),
    potential_loss DECIMAL(20, 8),
    risk_reward_ratio DECIMAL(10, 2),
    
    -- Volatility (optional)
    price_volatility DECIMAL(10, 4),
    
    -- Status
    risk_level VARCHAR, -- LOW, MEDIUM, HIGH, CRITICAL
    
    -- Indexes
    INDEX idx_risk_instance_time (instance_id, metric_time),
    INDEX idx_risk_level (risk_level, metric_time)
);
```

**Metrics Captured**:
- Position exposure
- Daily loss limits
- Risk/reward ratios
- Volatility measures

---

## 5. Market Conditions Log
**Purpose**: Record market conditions at decision points

### Table: `market_conditions_log`
```sql
CREATE TABLE market_conditions_log (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR NOT NULL,
    interval VARCHAR NOT NULL,
    
    -- Timestamps
    condition_time TIMESTAMP NOT NULL,
    
    -- Price Action
    current_price DECIMAL(20, 8) NOT NULL,
    price_change_1h DECIMAL(10, 4),
    price_change_24h DECIMAL(10, 4),
    
    -- Volume
    volume DECIMAL(20, 8),
    volume_ma_20 DECIMAL(20, 8),
    volume_ratio DECIMAL(10, 2),
    
    -- Trend Indicators
    trend VARCHAR, -- BULLISH, BEARISH, SIDEWAYS
    trend_strength DECIMAL(5, 2),
    
    -- Volatility
    volatility_index DECIMAL(10, 4),
    
    -- Support/Resistance (optional)
    nearest_support DECIMAL(20, 8),
    nearest_resistance DECIMAL(20, 8),
    
    -- Indexes
    INDEX idx_market_symbol_time (symbol, condition_time),
    INDEX idx_market_trend (trend, condition_time)
);
```

**Metrics Captured**:
- Price movements
- Volume analysis
- Trend identification
- Volatility tracking

---

## Implementation Strategy

### Phase 1: Core Metrics (Immediate)
1. ✅ Strategy Analysis Events - MACD persistence
2. ✅ Decision Logs - Trade decision tracking
3. ✅ Portfolio Snapshots - Value tracking

### Phase 2: Advanced Metrics (Short-term)
4. Risk Metrics History
5. Market Conditions Log

### Phase 3: Enhancements (Future)
- Real-time dashboard integration
- Grafana dashboards for visualization
- Automated alerts based on metrics
- Performance comparison tools

---

## Data Retention Policy

| Table | Retention Period | Reasoning |
|-------|-----------------|-----------|
| strategy_analysis_events | 90 days | High-frequency data (every minute) |
| trading_decision_logs | 1 year | Important for strategy review |
| portfolio_snapshots | 1 year | Long-term performance tracking |
| risk_metrics_history | 90 days | Real-time risk monitoring |
| market_conditions_log | 30 days | Market context for analysis |

---

## Grafana Dashboard Integration

### Dashboard 1: Strategy Performance
- MACD line, signal line, histogram over time
- Signal detections (BUY/SELL markers)
- Price overlay
- Trade execution points

### Dashboard 2: Decision Analysis
- Decisions made vs rejected
- Blocking reasons distribution
- Success rate of different signal strengths

### Dashboard 3: Portfolio & Risk
- Portfolio value over time
- Position exposure
- Drawdown visualization
- Daily P&L tracking

### Dashboard 4: Market Context
- Price trends
- Volume analysis
- Volatility tracking
- Correlation with trade success

---

## Usage Examples

### Example 1: Analyze Why No Signals Generated
```sql
SELECT 
    analysis_time,
    current_price,
    macd_line,
    signal_line,
    histogram,
    signal_strength
FROM strategy_analysis_events
WHERE instance_id = 'conservative-btc'
    AND analysis_time > NOW() - INTERVAL '24 hours'
ORDER BY analysis_time DESC;
```

### Example 2: Review Trade Rejections
```sql
SELECT 
    decision_time,
    signal_detected,
    signal_strength,
    trade_allowed,
    blocked_reason
FROM trading_decision_logs
WHERE trade_allowed = false
    AND decision_time > NOW() - INTERVAL '7 days'
ORDER BY decision_time DESC;
```

### Example 3: Portfolio Value Trend
```sql
SELECT 
    snapshot_time,
    total_balance,
    position_value,
    total_realized_pnl,
    current_drawdown
FROM portfolio_snapshots
WHERE instance_id = 'aggressive-eth'
ORDER BY snapshot_time;
```

---

## Benefits

1. **Debugging**: Understand exactly why trades were/weren't made
2. **Performance Analysis**: Identify patterns in successful strategies
3. **Risk Management**: Monitor exposure and limits in real-time
4. **Optimization**: Data-driven strategy improvements
5. **Compliance**: Complete audit trail
6. **Learning**: Visual representation of market behavior

---

## Next Steps

1. ✅ Create database migrations
2. ✅ Add storage client methods
3. ✅ Update TestnetTradingInstance to collect metrics
4. ✅ Test data persistence
5. Create Grafana dashboards
6. Set up data retention policies

