-- Backfill 1d klines by aggregating 1m data
WITH params AS (
    SELECT 86400000::bigint AS period_ms, '1d'::varchar AS target_interval
), base AS (
    SELECT k.symbol,
           (k.open_time/params.period_ms)*params.period_ms AS bucket_start,
           MIN(k.open_time) AS min_open_time,
           MAX(k.close_time) AS max_close_time
    FROM kline k, params
    WHERE k.interval = '1m'
    GROUP BY k.symbol, bucket_start
), agg AS (
    SELECT b.symbol,
           b.min_open_time,
           b.max_close_time,
           (SELECT k1.open FROM kline k1
             WHERE k1.symbol=b.symbol AND k1.interval='1m' AND k1.open_time=b.min_open_time
             LIMIT 1) AS open,
           (SELECT k1.close FROM kline k1
             WHERE k1.symbol=b.symbol AND k1.interval='1m' AND k1.close_time=b.max_close_time
             LIMIT 1) AS close,
           (SELECT MAX(k1.high) FROM kline k1
             WHERE k1.symbol=b.symbol AND k1.interval='1m'
               AND k1.open_time>=b.min_open_time AND k1.close_time<=b.max_close_time) AS high,
           (SELECT MIN(k1.low) FROM kline k1
             WHERE k1.symbol=b.symbol AND k1.interval='1m'
               AND k1.open_time>=b.min_open_time AND k1.close_time<=b.max_close_time) AS low,
           (SELECT SUM(k1.volume) FROM kline k1
             WHERE k1.symbol=b.symbol AND k1.interval='1m'
               AND k1.open_time>=b.min_open_time AND k1.close_time<=b.max_close_time) AS volume
    FROM base b
)
INSERT INTO kline (
    symbol, interval, timestamp, display_time, open, high, low, close, volume,
    open_time, close_time, display_close_time,
    quote_asset_volume, number_of_trades, taker_buy_base_asset_volume, taker_buy_quote_asset_volume, ignore
)
SELECT a.symbol,
       params.target_interval,
       a.max_close_time,
       to_timestamp(a.min_open_time/1000),
       a.open, a.high, a.low, a.close, a.volume,
       a.min_open_time, a.max_close_time, to_timestamp(a.max_close_time/1000),
       NULL, NULL, NULL, NULL, NULL
FROM agg a, params
ON CONFLICT (symbol, interval, open_time, close_time) DO NOTHING;


