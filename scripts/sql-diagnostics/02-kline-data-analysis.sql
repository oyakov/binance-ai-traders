-- Kline Data Analysis Queries
-- This script provides comprehensive analysis of kline data for monitoring and validation

-- =============================================
-- 1. KLINE DATA OVERVIEW
-- =============================================

-- Basic kline data statistics
SELECT 
    'Kline Data Overview' as analysis_type,
    COUNT(*) as total_klines,
    COUNT(DISTINCT symbol) as unique_symbols,
    COUNT(DISTINCT interval) as unique_intervals,
    MIN(display_time) as earliest_data,
    MAX(display_time) as latest_data,
    MAX(display_time) - MIN(display_time) as data_span
FROM kline;

-- =============================================
-- 2. SYMBOL AND INTERVAL BREAKDOWN
-- =============================================

-- Data distribution by symbol and interval
SELECT 
    symbol,
    interval,
    COUNT(*) as kline_count,
    MIN(display_time) as first_kline,
    MAX(display_time) as last_kline,
    ROUND(AVG(close), 2) as avg_close_price,
    ROUND(MIN(close), 2) as min_close_price,
    ROUND(MAX(close), 2) as max_close_price,
    ROUND(SUM(volume), 2) as total_volume
FROM kline 
GROUP BY symbol, interval 
ORDER BY symbol, interval;

-- =============================================
-- 3. DATA QUALITY CHECKS
-- =============================================

-- Check for missing or invalid data
SELECT 
    'Data Quality Issues' as check_type,
    COUNT(*) as total_issues,
    SUM(CASE WHEN open IS NULL OR high IS NULL OR low IS NULL OR close IS NULL THEN 1 ELSE 0 END) as null_prices,
    SUM(CASE WHEN volume IS NULL OR volume <= 0 THEN 1 ELSE 0 END) as invalid_volumes,
    SUM(CASE WHEN high < low THEN 1 ELSE 0 END) as invalid_high_low,
    SUM(CASE WHEN open <= 0 OR close <= 0 THEN 1 ELSE 0 END) as invalid_prices
FROM kline;

-- =============================================
-- 4. PRICE ANALYSIS
-- =============================================

-- Price statistics by symbol
SELECT 
    symbol,
    COUNT(*) as data_points,
    ROUND(AVG(close), 2) as avg_price,
    ROUND(MIN(close), 2) as min_price,
    ROUND(MAX(close), 2) as max_price,
    ROUND(STDDEV(close), 2) as price_volatility,
    ROUND((MAX(close) - MIN(close)) / MIN(close) * 100, 2) as price_range_percent
FROM kline 
GROUP BY symbol 
ORDER BY avg_price DESC;

-- =============================================
-- 5. VOLUME ANALYSIS
-- =============================================

-- Volume statistics by symbol
SELECT 
    symbol,
    COUNT(*) as data_points,
    ROUND(AVG(volume), 2) as avg_volume,
    ROUND(MIN(volume), 2) as min_volume,
    ROUND(MAX(volume), 2) as max_volume,
    ROUND(STDDEV(volume), 2) as volume_volatility,
    ROUND(SUM(volume), 2) as total_volume
FROM kline 
GROUP BY symbol 
ORDER BY total_volume DESC;

-- =============================================
-- 6. TIME-BASED ANALYSIS
-- =============================================

-- Data collection timeline
SELECT 
    DATE_TRUNC('hour', display_time) as hour_bucket,
    COUNT(*) as klines_per_hour,
    COUNT(DISTINCT symbol) as symbols_per_hour,
    ROUND(AVG(close), 2) as avg_price
FROM kline 
GROUP BY DATE_TRUNC('hour', display_time)
ORDER BY hour_bucket;

-- =============================================
-- 7. GAPS IN DATA
-- =============================================

-- Check for data gaps (missing time periods)
WITH time_gaps AS (
    SELECT 
        symbol,
        interval,
        display_time,
        LAG(display_time) OVER (PARTITION BY symbol, interval ORDER BY display_time) as prev_time,
        display_time - LAG(display_time) OVER (PARTITION BY symbol, interval ORDER BY display_time) as gap_duration
    FROM kline
    WHERE symbol = 'BTCUSDT' AND interval = '5m'
)
SELECT 
    symbol,
    interval,
    prev_time,
    display_time,
    gap_duration,
    CASE 
        WHEN gap_duration > INTERVAL '10 minutes' THEN 'LARGE_GAP'
        WHEN gap_duration > INTERVAL '5 minutes' THEN 'SMALL_GAP'
        ELSE 'NORMAL'
    END as gap_type
FROM time_gaps 
WHERE gap_duration > INTERVAL '5 minutes'
ORDER BY gap_duration DESC;

-- =============================================
-- 8. PRICE MOVEMENT ANALYSIS
-- =============================================

-- Price changes and trends
WITH price_changes AS (
    SELECT 
        symbol,
        interval,
        display_time,
        close,
        LAG(close) OVER (PARTITION BY symbol, interval ORDER BY display_time) as prev_close,
        close - LAG(close) OVER (PARTITION BY symbol, interval ORDER BY display_time) as price_change,
        ROUND((close - LAG(close) OVER (PARTITION BY symbol, interval ORDER BY display_time)) / LAG(close) OVER (PARTITION BY symbol, interval ORDER BY display_time) * 100, 4) as price_change_percent
    FROM kline
    WHERE symbol = 'BTCUSDT' AND interval = '5m'
)
SELECT 
    symbol,
    interval,
    COUNT(*) as total_changes,
    ROUND(AVG(price_change_percent), 4) as avg_change_percent,
    ROUND(MIN(price_change_percent), 4) as min_change_percent,
    ROUND(MAX(price_change_percent), 4) as max_change_percent,
    ROUND(STDDEV(price_change_percent), 4) as volatility,
    SUM(CASE WHEN price_change_percent > 0 THEN 1 ELSE 0 END) as positive_changes,
    SUM(CASE WHEN price_change_percent < 0 THEN 1 ELSE 0 END) as negative_changes
FROM price_changes 
WHERE prev_close IS NOT NULL
GROUP BY symbol, interval;

-- =============================================
-- 9. RECENT DATA VALIDATION
-- =============================================

-- Recent data validation (last 24 hours)
SELECT 
    'Recent Data Validation' as check_type,
    COUNT(*) as recent_klines,
    COUNT(DISTINCT symbol) as active_symbols,
    MAX(display_time) as latest_update,
    NOW() - MAX(display_time) as time_since_last_update,
    CASE 
        WHEN NOW() - MAX(display_time) > INTERVAL '1 hour' THEN 'WARNING: Stale data'
        WHEN NOW() - MAX(display_time) > INTERVAL '30 minutes' THEN 'CAUTION: Data may be stale'
        ELSE 'OK: Recent data available'
    END as data_freshness_status
FROM kline 
WHERE display_time >= NOW() - INTERVAL '24 hours';

-- =============================================
-- 10. DATA COMPLETENESS CHECK
-- =============================================

-- Check data completeness for each symbol/interval combination
SELECT 
    symbol,
    interval,
    COUNT(*) as actual_klines,
    CASE 
        WHEN interval = '1m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 60
        WHEN interval = '5m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 300
        WHEN interval = '15m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 900
        WHEN interval = '1h' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 3600
        ELSE 0
    END as expected_klines,
    ROUND(COUNT(*) * 100.0 / NULLIF(CASE 
        WHEN interval = '1m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 60
        WHEN interval = '5m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 300
        WHEN interval = '15m' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 900
        WHEN interval = '1h' THEN EXTRACT(EPOCH FROM (MAX(display_time) - MIN(display_time))) / 3600
        ELSE 1
    END, 0), 2) as completeness_percent
FROM kline 
GROUP BY symbol, interval 
ORDER BY completeness_percent ASC;

-- =============================================
-- 11. PERFORMANCE METRICS
-- =============================================

-- Query performance for kline table
SELECT 
    'Kline Table Performance' as metric_type,
    pg_size_pretty(pg_total_relation_size('kline')) as table_size,
    pg_size_pretty(pg_relation_size('kline')) as data_size,
    pg_size_pretty(pg_total_relation_size('kline') - pg_relation_size('kline')) as index_size,
    (SELECT COUNT(*) FROM pg_stat_user_indexes WHERE tablename = 'kline') as index_count,
    (SELECT n_tup_ins FROM pg_stat_user_tables WHERE tablename = 'kline') as total_inserts,
    (SELECT n_tup_upd FROM pg_stat_user_tables WHERE tablename = 'kline') as total_updates,
    (SELECT n_tup_del FROM pg_stat_user_tables WHERE tablename = 'kline') as total_deletes;
