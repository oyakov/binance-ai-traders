#!/usr/bin/env python3
"""
Binance Kline Backfill Utility

Fetches historical kline/candlestick data from the Binance REST API and dumps it
to the local dataset folder, organized by symbol and interval.

Usage examples:
  python scripts/backfill/backfill_klines.py --symbol BTCUSDT --interval 5m --days 7
  python scripts/backfill/backfill_klines.py --symbol ETHUSDT --interval 1h \
      --start 2025-10-01 --end 2025-10-12 --format csv

Notes:
  - This script targets the public REST API and does not require API keys.
  - Binance returns at most 1000 klines per request; this script iterates over time
    windows until the requested range is fully downloaded.
  - Output is saved under datasets/klines/{symbol}/{interval}/ by default.
"""

from __future__ import annotations

import argparse
import csv
import datetime as dt
import json
import math
import os
import sys
import time
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple

import requests


BINANCE_DEFAULT_BASE_URL = os.environ.get("BINANCE_BASE_URL", "https://api.binance.com")
MAX_LIMIT = 1000  # Binance max klines per request


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Backfill historical kline data from Binance")
    parser.add_argument("--symbol", required=True, help="Trading pair symbol, e.g., BTCUSDT")
    parser.add_argument(
        "--interval",
        required=True,
        help="Kline interval (e.g., 1m, 3m, 5m, 15m, 1h, 4h, 1d)",
    )
    parser.add_argument(
        "--days",
        type=int,
        default=None,
        help="Number of trailing days to backfill (mutually exclusive with --start/--end)",
    )
    parser.add_argument(
        "--start",
        type=str,
        default=None,
        help="Start date (YYYY-MM-DD). Inclusive."
    )
    parser.add_argument(
        "--end",
        type=str,
        default=None,
        help="End date (YYYY-MM-DD). Exclusive at midnight. Defaults to now if omitted.",
    )
    parser.add_argument(
        "--output-dir",
        type=str,
        default=str(Path("datasets/klines")),
        help="Output base directory",
    )
    parser.add_argument(
        "--format",
        choices=["csv", "jsonl"],
        default="csv",
        help="Output file format (csv or jsonl)",
    )
    parser.add_argument(
        "--base-url",
        type=str,
        default=BINANCE_DEFAULT_BASE_URL,
        help="Binance REST base URL (default: %(default)s)",
    )
    parser.add_argument(
        "--throttle-ms",
        type=int,
        default=250,
        help="Throttle delay between paginated requests (ms)",
    )
    return parser.parse_args()


def date_to_ms(date: dt.datetime) -> int:
    return int(date.timestamp() * 1000)


def ms_to_date(ms: int) -> dt.datetime:
    return dt.datetime.utcfromtimestamp(ms / 1000)


def resolve_time_range(days: Optional[int], start: Optional[str], end: Optional[str], interval: str) -> Tuple[int, int]:
    if days is not None:
        end_dt = dt.datetime.utcnow()
        start_dt = end_dt - dt.timedelta(days=days)
        return date_to_ms(start_dt), date_to_ms(end_dt)

    if start is None and end is None:
        # Default to last 24 hours if nothing provided
        end_dt = dt.datetime.utcnow()
        start_dt = end_dt - dt.timedelta(days=1)
        return date_to_ms(start_dt), date_to_ms(end_dt)

    if start is None:
        raise ValueError("--start is required when --days is not provided")

    start_dt = dt.datetime.strptime(start, "%Y-%m-%d")
    if end is None:
        end_dt = dt.datetime.utcnow()
    else:
        end_dt = dt.datetime.strptime(end, "%Y-%m-%d")
    return date_to_ms(start_dt), date_to_ms(end_dt)


def get_klines(
    base_url: str,
    symbol: str,
    interval: str,
    start_ms: int,
    end_ms: int,
    throttle_ms: int,
) -> Iterable[List[Any]]:
    url = f"{base_url}/api/v3/klines"
    start = start_ms
    while start < end_ms:
        params = {
            "symbol": symbol.upper(),
            "interval": interval,
            "limit": MAX_LIMIT,
            "startTime": start,
            "endTime": end_ms,
        }
        resp = requests.get(url, params=params, timeout=30)
        resp.raise_for_status()
        batch = resp.json()
        if not batch:
            break
        for item in batch:
            yield item
        # Advance by last close time + 1 ms to avoid duplicates
        last_close = int(batch[-1][6])
        # Prevent infinite loops
        if last_close <= start:
            break
        start = last_close + 1
        time.sleep(throttle_ms / 1000.0)


def ensure_output_dir(base: Path, symbol: str, interval: str) -> Path:
    out_dir = base / symbol.upper() / interval
    out_dir.mkdir(parents=True, exist_ok=True)
    return out_dir


def write_csv(rows: Iterable[List[Any]], out_file: Path) -> int:
    header = [
        "open_time", "open", "high", "low", "close", "volume",
        "close_time", "quote_asset_volume", "num_trades",
        "taker_buy_base_volume", "taker_buy_quote_volume", "ignore",
    ]
    count = 0
    with out_file.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        for row in rows:
            writer.writerow(row)
            count += 1
    return count


def write_jsonl(rows: Iterable[List[Any]], out_file: Path) -> int:
    count = 0
    with out_file.open("w", encoding="utf-8") as f:
        for row in rows:
            obj = {
                "open_time": row[0],
                "open": row[1],
                "high": row[2],
                "low": row[3],
                "close": row[4],
                "volume": row[5],
                "close_time": row[6],
                "quote_asset_volume": row[7],
                "num_trades": row[8],
                "taker_buy_base_volume": row[9],
                "taker_buy_quote_volume": row[10],
            }
            f.write(json.dumps(obj) + "\n")
            count += 1
    return count


def main() -> int:
    args = parse_args()
    start_ms, end_ms = resolve_time_range(args.days, args.start, args.end, args.interval)

    out_base = Path(args.output_dir)
    out_dir = ensure_output_dir(out_base, args.symbol, args.interval)
    # filename using range in UTC
    start_iso = ms_to_date(start_ms).strftime("%Y%m%dT%H%M%SZ")
    end_iso = ms_to_date(end_ms).strftime("%Y%m%dT%H%M%SZ")
    ext = "csv" if args.format == "csv" else "jsonl"
    out_file = out_dir / f"{args.symbol.upper()}_{args.interval}_{start_iso}_{end_iso}.{ext}"

    rows = list(
        get_klines(
            base_url=args.base_url,
            symbol=args.symbol,
            interval=args.interval,
            start_ms=start_ms,
            end_ms=end_ms,
            throttle_ms=args.throttle_ms,
        )
    )

    if not rows:
        print("No klines returned for the requested range.")
        return 2

    if args.format == "csv":
        count = write_csv(rows, out_file)
    else:
        count = write_jsonl(rows, out_file)

    print(f"Saved {count} klines -> {out_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())


