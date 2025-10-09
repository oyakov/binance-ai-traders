-- Ensure MACD table exists (idempotent) and add unique index for upserts
CREATE TABLE IF NOT EXISTS public.macd (
    id serial4 PRIMARY KEY,
    symbol varchar NULL,
    "interval" varchar NULL,
    collection_time timestamp NULL,
    display_time timestamp NULL,
    "timestamp" int8 NULL,
    ema_fast float8 NULL,
    ema_slow float8 NULL,
    macd float8 NULL,
    signal float8 NULL,
    histogram float8 NULL,
    signal_buy float8 NULL,
    signal_sell float8 NULL,
    volume_signal float8 NULL,
    buy float8 NULL,
    sell float8 NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS macd_symbol_interval_timestamp_idx
    ON public.macd (symbol, "interval", "timestamp");


