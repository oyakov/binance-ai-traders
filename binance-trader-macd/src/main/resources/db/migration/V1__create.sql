
-- public.order_books definition

-- Drop table

-- DROP TABLE public.order_books;

CREATE TABLE public.order_books (
                                    id BIGINT AUTO_INCREMENT NOT NULL,
                                    symbol VARCHAR(255) NOT NULL,
                                    last_update_id BIGINT NOT NULL,
                                    tx_time TIMESTAMP NOT NULL,
                                    "type" VARCHAR(255) NOT NULL,
                                    price BIGINT NOT NULL,
                                    quantity BIGINT NOT NULL,
                                    CONSTRAINT order_books_pkey PRIMARY KEY (id)
);


-- public.orders definition

-- Drop table

-- DROP TABLE public.orders;

CREATE TABLE public.orders (
                               id BIGINT AUTO_INCREMENT PRIMARY KEY,
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
                               fills CLOB NOT NULL
);
