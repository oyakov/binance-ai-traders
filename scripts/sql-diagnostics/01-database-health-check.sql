-- Database Health Check Queries
-- This script provides comprehensive database health monitoring queries

-- =============================================
-- 1. DATABASE OVERVIEW
-- =============================================

-- Database size and basic info
SELECT 
    pg_database.datname as database_name,
    pg_size_pretty(pg_database_size(pg_database.datname)) as database_size,
    pg_database.encoding as encoding,
    pg_database.datcollate as collation
FROM pg_database 
WHERE datname = 'binance_trader_testnet';

-- =============================================
-- 2. TABLE STATISTICS
-- =============================================

-- Table sizes and row counts
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as total_size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples
FROM pg_stat_user_tables 
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =============================================
-- 3. INDEX USAGE STATISTICS
-- =============================================

-- Index usage statistics
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_tup_read,
    idx_tup_fetch,
    CASE 
        WHEN idx_tup_read = 0 THEN 0 
        ELSE ROUND((idx_tup_fetch::numeric / idx_tup_read::numeric) * 100, 2) 
    END as hit_ratio_percent
FROM pg_stat_user_indexes 
ORDER BY idx_tup_read DESC;

-- =============================================
-- 4. CONNECTION STATISTICS
-- =============================================

-- Current connections
SELECT 
    state,
    COUNT(*) as connection_count
FROM pg_stat_activity 
WHERE datname = 'binance_trader_testnet'
GROUP BY state;

-- Connection details
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query_start,
    state_change,
    query
FROM pg_stat_activity 
WHERE datname = 'binance_trader_testnet'
ORDER BY query_start DESC;

-- =============================================
-- 5. LOCK INFORMATION
-- =============================================

-- Current locks
SELECT 
    l.locktype,
    l.database,
    l.relation,
    l.page,
    l.tuple,
    l.virtualxid,
    l.transactionid,
    l.classid,
    l.objid,
    l.objsubid,
    l.virtualtransaction,
    l.pid,
    l.mode,
    l.granted,
    a.usename,
    a.query,
    a.query_start,
    a.state
FROM pg_locks l
LEFT JOIN pg_stat_activity a ON l.pid = a.pid
WHERE l.database = (SELECT oid FROM pg_database WHERE datname = 'binance_trader_testnet')
ORDER BY l.pid;

-- =============================================
-- 6. QUERY PERFORMANCE
-- =============================================

-- Slow queries (if log_min_duration is set)
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    stddev_time,
    rows,
    100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS hit_percent
FROM pg_stat_statements 
WHERE query NOT LIKE '%pg_stat_statements%'
ORDER BY total_time DESC 
LIMIT 10;

-- =============================================
-- 7. VACUUM AND ANALYZE STATISTICS
-- =============================================

-- Last vacuum and analyze times
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
    autoanalyze_count
FROM pg_stat_user_tables
ORDER BY last_analyze DESC NULLS LAST;

-- =============================================
-- 8. DISK USAGE
-- =============================================

-- Database disk usage by table
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size,
    pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) as table_size,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) - pg_relation_size(schemaname||'.'||tablename)) as index_size
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- =============================================
-- 9. SYSTEM RESOURCE USAGE
-- =============================================

-- Check for long-running queries
SELECT 
    pid,
    now() - pg_stat_activity.query_start AS duration,
    query,
    state
FROM pg_stat_activity 
WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes'
AND state = 'active'
AND datname = 'binance_trader_testnet';

-- =============================================
-- 10. HEALTH SUMMARY
-- =============================================

-- Overall health summary
SELECT 
    'Database Health Summary' as check_type,
    CASE 
        WHEN (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND datname = 'binance_trader_testnet') > 10 
        THEN 'WARNING: High active connections'
        ELSE 'OK: Normal connection count'
    END as connection_status,
    CASE 
        WHEN (SELECT COUNT(*) FROM pg_locks WHERE NOT granted) > 0 
        THEN 'WARNING: Blocked queries detected'
        ELSE 'OK: No blocked queries'
    END as lock_status,
    CASE 
        WHEN (SELECT COUNT(*) FROM pg_stat_activity WHERE state = 'active' AND (now() - query_start) > interval '10 minutes') > 0 
        THEN 'WARNING: Long-running queries detected'
        ELSE 'OK: No long-running queries'
    END as performance_status;
