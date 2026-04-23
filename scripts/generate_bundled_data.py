#!/usr/bin/env python3
from __future__ import annotations

import json
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any


ASSETS = [
    ("spy", "SPY", "SPDR S&P 500 ETF", "Major ETF"),
    ("voo", "VOO", "Vanguard S&P 500 ETF", "Major ETF"),
    ("vti", "VTI", "Vanguard Total Stock Market ETF", "Major ETF"),
    ("qqq", "QQQ", "Invesco Nasdaq-100 ETF", "Major ETF"),
    ("dia", "DIA", "SPDR Dow Jones ETF", "Major ETF"),
    ("aapl", "AAPL", "Apple", "Magnificent 7"),
    ("msft", "MSFT", "Microsoft", "Magnificent 7"),
    ("nvda", "NVDA", "NVIDIA", "Magnificent 7"),
    ("amzn", "AMZN", "Amazon", "Magnificent 7"),
    ("googl", "GOOGL", "Alphabet", "Magnificent 7"),
    ("meta", "META", "Meta", "Magnificent 7"),
    ("tsla", "TSLA", "Tesla", "Magnificent 7"),
]


@dataclass
class AssetHistory:
    asset: str
    symbol: str
    display_name: str
    category_label: str
    monthly_bars: list[dict[str, Any]]
    recent_bars: list[dict[str, Any]]
    six_month_bars: list[dict[str, Any]]
    yearly_bars: list[dict[str, Any]]


def iso_date(timestamp: int | float) -> str:
    return (
        datetime.fromtimestamp(timestamp, tz=timezone.utc)
        .replace(microsecond=0)
        .isoformat()
        .replace("+00:00", "Z")
    )


def fetch_bars(symbol: str, interval: str, start: int, end: int) -> list[dict[str, Any]]:
    url = (
        f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}"
        f"?interval={interval}&period1={start}&period2={end}"
        "&events=div%2Csplits&includeAdjustedClose=true"
    )
    request = urllib.request.Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json",
        },
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.load(response)

    result = payload["chart"]["result"][0]
    quote = result["indicators"]["quote"][0]
    adjusted = result["indicators"]["adjclose"][0]["adjclose"]
    bars: list[dict[str, Any]] = []

    for index, timestamp in enumerate(result["timestamp"]):
        open_price = quote["open"][index]
        high = quote["high"][index]
        low = quote["low"][index]
        close = quote["close"][index]
        adjusted_close = adjusted[index]
        if not all(value and value > 0 for value in [open_price, high, low, close, adjusted_close]):
            continue

        volume = quote.get("volume", [None] * len(result["timestamp"]))[index]
        bar = {
            "date": iso_date(timestamp),
            "open": round(float(open_price), 6),
            "high": round(float(high), 6),
            "low": round(float(low), 6),
            "close": round(float(close), 6),
            "adjustedClose": round(float(adjusted_close), 6),
        }
        if volume is not None:
            bar["volume"] = float(volume)
        bars.append(bar)

    return bars


def bar_bucket_key(bar: dict[str, Any], months_per_bar: int) -> int:
    date = datetime.fromisoformat(bar["date"].replace("Z", "+00:00"))
    bucket = (date.month - 1) // months_per_bar
    return date.year * (12 // months_per_bar) + bucket


def aggregate_bars(bars: list[dict[str, Any]], months_per_bar: int) -> list[dict[str, Any]]:
    buckets: dict[int, list[dict[str, Any]]] = {}
    for bar in bars:
        buckets.setdefault(bar_bucket_key(bar, months_per_bar), []).append(bar)

    aggregated: list[dict[str, Any]] = []
    for key in sorted(buckets):
        bucket_bars = sorted(buckets[key], key=lambda item: item["date"])
        first = bucket_bars[0]
        last = bucket_bars[-1]
        volumes = [bar["volume"] for bar in bucket_bars if "volume" in bar]
        bar = {
            "date": last["date"],
            "open": first["open"],
            "high": max(item["high"] for item in bucket_bars),
            "low": min(item["low"] for item in bucket_bars),
            "close": last["close"],
            "adjustedClose": last["adjustedClose"],
        }
        if volumes:
            bar["volume"] = sum(volumes)
        aggregated.append(bar)

    return aggregated


def fetch_history(asset: tuple[str, str, str, str]) -> AssetHistory:
    asset_id, symbol, display_name, category_label = asset
    start = int(datetime(2010, 1, 1, tzinfo=timezone.utc).timestamp())
    now = datetime.now(tz=timezone.utc)
    recent_start = int((now - timedelta(days=366)).timestamp())
    end = int(now.timestamp()) + 86400

    monthly_bars = fetch_bars(symbol, "1mo", start, end)
    recent_bars = fetch_bars(symbol, "1wk", recent_start, end)
    six_month_bars = aggregate_bars(monthly_bars, months_per_bar=6)
    yearly_bars = aggregate_bars(monthly_bars, months_per_bar=12)

    return AssetHistory(
        asset=asset_id,
        symbol=symbol,
        display_name=display_name,
        category_label=category_label,
        monthly_bars=monthly_bars,
        recent_bars=recent_bars,
        six_month_bars=six_month_bars,
        yearly_bars=yearly_bars,
    )


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    output_path = repo_root / "WhatIfInvest" / "Resources" / "Historical" / "bundled_historical_data.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    histories = [fetch_history(asset) for asset in ASSETS]
    payload = {
        "generatedAt": datetime.now(tz=timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "provider": "Yahoo Finance chart endpoint (monthly OHLC + recent OHLC + derived semiannual/annual OHLC)",
        "interval": "1mo+1wk+6mo+1y",
        "histories": [
            {
                "asset": history.asset,
                "symbol": history.symbol,
                "displayName": history.display_name,
                "categoryLabel": history.category_label,
                "monthlyPoints": [
                    {
                        "date": bar["date"],
                        "adjustedClose": bar["adjustedClose"],
                    }
                    for bar in history.monthly_bars
                ],
                "recentPoints": [
                    {
                        "date": bar["date"],
                        "adjustedClose": bar["adjustedClose"],
                    }
                    for bar in history.recent_bars
                ],
                "monthlyBars": history.monthly_bars,
                "recentBars": history.recent_bars,
                "sixMonthBars": history.six_month_bars,
                "yearlyBars": history.yearly_bars,
            }
            for history in histories
        ],
    }
    output_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
