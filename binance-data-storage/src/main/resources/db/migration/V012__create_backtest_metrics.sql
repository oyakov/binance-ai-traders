-- Migration: V012 - Create Backtest Metrics Table
-- Purpose: Store comprehensive performance metrics for each backtest run
-- Part of: Testability & Observability Feedback Loop

CREATE TABLE IF NOT EXISTS backtest_metrics (
    id BIGSERIAL PRIMARY KEY,
    run_id UUID NOT NULL REFERENCES backtest_runs(run_id) ON DELETE CASCADE,
    metric_category VARCHAR(50) NOT NULL,  -- PROFITABILITY, RISK, TRADE_ANALYSIS, TIME_ANALYSIS, MARKET_ANALYSIS
    metric_name VARCHAR(100) NOT NULL,
    metric_value NUMERIC(20, 8),
    metric_json JSONB,
    metric_unit VARCHAR(20),  -- USD, PERCENT, RATIO, COUNT, HOURS
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for efficient querying
CREATE INDEX idx_backtest_metrics_run_id ON backtest_metrics(run_id);
CREATE INDEX idx_backtest_metrics_category ON backtest_metrics(metric_category);
CREATE INDEX idx_backtest_metrics_name ON backtest_metrics(metric_name);
CREATE INDEX idx_backtest_metrics_composite ON backtest_metrics(run_id, metric_category, metric_name);

-- Index for JSON queries
CREATE INDEX idx_backtest_metrics_json ON backtest_metrics USING GIN (metric_json);

-- Comments
COMMENT ON TABLE backtest_metrics IS 'Stores comprehensive performance metrics for each backtest run';
COMMENT ON COLUMN backtest_metrics.run_id IS 'Foreign key to backtest_runs table';
COMMENT ON COLUMN backtest_metrics.metric_category IS 'Category: PROFITABILITY, RISK, TRADE_ANALYSIS, TIME_ANALYSIS, MARKET_ANALYSIS';
COMMENT ON COLUMN backtest_metrics.metric_name IS 'Metric name (e.g., net_profit, win_rate, sharpe_ratio)';
COMMENT ON COLUMN backtest_metrics.metric_value IS 'Numeric value of the metric';
COMMENT ON COLUMN backtest_metrics.metric_json IS 'Complex metric data as JSON (e.g., trade breakdowns, time series)';
COMMENT ON COLUMN backtest_metrics.metric_unit IS 'Unit of measurement (USD, PERCENT, RATIO, COUNT, HOURS)';

-- View for easy metric access
CREATE OR REPLACE VIEW v_backtest_metrics_summary AS
SELECT 
    br.run_id,
    br.dataset_name,
    br.symbol,
    br.interval,
    br.strategy_name,
    br.parameters,
    MAX(CASE WHEN bm.metric_name = 'net_profit' THEN bm.metric_value END) AS net_profit,
    MAX(CASE WHEN bm.metric_name = 'net_profit_percent' THEN bm.metric_value END) AS net_profit_percent,
    MAX(CASE WHEN bm.metric_name = 'win_rate' THEN bm.metric_value END) AS win_rate,
    MAX(CASE WHEN bm.metric_name = 'sharpe_ratio' THEN bm.metric_value END) AS sharpe_ratio,
    MAX(CASE WHEN bm.metric_name = 'sortino_ratio' THEN bm.metric_value END) AS sortino_ratio,
    MAX(CASE WHEN bm.metric_name = 'max_drawdown_percent' THEN bm.metric_value END) AS max_drawdown_percent,
    MAX(CASE WHEN bm.metric_name = 'total_trades' THEN bm.metric_value END) AS total_trades,
    br.created_at
FROM backtest_runs br
LEFT JOIN backtest_metrics bm ON br.run_id = bm.run_id
WHERE br.status = 'COMPLETED'
GROUP BY br.run_id, br.dataset_name, br.symbol, br.interval, br.strategy_name, br.parameters, br.created_at;

COMMENT ON VIEW v_backtest_metrics_summary IS 'Consolidated view of key metrics for each backtest run';

