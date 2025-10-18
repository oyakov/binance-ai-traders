-- Migration: V014 - Create Market Regime Performance Table
-- Purpose: Track strategy performance across different market conditions
-- Part of: Testability & Observability Feedback Loop

CREATE TABLE IF NOT EXISTS market_regime_performance (
    id BIGSERIAL PRIMARY KEY,
    run_id UUID NOT NULL REFERENCES backtest_runs(run_id) ON DELETE CASCADE,
    regime_type VARCHAR(50) NOT NULL,  -- BULL_TRENDING, BEAR_TRENDING, RANGING, VOLATILE, UNKNOWN
    regime_start_time TIMESTAMP NOT NULL,
    regime_end_time TIMESTAMP NOT NULL,
    regime_duration_hours NUMERIC(10, 2),
    trades_count INTEGER DEFAULT 0,
    winning_trades INTEGER DEFAULT 0,
    losing_trades INTEGER DEFAULT 0,
    net_profit NUMERIC(20, 8),
    net_profit_percent NUMERIC(10, 4),
    win_rate NUMERIC(5, 4),
    avg_profit_per_trade NUMERIC(20, 8),
    max_profit NUMERIC(20, 8),
    max_loss NUMERIC(20, 8),
    sharpe_ratio NUMERIC(10, 4),
    market_return NUMERIC(10, 4),  -- Buy-and-hold return during this regime
    strategy_vs_market NUMERIC(10, 4),  -- Strategy outperformance vs buy-and-hold
    avg_trade_duration_hours NUMERIC(10, 2),
    volatility_percent NUMERIC(10, 4),
    price_range_percent NUMERIC(10, 4),
    created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for regime analysis queries
CREATE INDEX idx_regime_perf_run_id ON market_regime_performance(run_id);
CREATE INDEX idx_regime_perf_type ON market_regime_performance(regime_type);
CREATE INDEX idx_regime_perf_performance ON market_regime_performance(regime_type, net_profit DESC);
CREATE INDEX idx_regime_perf_time_range ON market_regime_performance(regime_start_time, regime_end_time);
CREATE INDEX idx_regime_perf_duration ON market_regime_performance(regime_duration_hours DESC);

-- Comments
COMMENT ON TABLE market_regime_performance IS 'Tracks strategy performance across different market conditions';
COMMENT ON COLUMN market_regime_performance.regime_type IS 'Market condition: BULL_TRENDING, BEAR_TRENDING, RANGING, VOLATILE, UNKNOWN';
COMMENT ON COLUMN market_regime_performance.regime_duration_hours IS 'How long this market regime lasted';
COMMENT ON COLUMN market_regime_performance.trades_count IS 'Number of trades during this regime';
COMMENT ON COLUMN market_regime_performance.win_rate IS 'Win rate during this regime (0.0 to 1.0)';
COMMENT ON COLUMN market_regime_performance.market_return IS 'Buy-and-hold return during this regime';
COMMENT ON COLUMN market_regime_performance.strategy_vs_market IS 'Strategy outperformance vs buy-and-hold';
COMMENT ON COLUMN market_regime_performance.volatility_percent IS 'Market volatility during this regime';

-- View for regime performance summary
CREATE OR REPLACE VIEW v_regime_performance_summary AS
SELECT 
    br.symbol,
    br.interval,
    br.strategy_name,
    mrp.regime_type,
    COUNT(DISTINCT mrp.run_id) AS backtest_count,
    SUM(mrp.regime_duration_hours) AS total_hours_in_regime,
    SUM(mrp.trades_count) AS total_trades,
    AVG(mrp.win_rate) AS avg_win_rate,
    AVG(mrp.net_profit_percent) AS avg_profit_percent,
    AVG(mrp.sharpe_ratio) AS avg_sharpe_ratio,
    AVG(mrp.strategy_vs_market) AS avg_vs_market,
    AVG(mrp.volatility_percent) AS avg_volatility,
    MIN(mrp.net_profit_percent) AS worst_profit_percent,
    MAX(mrp.net_profit_percent) AS best_profit_percent
FROM market_regime_performance mrp
JOIN backtest_runs br ON mrp.run_id = br.run_id
WHERE br.status = 'COMPLETED'
GROUP BY br.symbol, br.interval, br.strategy_name, mrp.regime_type;

COMMENT ON VIEW v_regime_performance_summary IS 'Aggregated strategy performance by market regime';

-- View for regime distribution
CREATE OR REPLACE VIEW v_regime_distribution AS
SELECT 
    br.symbol,
    br.interval,
    mrp.regime_type,
    COUNT(*) AS regime_occurrence_count,
    AVG(mrp.regime_duration_hours) AS avg_duration_hours,
    SUM(mrp.regime_duration_hours) AS total_hours,
    ROUND(
        100.0 * SUM(mrp.regime_duration_hours) / 
        SUM(SUM(mrp.regime_duration_hours)) OVER (PARTITION BY br.symbol, br.interval),
        2
    ) AS time_percentage
FROM market_regime_performance mrp
JOIN backtest_runs br ON mrp.run_id = br.run_id
WHERE br.status = 'COMPLETED'
GROUP BY br.symbol, br.interval, mrp.regime_type;

COMMENT ON VIEW v_regime_distribution IS 'Distribution of time spent in each market regime';

-- View for best/worst regimes by strategy
CREATE OR REPLACE VIEW v_strategy_regime_ranking AS
WITH regime_ranks AS (
    SELECT 
        br.symbol,
        br.interval,
        br.strategy_name,
        mrp.regime_type,
        AVG(mrp.net_profit_percent) AS avg_profit,
        AVG(mrp.win_rate) AS avg_win_rate,
        COUNT(*) AS sample_count,
        ROW_NUMBER() OVER (
            PARTITION BY br.symbol, br.interval, br.strategy_name 
            ORDER BY AVG(mrp.net_profit_percent) DESC
        ) AS profit_rank
    FROM market_regime_performance mrp
    JOIN backtest_runs br ON mrp.run_id = br.run_id
    WHERE br.status = 'COMPLETED'
    GROUP BY br.symbol, br.interval, br.strategy_name, mrp.regime_type
    HAVING COUNT(*) >= 3
)
SELECT 
    symbol,
    interval,
    strategy_name,
    regime_type,
    avg_profit,
    avg_win_rate,
    sample_count,
    CASE 
        WHEN profit_rank = 1 THEN 'BEST'
        WHEN profit_rank = (SELECT MAX(profit_rank) FROM regime_ranks rr2 
                           WHERE rr2.symbol = regime_ranks.symbol 
                           AND rr2.interval = regime_ranks.interval 
                           AND rr2.strategy_name = regime_ranks.strategy_name) THEN 'WORST'
        ELSE 'NEUTRAL'
    END AS performance_category
FROM regime_ranks;

COMMENT ON VIEW v_strategy_regime_ranking IS 'Ranks best and worst market regimes for each strategy';

