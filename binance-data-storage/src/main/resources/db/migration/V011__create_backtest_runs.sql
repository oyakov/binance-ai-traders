-- Migration: V011 - Create Backtest Runs Table
-- Purpose: Store metadata for each backtest execution
-- Part of: Testability & Observability Feedback Loop

CREATE TABLE IF NOT EXISTS backtest_runs (
    id BIGSERIAL PRIMARY KEY,
    run_id UUID UNIQUE NOT NULL,
    dataset_name VARCHAR(255) NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    interval VARCHAR(10) NOT NULL,
    strategy_name VARCHAR(50) NOT NULL,
    parameters JSONB NOT NULL,
    initial_capital NUMERIC(20, 8),
    final_capital NUMERIC(20, 8),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    execution_duration_ms BIGINT,
    kline_count INTEGER,
    trade_count INTEGER,
    status VARCHAR(20) DEFAULT 'COMPLETED',  -- COMPLETED, FAILED, RUNNING
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_backtest_runs_run_id ON backtest_runs(run_id);
CREATE INDEX idx_backtest_runs_symbol_interval ON backtest_runs(symbol, interval);
CREATE INDEX idx_backtest_runs_strategy ON backtest_runs(strategy_name);
CREATE INDEX idx_backtest_runs_created_at ON backtest_runs(created_at DESC);
CREATE INDEX idx_backtest_runs_status ON backtest_runs(status);
CREATE INDEX idx_backtest_runs_dataset ON backtest_runs(dataset_name);

-- Index for parameter queries (GIN index for JSONB)
CREATE INDEX idx_backtest_runs_parameters ON backtest_runs USING GIN (parameters);

-- Comments for documentation
COMMENT ON TABLE backtest_runs IS 'Stores metadata for each backtest execution';
COMMENT ON COLUMN backtest_runs.run_id IS 'Unique identifier for this backtest run';
COMMENT ON COLUMN backtest_runs.dataset_name IS 'Name of the dataset used (e.g., BTCUSDT-1h-30d)';
COMMENT ON COLUMN backtest_runs.symbol IS 'Trading pair symbol (e.g., BTCUSDT)';
COMMENT ON COLUMN backtest_runs.interval IS 'Candlestick interval (e.g., 1h, 5m)';
COMMENT ON COLUMN backtest_runs.strategy_name IS 'Trading strategy name (e.g., MACD, Grid)';
COMMENT ON COLUMN backtest_runs.parameters IS 'Strategy parameters as JSON (e.g., {"fastEMA":12,"slowEMA":26})';
COMMENT ON COLUMN backtest_runs.initial_capital IS 'Starting capital for backtest';
COMMENT ON COLUMN backtest_runs.final_capital IS 'Ending capital after backtest';
COMMENT ON COLUMN backtest_runs.execution_duration_ms IS 'How long the backtest took to execute (milliseconds)';
COMMENT ON COLUMN backtest_runs.kline_count IS 'Number of candlesticks processed';
COMMENT ON COLUMN backtest_runs.trade_count IS 'Number of trades executed';
COMMENT ON COLUMN backtest_runs.status IS 'Execution status: COMPLETED, FAILED, or RUNNING';

