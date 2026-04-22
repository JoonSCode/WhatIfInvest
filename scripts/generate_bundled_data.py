#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path


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
    monthly_points: list[dict[str, object]]


def fetch_history(asset: tuple[str, str, str, str]) -> AssetHistory:
    asset_id, symbol, display_name, category_label = asset
    start = int(datetime(2010, 1, 1, tzinfo=timezone.utc).timestamp())
    end = int(datetime.now(tz=timezone.utc).timestamp()) + 86400
    url = (
        f"https://query1.finance.yahoo.com/v8/finance/chart/{symbol}"
        f"?interval=1mo&period1={start}&period2={end}&events=div%2Csplits&includeAdjustedClose=true"
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
    timestamps = result["timestamp"]
    adjusted = result["indicators"]["adjclose"][0]["adjclose"]

    monthly_points = []
    for timestamp, price in zip(timestamps, adjusted):
        if price is None:
            continue
        monthly_points.append(
            {
                "date": datetime.fromtimestamp(timestamp, tz=timezone.utc)
                .replace(microsecond=0)
                .isoformat()
                .replace("+00:00", "Z"),
                "adjustedClose": round(float(price), 6),
            }
        )

    return AssetHistory(
        asset=asset_id,
        symbol=symbol,
        display_name=display_name,
        category_label=category_label,
        monthly_points=monthly_points,
    )


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    output_path = repo_root / "TimeMachineInvest" / "Resources" / "Historical" / "bundled_historical_data.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)

    histories = [fetch_history(asset) for asset in ASSETS]
    payload = {
        "generatedAt": datetime.now(tz=timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "provider": "Yahoo Finance chart endpoint (monthly adjusted close)",
        "interval": "1mo",
        "histories": [
            {
                "asset": history.asset,
                "symbol": history.symbol,
                "displayName": history.display_name,
                "categoryLabel": history.category_label,
                "monthlyPoints": history.monthly_points,
            }
            for history in histories
        ],
    }
    output_path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
