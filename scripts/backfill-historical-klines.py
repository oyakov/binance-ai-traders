#!/usr/bin/env python3
"""
Historical Kline Data Backfill Script for Binance AI Traders
Purpose: Fetch and backfill historical kline data into PostgreSQL database
Date: October 11, 2025
"""

import argparse
import time
import sys
from datetime import datetime, timedelta
import requests
import psycopg2
from psycopg2.extras import execute_values

# Configuration
ALL_SYMBOLS = ["BTCUSDT", "ETHUSDT", "BNBUSDT", "ADAUSDT", "DOGEUSDT", 
               "XRPUSDT", "DOTUSDT", "LTCUSDT", "LINKUSDT", "UNIUSDT"]

ALL_INTERVALS = ["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "8h", "12h", "1d", "3d", "1w", "1M"]

INTERVAL_MS = {
    "1m": 60000,
    "3m": 180000,
    "5m": 300000,
    "15m": 900000,
    "30m": 1800000,
    "1h": 3600000,
    "2h": 7200000,
    "4h": 14400000,
    "6h": 21600000,
    "8h": 28800000,
    "12h": 43200000,
    "1d": 86400000,
    "3d": 259200000,
    "1w": 604800000,
    "1M": 2592000000
}

def fetch_klines_from_binance(symbol, interval, start_time, end_time, api_url):
    """Fetch historical klines from Binance API"""
    url = f"{api_url}/api/v3/klines"
    params = {
        "symbol": symbol,
        "interval": interval,
        "startTime": start_time,
        "endTime": end_time,
        "limit": 1000
    }
    
    try:
        response = requests.get(url, params=params, timeout=30)
        response.raise_for_status()
        return response.json()
    except Exception as e:
        print(f"    ERROR fetching data: {e}")
        return None

def insert_klines_to_db(conn, symbol, interval, klines, dry_run=False):
    """Insert klines into PostgreSQL database"""
    if not klines:
        return 0, 0
    
    inserted = 0
    skipped = 0
    
    cursor = conn.cursor()
    
    for kline in klines:
        open_time, open_price, high, low, close, volume, close_time, quote_volume, trades, taker_buy_base, taker_buy_quote, _ = kline
        
        timestamp = open_time
        display_time = datetime.fromtimestamp(open_time / 1000).strftime('%Y-%m-%d %H:%M:%S')
        display_close_time = datetime.fromtimestamp(close_time / 1000).strftime('%Y-%m-%d %H:%M:%S')
        
        if dry_run:
            print(f"    [DRY RUN] Would insert: {symbol} {interval} @ {display_time}")
            inserted += 1
            continue
        
        try:
            cursor.execute("""
                INSERT INTO kline (
                    symbol, interval, timestamp, display_time,
                    open, high, low, close, volume,
                    open_time, close_time, display_close_time,
                    quote_asset_volume, number_of_trades,
                    taker_buy_base_asset_volume, taker_buy_quote_asset_volume
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
                ON CONFLICT (symbol, interval, open_time) DO NOTHING
            """, (
                symbol, interval, timestamp, display_time,
                float(open_price), float(high), float(low), float(close), float(volume),
                open_time, close_time, display_close_time,
                float(quote_volume), int(trades),
                float(taker_buy_base), float(taker_buy_quote)
            ))
            
            if cursor.rowcount > 0:
                inserted += 1
            else:
                skipped += 1
                
        except Exception as e:
            print(f"    WARNING: Insert failed: {e}")
            skipped += 1
    
    conn.commit()
    cursor.close()
    
    return inserted, skipped

def backfill_symbol_interval(symbol, interval, days_back, api_url, db_conn, dry_run=False):
    """Backfill historical data for a specific symbol and interval"""
    print(f"\nProcessing: {symbol} {interval}")
    print(f"  Days back: {days_back}")
    
    # Calculate time range
    end_time = int(datetime.utcnow().timestamp() * 1000)
    start_time = end_time - (days_back * 86400000)
    
    interval_ms = INTERVAL_MS.get(interval)
    if not interval_ms:
        print(f"  ERROR: Unknown interval {interval}")
        return
    
    print(f"  Time range: {datetime.fromtimestamp(start_time/1000)} to {datetime.fromtimestamp(end_time/1000)}")
    
    current_start = start_time
    total_inserted = 0
    total_skipped = 0
    batch_count = 0
    
    while current_start < end_time:
        batch_count += 1
        current_end = min(current_start + (1000 * interval_ms), end_time)
        
        print(f"  Batch {batch_count}: Fetching klines...", end=" ", flush=True)
        
        klines = fetch_klines_from_binance(symbol, interval, current_start, current_end, api_url)
        
        if not klines:
            print("No data")
            break
        
        print(f"Got {len(klines)} klines")
        
        inserted, skipped = insert_klines_to_db(db_conn, symbol, interval, klines, dry_run)
        total_inserted += inserted
        total_skipped += skipped
        
        # Move to next batch
        last_kline_time = int(klines[-1][0])
        current_start = last_kline_time + interval_ms
        
        # Rate limiting
        time.sleep(0.1)
    
    print(f"  ✓ Complete: Inserted {total_inserted}, Skipped {total_skipped} (already exist)")

def main():
    parser = argparse.ArgumentParser(description="Backfill historical kline data")
    parser.add_argument("--symbol", default="BTCUSDT", help="Trading symbol")
    parser.add_argument("--interval", default="1d", help="Kline interval")
    parser.add_argument("--days-back", type=int, default=60, help="Number of days to backfill")
    parser.add_argument("--api-url", default="https://testnet.binance.vision", help="Binance API URL")
    parser.add_argument("--db-host", default="localhost", help="Database host")
    parser.add_argument("--db-port", type=int, default=5433, help="Database port")
    parser.add_argument("--db-name", default="binance_trader_testnet", help="Database name")
    parser.add_argument("--db-user", default="testnet_user", help="Database user")
    parser.add_argument("--db-password", default="testnet_password", help="Database password")
    parser.add_argument("--all-symbols", action="store_true", help="Backfill all symbols")
    parser.add_argument("--dry-run", action="store_true", help="Dry run mode (no database inserts)")
    
    args = parser.parse_args()
    
    print("\n================================")
    print("   Historical Kline Backfill   ")
    print("================================\n")
    
    if args.dry_run:
        print("[DRY RUN MODE - No data will be inserted]\n")
    
    print("Configuration:")
    print(f"  Database: {args.db_host}:{args.db_port}/{args.db_name}")
    print(f"  API URL: {args.api_url}\n")
    
    # Connect to database
    try:
        conn = psycopg2.connect(
            host=args.db_host,
            port=args.db_port,
            database=args.db_name,
            user=args.db_user,
            password=args.db_password
        )
        print("✓ Database connected\n")
    except Exception as e:
        print(f"ERROR: Could not connect to database: {e}")
        sys.exit(1)
    
    try:
        if args.all_symbols:
            print("Backfilling ALL symbols and intervals...")
            print("This will take a LONG time!\n")
            
            for symbol in ALL_SYMBOLS:
                for interval in ALL_INTERVALS:
                    backfill_symbol_interval(symbol, interval, args.days_back, args.api_url, conn, args.dry_run)
        else:
            backfill_symbol_interval(args.symbol, args.interval, args.days_back, args.api_url, conn, args.dry_run)
    
    finally:
        conn.close()
    
    print("\n================================")
    print("   Backfill Complete!          ")
    print("================================\n")
    print("Done!")

if __name__ == "__main__":
    main()

