-- Ensure MACD upserts are possible by adding a unique index on (symbol, interval, timestamp)
CREATE UNIQUE INDEX IF NOT EXISTS macd_symbol_interval_timestamp_idx
    ON public.macd (symbol, "interval", "timestamp");


