-- =====================================================
-- Trading System Observability Tables
-- Created: 2025-10-12
-- Purpose: Historical metrics for testnet trading analysis
-- =====================================================

-- 1. Strategy Analysis Events
-- Records every MACD calculation for historical analysis
CREATE TABLE strategy_analysis_events (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    strategy_name VARCHAR(255) NOT NULL,
    symbol VARCHAR(50) NOT NULL,
    interval VARCHAR(10) NOT NULL,
    
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
    signal_strength VARCHAR(20),
    
    -- Signal Detection
    signal_detected VARCHAR(10),
    signal_reason TEXT,
    
    -- EMAs (optional for advanced analysis)
    ema_fast DECIMAL(20, 8),
    ema_slow DECIMAL(20, 8)
);

CREATE INDEX idx_analysis_instance_time ON strategy_analysis_events(instance_id, analysis_time);
CREATE INDEX idx_analysis_symbol_interval_time ON strategy_analysis_events(symbol, interval, analysis_time);

-- 2. Trading Decision Logs
-- Records why trades were or weren't executed
CREATE TABLE trading_decision_logs (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    strategy_name VARCHAR(255) NOT NULL,
    symbol VARCHAR(50) NOT NULL,
    
    -- Timestamps
    decision_time TIMESTAMP NOT NULL,
    
    -- Signal Info
    signal_detected VARCHAR(10),
    signal_strength VARCHAR(20),
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
    order_id VARCHAR(255),
    executed_price DECIMAL(20, 8),
    executed_quantity DECIMAL(20, 8)
);

CREATE INDEX idx_decision_instance_time ON trading_decision_logs(instance_id, decision_time);
CREATE INDEX idx_decision_executed ON trading_decision_logs(trade_executed, decision_time);

-- 3. Portfolio Snapshots
-- Track portfolio value and composition over time
CREATE TABLE portfolio_snapshots (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    strategy_name VARCHAR(255) NOT NULL,
    
    -- Timestamps
    snapshot_time TIMESTAMP NOT NULL,
    
    -- Portfolio Value
    total_balance DECIMAL(20, 8) NOT NULL,
    available_balance DECIMAL(20, 8) NOT NULL,
    position_value DECIMAL(20, 8) NOT NULL,
    
    -- Position Details
    symbol VARCHAR(50),
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
    max_drawdown DECIMAL(20, 8)
);

CREATE INDEX idx_snapshot_instance_time ON portfolio_snapshots(instance_id, snapshot_time);
CREATE INDEX idx_snapshot_time ON portfolio_snapshots(snapshot_time);

-- 4. Risk Metrics History
-- Track risk metrics and exposure over time
CREATE TABLE risk_metrics_history (
    id SERIAL PRIMARY KEY,
    instance_id VARCHAR(255) NOT NULL,
    strategy_name VARCHAR(255) NOT NULL,
    
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
    risk_level VARCHAR(20)
);

CREATE INDEX idx_risk_instance_time ON risk_metrics_history(instance_id, metric_time);
CREATE INDEX idx_risk_level ON risk_metrics_history(risk_level, metric_time);

-- Comments for documentation
COMMENT ON TABLE strategy_analysis_events IS 'Records every MACD calculation for historical analysis and debugging';
COMMENT ON TABLE trading_decision_logs IS 'Records trading decisions and reasons for execution or rejection';
COMMENT ON TABLE portfolio_snapshots IS 'Periodic snapshots of portfolio value and composition';
COMMENT ON TABLE risk_metrics_history IS 'Historical risk metrics and exposure tracking';

