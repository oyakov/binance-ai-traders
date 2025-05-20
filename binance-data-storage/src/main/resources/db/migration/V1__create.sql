-- public.accounts definition

-- Drop table

-- DROP TABLE public.accounts;

CREATE TABLE public.accounts (
	id serial4 NOT NULL,
	uid int8 NOT NULL,
	maker_commission int4 NOT NULL,
	taker_commission int4 NOT NULL,
	buyer_commission int4 NOT NULL,
	seller_commission int4 NOT NULL,
	can_trade bool NOT NULL,
	can_withdraw bool NOT NULL,
	can_deposit bool NOT NULL,
	brokered bool NOT NULL,
	require_self_trade_prevention bool NOT NULL,
	prevent_sor bool NOT NULL,
	account_type varchar NOT NULL,
	update_time int8 NOT NULL,
	balances json NOT NULL,
	commission_rates json NOT NULL,
	permissions json NOT NULL,
	CONSTRAINT accounts_pkey PRIMARY KEY (id)
);

-- public.kline definition

-- Drop table

-- DROP TABLE public.kline;

create table public.kline
(
    symbol                       varchar,
    interval                     varchar,
    timestamp                    bigint,
    display_time                 timestamp,
    open                         double precision,
    high                         double precision,
    low                          double precision,
    close                        double precision,
    volume                       double precision,
    open_time                    bigint,
    close_time                   bigint,
    display_close_time           timestamp,
    quote_asset_volume           double precision,
    number_of_trades             integer,
    taker_buy_base_asset_volume  double precision,
    taker_buy_quote_asset_volume double precision,
    ignore                       varchar
);

alter table public.kline
    owner to postgres;

create unique index kline_symbol_interval_opentime_idx
    on public.kline (symbol, interval, open_time, close_time);

-- public.macd definition

-- Drop table

-- DROP TABLE public.macd;

CREATE TABLE public.macd (
	id serial4 NOT NULL,
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
	sell float8 NULL,
	CONSTRAINT macd_pkey PRIMARY KEY (id)
);


-- public.macd_trend definition

-- Drop table

-- DROP TABLE public.macd_trend;

CREATE TABLE public.macd_trend (
	id serial4 NOT NULL,
	symbol varchar NULL,
	"timestamp" int8 NULL,
	display_time timestamp NULL,
	"interval" varchar NULL,
	trend varchar NULL,
	histogram float8 NULL,
	CONSTRAINT macd_trend_pkey PRIMARY KEY (id)
);

-- public.tickers definition

-- Drop table

-- DROP TABLE public.tickers;

CREATE TABLE public.tickers (
	id serial4 NOT NULL,
	symbol varchar NOT NULL,
	price_change float8 NULL,
	price_change_percent float8 NULL,
	weighted_avg_price float8 NULL,
	prev_close_price float8 NULL,
	last_price float8 NULL,
	last_qty float8 NULL,
	bid_price float8 NULL,
	bid_qty float8 NULL,
	ask_price float8 NULL,
	ask_qty float8 NULL,
	open_price float8 NULL,
	high_price float8 NULL,
	low_price float8 NULL,
	volume float8 NULL,
	quote_volume float8 NULL,
	open_time int8 NULL,
	dispay_open_time timestamp NULL,
	close_time int8 NULL,
	display_close_time timestamp NULL,
	first_id int8 NULL,
	last_id int8 NULL,
	count int4 NULL,
	CONSTRAINT tickers_pkey PRIMARY KEY (id)
);
