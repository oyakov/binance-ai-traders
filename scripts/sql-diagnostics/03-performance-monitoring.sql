-- Database Performance Monitoring Queries
-- This script provides comprehensive performance monitoring and optimization insights

-- =============================================
-- 1. QUERY PERFORMANCE ANALYSIS
-- =============================================

-- Top 10 slowest queries
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    stddev_time,
    rows,
    100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent,
    shared_blks_hit,
    shared_blks_read,
    shared_blks_dirtied,
    shared_blks_written
FROM pg_stat_statements 
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_time DESC 
LIMIT 10;

-- =============================================
-- 2. INDEX EFFICIENCY ANALYSIS
-- =============================================

-- Index usage efficiency
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    CASE 
        WHEN idx_tup_read = 0 THEN 0 
        ELSE ROUND((idx_tup_fetch::numeric / idx_tup_read::numeric) * 100, 2) 
    END as hit_ratio_percent,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes 
ORDER BY idx_tup_read DESC;

-- Unused indexes (potential candidates for removal)
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) as index_size,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes 
WHERE idx_tup_read = 0
ORDER BY pg_relation_size(indexrelid) DESC;

-- =============================================
-- 3. TABLE SCAN ANALYSIS
-- =============================================

-- Sequential scan analysis
SELECT 
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    idx_tup_fetch,
    CASE 
        WHEN seq_scan = 0 THEN 0
        ELSE ROUND((seq_tup_read::numeric / seq_scan::numeric), 2)
    END as avg_tuples_per_seq_scan,
    CASE 
        WHEN idx_scan = 0 THEN 0
        ELSE ROUND((idx_tup_fetch::numeric / idx_scan::numeric), 2)
    END as avg_tuples_per_idx_scan
FROM pg_stat_user_tables 
WHERE seq_scan > 0 OR idx_scan > 0
ORDER BY seq_tup_read DESC;

-- =============================================
-- 4. CACHE HIT RATIOS
-- =============================================

-- Buffer cache hit ratios
SELECT 
    'Buffer Cache Hit Ratio' as metric_name,
    ROUND(
        (sum(blks_hit) * 100.0 / (sum(blks_hit) + sum(blks_read))), 
        2
    ) as hit_ratio_percent,
    sum(blks_hit) as blocks_hit,
    sum(blks_read) as blocks_read
FROM pg_stat_database 
WHERE datname = 'binance_trader_testnet';

-- =============================================
-- 5. CONNECTION MONITORING
-- =============================================

-- Active connections by state
SELECT 
    state,
    COUNT(*) as connection_count,
    ROUND(AVG(EXTRACT(EPOCH FROM (now() - query_start))), 2) as avg_duration_seconds
FROM pg_stat_activity 
WHERE datname = 'binance_trader_testnet'
GROUP BY state
ORDER BY connection_count DESC;

-- Long-running queries
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    EXTRACT(EPOCH FROM (now() - query_start)) as duration_seconds,
    LEFT(query, 100) as query_preview
FROM pg_stat_activity 
WHERE datname = 'binance_trader_testnet'
AND state = 'active'
AND query NOT LIKE '%pg_stat_activity%'
ORDER BY duration_seconds DESC;

-- =============================================
-- 6. LOCK ANALYSIS
-- =============================================

-- Current lock analysis
SELECT 
    l.locktype,
    l.mode,
    l.granted,
    COUNT(*) as lock_count,
    STRING_AGG(DISTINCT a.usename, ', ') as users,
    STRING_AGG(DISTINCT a.application_name, ', ') as applications
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.database = (SELECT oid FROM pg_database WHERE datname = 'binance_trader_testnet')
GROUP BY l.locktype, l.mode, l.granted
ORDER BY lock_count DESC;

-- Blocked queries
SELECT 
    blocked_locks.pid AS blocked_pid,
    blocked_activity.usename AS blocked_user,
    blocking_locks.pid AS blocking_pid,
    blocking_activity.usename AS blocking_user,
    blocked_activity.query AS blocked_statement,
    blocking_activity.query AS current_statement_in_blocking_process
FROM pg_catalog.pg_locks blocked_locks
JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid
JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype
    AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
    AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
    AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
    AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
    AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
    AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
    AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
    AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
    AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
    AND blocking_locks.pid != blocked_locks.pid
JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid
WHERE NOT blocked_locks.granted;

-- =============================================
-- 7. VACUUM AND MAINTENANCE ANALYSIS
-- =============================================

-- Vacuum and analyze statistics
SELECT 
    schemaname,
    tablename,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze,
    vacuum_count,
    autovacuum_count,
    analyze_count,
    autoanalyze_count,
    n_dead_tup,
    n_live_tup,
    ROUND((n_dead_tup::numeric / NULLIF(n_live_tup + n_dead_tup, 0)) * 100, 2) as dead_tuple_percent
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;

-- Tables needing vacuum
SELECT 
    schemaname,
    tablename,
    n_dead_tup,
    n_live_tup,
    ROUND((n_dead_tup::numeric / NULLIF(n_live_tup + n_dead_tup, 0)) * 100, 2) as dead_tuple_percent,
    last_autovacuum,
    CASE 
        WHEN (n_dead_tup::numeric / NULLIF(n_live_tup + n_dead_tup, 0)) > 0.1 THEN 'HIGH'
        WHEN (n_dead_tup::numeric / NULLIF(n_live_tup + n_dead_tup, 0)) > 0.05 THEN 'MEDIUM'
        ELSE 'LOW'
    END as vacuum_priority
FROM pg_stat_user_tables
WHERE n_dead_tup > 0
ORDER BY dead_tuple_percent DESC;

-- =============================================
-- 8. DISK I/O ANALYSIS
-- =============================================

-- Disk I/O statistics
SELECT 
    'Database I/O' as metric_type,
    ROUND(blk_read_time::numeric, 2) as read_time_ms,
    ROUND(blk_write_time::numeric, 2) as write_time_ms,
    ROUND((blk_read_time + blk_write_time)::numeric, 2) as total_io_time_ms,
    ROUND(blk_read_time::numeric / NULLIF(blks_read, 0), 4) as avg_read_time_per_block,
    ROUND(blk_write_time::numeric / NULLIF(blks_written, 0), 4) as avg_write_time_per_block
FROM pg_stat_database 
WHERE datname = 'binance_trader_testnet';

-- =============================================
-- 9. MEMORY USAGE
-- =============================================

-- Shared buffer usage
SELECT 
    'Shared Buffers' as buffer_type,
    setting as buffer_size,
    pg_size_pretty(setting::bigint * 8192) as buffer_size_pretty
FROM pg_settings 
WHERE name = 'shared_buffers';

-- Current shared buffer usage
SELECT 
    'Current Buffer Usage' as metric_type,
    COUNT(*) as total_buffers,
    COUNT(*) * 8192 as total_size_bytes,
    pg_size_pretty(COUNT(*) * 8192) as total_size_pretty
FROM pg_buffercache;

-- =============================================
-- 10. PERFORMANCE RECOMMENDATIONS
-- =============================================

-- Performance recommendations based on current stats
WITH recommendations AS (
    SELECT 
        'Low Cache Hit Ratio' as issue,
        'Consider increasing shared_buffers or effective_cache_size' as recommendation,
        'HIGH' as priority
    WHERE (
        SELECT ROUND((sum(blks_hit) * 100.0 / (sum(blks_hit) + sum(blks_read))), 2)
        FROM pg_stat_database 
        WHERE datname = 'binance_trader_testnet'
    ) < 90
    
    UNION ALL
    
    SELECT 
        'High Dead Tuple Ratio' as issue,
        'Run VACUUM on tables with high dead tuple percentage' as recommendation,
        'MEDIUM' as priority
    WHERE EXISTS (
        SELECT 1 FROM pg_stat_user_tables 
        WHERE (n_dead_tup::numeric / NULLIF(n_live_tup + n_dead_tup, 0)) > 0.1
    )
    
    UNION ALL
    
    SELECT 
        'Unused Indexes' as issue,
        'Consider dropping unused indexes to improve write performance' as recommendation,
        'LOW' as priority
    WHERE EXISTS (
        SELECT 1 FROM pg_stat_user_indexes 
        WHERE idx_tup_read = 0 AND pg_relation_size(indexrelid) > 1024*1024
    )
    
    UNION ALL
    
    SELECT 
        'Long Running Queries' as issue,
        'Investigate and optimize long-running queries' as recommendation,
        'HIGH' as priority
    WHERE EXISTS (
        SELECT 1 FROM pg_stat_activity 
        WHERE state = 'active' AND (now() - query_start) > interval '5 minutes'
        AND datname = 'binance_trader_testnet'
    )
)
SELECT 
    issue,
    recommendation,
    priority
FROM recommendations
ORDER BY 
    CASE priority 
        WHEN 'HIGH' THEN 1 
        WHEN 'MEDIUM' THEN 2 
        WHEN 'LOW' THEN 3 
    END;
