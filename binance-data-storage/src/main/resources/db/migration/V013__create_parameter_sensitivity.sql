-- Migration: V013 - Create Parameter Sensitivity Table
-- Purpose: Track strategy performance across different parameter combinations
-- Part of: Testability & Observability Feedback Loop

CREATE TABLE IF NOT EXISTS parameter_sensitivity (
    id BIGSERIAL PRIMARY KEY,
    run_id UUID NOT NULL REFERENCES backtest_runs(run_id) ON DELETE CASCADE,
    parameter_name VARCHAR(50) NOT NULL,
    parameter_value VARCHAR(100) NOT NULL,
    net_profit NUMERIC(20, 8),
    net_profit_percent NUMERIC(10, 4),
    win_rate NUMERIC(5, 4),
    sharpe_ratio NUMERIC(10, 4),
    sortino_ratio NUMERIC(10, 4),
    max_drawdown NUMERIC(20, 8),
    max_drawdown_percent NUMERIC(10, 4),
    profit_factor NUMERIC(10, 4),
    trade_count INTEGER,
    winning_trades INTEGER,
    losing_trades INTEGER,
    avg_win NUMERIC(20, 8),
    avg_loss NUMERIC(20, 8),
    expectancy NUMERIC(20, 8),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for parameter analysis queries
CREATE INDEX idx_param_sensitivity_run_id ON parameter_sensitivity(run_id);
CREATE INDEX idx_param_sensitivity_parameter ON parameter_sensitivity(parameter_name, parameter_value);
CREATE INDEX idx_param_sensitivity_performance ON parameter_sensitivity(parameter_name, net_profit DESC);
CREATE INDEX idx_param_sensitivity_win_rate ON parameter_sensitivity(parameter_name, win_rate DESC);
CREATE INDEX idx_param_sensitivity_sharpe ON parameter_sensitivity(parameter_name, sharpe_ratio DESC);

-- Comments
COMMENT ON TABLE parameter_sensitivity IS 'Tracks strategy performance across different parameter combinations for optimization';
COMMENT ON COLUMN parameter_sensitivity.parameter_name IS 'Parameter being tested (e.g., fastEMA, stopLoss, takeProfit)';
COMMENT ON COLUMN parameter_sensitivity.parameter_value IS 'Value of the parameter (e.g., 12, 0.98, 1.05)';
COMMENT ON COLUMN parameter_sensitivity.net_profit IS 'Net profit in quote asset (USD)';
COMMENT ON COLUMN parameter_sensitivity.win_rate IS 'Percentage of winning trades (0.0 to 1.0)';
COMMENT ON COLUMN parameter_sensitivity.sharpe_ratio IS 'Risk-adjusted return metric';
COMMENT ON COLUMN parameter_sensitivity.profit_factor IS 'Ratio of gross profit to gross loss';
COMMENT ON COLUMN parameter_sensitivity.expectancy IS 'Expected value per trade';

-- View for parameter heatmap data
CREATE OR REPLACE VIEW v_parameter_heatmap AS
SELECT 
    br.symbol,
    br.interval,
    br.strategy_name,
    ps.parameter_name,
    ps.parameter_value,
    AVG(ps.net_profit_percent) AS avg_net_profit_percent,
    AVG(ps.win_rate) AS avg_win_rate,
    AVG(ps.sharpe_ratio) AS avg_sharpe_ratio,
    AVG(ps.max_drawdown_percent) AS avg_max_drawdown_percent,
    COUNT(*) AS sample_count
FROM parameter_sensitivity ps
JOIN backtest_runs br ON ps.run_id = br.run_id
WHERE br.status = 'COMPLETED'
GROUP BY br.symbol, br.interval, br.strategy_name, ps.parameter_name, ps.parameter_value
HAVING COUNT(*) >= 3;  -- Only show parameters tested at least 3 times

COMMENT ON VIEW v_parameter_heatmap IS 'Aggregated parameter performance for heatmap visualization';

-- View for best parameters by metric
CREATE OR REPLACE VIEW v_best_parameters AS
WITH ranked_params AS (
    SELECT 
        br.symbol,
        br.interval,
        br.strategy_name,
        ps.parameter_name,
        ps.parameter_value,
        AVG(ps.net_profit_percent) AS avg_profit,
        AVG(ps.sharpe_ratio) AS avg_sharpe,
        AVG(ps.win_rate) AS avg_win_rate,
        AVG(ps.max_drawdown_percent) AS avg_drawdown,
        COUNT(*) AS test_count,
        ROW_NUMBER() OVER (
            PARTITION BY br.symbol, br.interval, br.strategy_name, ps.parameter_name 
            ORDER BY AVG(ps.sharpe_ratio) DESC
        ) AS rank_by_sharpe
    FROM parameter_sensitivity ps
    JOIN backtest_runs br ON ps.run_id = br.run_id
    WHERE br.status = 'COMPLETED'
    GROUP BY br.symbol, br.interval, br.strategy_name, ps.parameter_name, ps.parameter_value
    HAVING COUNT(*) >= 3
)
SELECT * FROM ranked_params WHERE rank_by_sharpe <= 5;

COMMENT ON VIEW v_best_parameters IS 'Top 5 parameter values for each parameter by Sharpe ratio';

