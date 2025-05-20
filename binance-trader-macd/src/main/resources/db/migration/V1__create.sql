
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
                               id SERIAL PRIMARY KEY,
                               symbol VARCHAR(10) NOT NULL,
                               order_id BIGINT NOT NULL UNIQUE,
                               parent_order_id BIGINT,
                               order_list_id INTEGER NOT NULL,
                               client_order_id VARCHAR(50) NOT NULL,
                               transact_time BIGINT,
                               display_transact_time TIMESTAMP,
                               price NUMERIC(20, 8) NOT NULL,
                               orig_qty NUMERIC(20, 8) NOT NULL,
                               executed_qty NUMERIC(20, 8) NOT NULL,
                               cummulative_quote_qty NUMERIC(20, 8) NOT NULL,
                               status VARCHAR(20) NOT NULL,
                               time_in_force VARCHAR(10) NOT NULL,
                               "type" VARCHAR(20) NOT NULL,
                               side VARCHAR(10) NOT NULL,
                               working_time BIGINT NOT NULL,
                               display_working_time TIMESTAMP NOT NULL,
                               self_trade_prevention_mode VARCHAR(20) NOT NULL,
                               fills JSON NOT NULL
);
