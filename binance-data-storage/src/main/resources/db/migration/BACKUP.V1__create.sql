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


-- public.calendar_dom definition

-- Drop table

-- DROP TABLE public.calendar_dom;

CREATE TABLE public.calendar_dom (
	id serial4 NOT NULL,
	day_1 bool NULL,
	day_2 bool NULL,
	day_3 bool NULL,
	day_4 bool NULL,
	day_5 bool NULL,
	day_6 bool NULL,
	day_7 bool NULL,
	day_8 bool NULL,
	day_9 bool NULL,
	day_10 bool NULL,
	day_11 bool NULL,
	day_12 bool NULL,
	day_13 bool NULL,
	day_14 bool NULL,
	day_15 bool NULL,
	day_16 bool NULL,
	day_17 bool NULL,
	day_18 bool NULL,
	day_19 bool NULL,
	day_20 bool NULL,
	day_21 bool NULL,
	day_22 bool NULL,
	day_23 bool NULL,
	day_24 bool NULL,
	day_25 bool NULL,
	day_26 bool NULL,
	day_27 bool NULL,
	day_28 bool NULL,
	day_29 bool NULL,
	day_30 bool NULL,
	day_31 bool NULL,
	CONSTRAINT calendar_dom_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_calendar_dom_id ON public.calendar_dom USING btree (id);


-- public.calendar_dow definition

-- Drop table

-- DROP TABLE public.calendar_dow;

CREATE TABLE public.calendar_dow (
	id serial4 NOT NULL,
	monday bool NULL,
	tuesday bool NULL,
	wednesday bool NULL,
	thursday bool NULL,
	friday bool NULL,
	saturday bool NULL,
	sunday bool NULL,
	CONSTRAINT calendar_dow_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_calendar_dow_id ON public.calendar_dow USING btree (id);


-- public.calendar_moy definition

-- Drop table

-- DROP TABLE public.calendar_moy;

CREATE TABLE public.calendar_moy (
	id serial4 NOT NULL,
	january bool NULL,
	february bool NULL,
	march bool NULL,
	april bool NULL,
	may bool NULL,
	june bool NULL,
	july bool NULL,
	august bool NULL,
	september bool NULL,
	october bool NULL,
	november bool NULL,
	december bool NULL,
	CONSTRAINT calendar_moy_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_calendar_moy_id ON public.calendar_moy USING btree (id);


-- public.calendar_tod definition

-- Drop table

-- DROP TABLE public.calendar_tod;

CREATE TABLE public.calendar_tod (
	id serial4 NOT NULL,
	time_10_00 bool NULL,
	time_12_00 bool NULL,
	time_14_00 bool NULL,
	time_16_00 bool NULL,
	time_18_00 bool NULL,
	time_20_00 bool NULL,
	time_22_00 bool NULL,
	CONSTRAINT calendar_tod_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_calendar_tod_id ON public.calendar_tod USING btree (id);


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


-- public.order_books definition

-- Drop table

-- DROP TABLE public.order_books;

CREATE TABLE public.order_books (
	id serial4 NOT NULL,
	symbol varchar NOT NULL,
	last_update_id int8 NOT NULL,
	tx_time timestamp NOT NULL,
	"type" varchar NOT NULL,
	price int8 NOT NULL,
	quantity int8 NOT NULL,
	CONSTRAINT order_books_pkey PRIMARY KEY (id)
);


-- public.orders definition

-- Drop table

-- DROP TABLE public.orders;

CREATE TABLE public.orders (
	id serial4 NOT NULL,
	symbol varchar(10) NOT NULL,
	order_id int8 NOT NULL,
	order_list_id int4 NOT NULL,
	client_order_id varchar(50) NOT NULL,
	transact_time int8 NOT NULL,
	display_transact_time timestamp NOT NULL,
	price float8 NOT NULL,
	orig_qty float8 NOT NULL,
	executed_qty float8 NOT NULL,
	cummulative_quote_qty float8 NOT NULL,
	status varchar(20) NOT NULL,
	time_in_force varchar(10) NOT NULL,
	"type" varchar(20) NOT NULL,
	side varchar(10) NOT NULL,
	working_time int8 NOT NULL,
	display_working_time timestamp NOT NULL,
	self_trade_prevention_mode varchar(20) NOT NULL,
	fills json NOT NULL,
	CONSTRAINT orders_order_id_key UNIQUE (order_id),
	CONSTRAINT orders_pkey PRIMARY KEY (id)
);


-- public.payment_method definition

-- Drop table

-- DROP TABLE public.payment_method;

CREATE TABLE public.payment_method (
	id serial4 NOT NULL,
	short_name varchar NULL,
	description varchar NULL,
	"comment" varchar NULL,
	CONSTRAINT payment_method_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_payment_method_id ON public.payment_method USING btree (id);


-- public.product definition

-- Drop table

-- DROP TABLE public.product;

CREATE TABLE public.product (
	id serial4 NOT NULL,
	short_name varchar NULL,
	display_name varchar NULL,
	description varchar NULL,
	"comment" varchar NULL,
	price varchar NULL,
	image1 varchar NULL,
	image2 varchar NULL,
	delivery_qr_code varchar NULL,
	tracker_ticket varchar NULL,
	CONSTRAINT product_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_product_id ON public.product USING btree (id);


-- public.telegram_group definition

-- Drop table

-- DROP TABLE public.telegram_group;

CREATE TABLE public.telegram_group (
	id serial4 NOT NULL,
	chat_id varchar NULL,
	worker_bot_instance_id int4 NULL,
	owner_username varchar NULL,
	display_name varchar NULL,
	t_me_url varchar NULL,
	CONSTRAINT telegram_group_chat_id_key UNIQUE (chat_id),
	CONSTRAINT telegram_group_pkey PRIMARY KEY (id)
);
CREATE INDEX ix_telegram_group_id ON public.telegram_group USING btree (id);
CREATE INDEX ix_telegram_group_owner_username ON public.telegram_group USING btree (owner_username);
CREATE INDEX ix_telegram_group_worker_bot_instance_id ON public.telegram_group USING btree (worker_bot_instance_id);


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


-- public.calendar_data definition

-- Drop table

-- DROP TABLE public.calendar_data;

CREATE TABLE public.calendar_data (
	id serial4 NOT NULL,
	dow_id int4 NOT NULL,
	dom_id int4 NOT NULL,
	moy_id int4 NOT NULL,
	tod_id int4 NOT NULL,
	chat_id varchar NOT NULL,
	"data" varchar NOT NULL,
	username varchar NOT NULL,
	CONSTRAINT calendar_data_pkey PRIMARY KEY (id),
	CONSTRAINT calendar_data_chat_id_fkey FOREIGN KEY (chat_id) REFERENCES public.telegram_group(chat_id),
	CONSTRAINT calendar_data_dom_id_fkey FOREIGN KEY (dom_id) REFERENCES public.calendar_dom(id),
	CONSTRAINT calendar_data_dow_id_fkey FOREIGN KEY (dow_id) REFERENCES public.calendar_dow(id),
	CONSTRAINT calendar_data_moy_id_fkey FOREIGN KEY (moy_id) REFERENCES public.calendar_moy(id),
	CONSTRAINT calendar_data_tod_id_fkey FOREIGN KEY (tod_id) REFERENCES public.calendar_tod(id)
);
CREATE INDEX ix_calendar_data_id ON public.calendar_data USING btree (id);