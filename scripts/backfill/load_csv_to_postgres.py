#!/usr/bin/env python3
"""
Load CSV kline datasets (exported by backfill_klines.py) into a PostgreSQL table.

Assumes CSV header fields from backfill_klines.py and loads into table `kline`
with a compatible schema: (open_time BIGINT, open NUMERIC, high NUMERIC, low
NUMERIC, close NUMERIC, volume NUMERIC, close_time BIGINT, quote_asset_volume
NUMERIC, num_trades INT, taker_buy_base_volume NUMERIC, taker_buy_quote_volume
NUMERIC).

Usage:
  python scripts/backfill/load_csv_to_postgres.py --file datasets/klines/BTCUSDT/5m/*.csv \
      --host localhost --port 5433 --db binance_trader_testnet --user testnet_user --password testnet_password \
      --symbol BTCUSDT --interval 5m
"""

from __future__ import annotations
import argparse
import csv
import glob
import os
import sys
import psycopg2


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description='Load kline CSV files into PostgreSQL')
    p.add_argument('--file', required=True, help='CSV file path or glob pattern')
    p.add_argument('--host', default=os.getenv('PGHOST', 'localhost'))
    p.add_argument('--port', type=int, default=int(os.getenv('PGPORT', '5433')))
    p.add_argument('--db', default=os.getenv('PGDATABASE', 'binance_trader_testnet'))
    p.add_argument('--user', default=os.getenv('PGUSER', 'testnet_user'))
    p.add_argument('--password', default=os.getenv('PGPASSWORD', 'testnet_password'))
    p.add_argument('--symbol', required=True)
    p.add_argument('--interval', required=True)
    return p.parse_args()


INSERT_SQL = (
    'INSERT INTO kline ('
    'open_time, open, high, low, close, volume, close_time, quote_volume, number_of_trades, taker_buy_base_volume, taker_buy_quote_volume, symbol, interval, display_time'
    ') VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s, to_timestamp(%s/1000))'
)


def main() -> int:
    args = parse_args()
    files = glob.glob(args.file)
    if not files:
        print('No files matched')
        return 2
    conn = psycopg2.connect(host=args.host, port=args.port, dbname=args.db, user=args.user, password=args.password)
    conn.autocommit = False
    cur = conn.cursor()
    total = 0
    try:
        for f in files:
            with open(f, newline='', encoding='utf-8') as fh:
                reader = csv.DictReader(fh)
                for row in reader:
                    vals = (
                        int(row['open_time']), float(row['open']), float(row['high']), float(row['low']), float(row['close']),
                        float(row['volume']), int(row['close_time']), float(row['quote_asset_volume']), int(row['num_trades']),
                        float(row['taker_buy_base_volume']), float(row['taker_buy_quote_volume']), args.symbol, args.interval, int(row['open_time'])
                    )
                    cur.execute(INSERT_SQL, vals)
                    total += 1
        conn.commit()
    except Exception as e:
        conn.rollback()
        print('Error:', e)
        return 1
    finally:
        cur.close()
        conn.close()
    print(f'Inserted {total} rows into kline')
    return 0


if __name__ == '__main__':
    sys.exit(main())


