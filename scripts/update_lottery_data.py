#!/usr/bin/env python3
"""抓取台灣彩券大樂透（Lotto 649）歷史開獎資料，寫成 App 需要的 JSON 格式。

資料來源：台灣彩券官網本身在用的公開 API 端點
https://api.taiwanlottery.com/TLCAPIWeB/Lottery/Lotto649Result
這個端點沒有官方文件、非正式對外開放的 API，本腳本僅做唯讀查詢，
使用風險（例如官網改版導致失效、存取政策疑慮）請自行評估承擔。

用法：
    python3 scripts/update_lottery_data.py            # 只補最近兩個月（排程用）
    python3 scripts/update_lottery_data.py --backfill  # 從頭回補所有歷史資料（只需執行一次）
"""
import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

BASE_URL = "https://api.taiwanlottery.com/TLCAPIWeB/Lottery/Lotto649Result"
OUTPUT_PATH = Path(__file__).resolve().parent.parent / "docs" / "lotto649.json"

# 回補起始月份：目前不確定大樂透最早的歷史月份，保守從這裡開始往回抓；
# 抓不到資料的月份會被自動略過，想抓更久以前的資料把這兩個值往前調整即可。
BACKFILL_START_YEAR = 2015
BACKFILL_START_MONTH = 1


def fetch_month(year: int, month: int) -> list[dict]:
    url = f"{BASE_URL}?period&month={year:04d}-{month:02d}&pageSize=31"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            payload = json.load(resp)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError) as exc:
        print(f"  [警告] {year}-{month:02d} 讀取失敗：{exc}", file=sys.stderr)
        return []

    if payload.get("rtCode") != 0 or not payload.get("content"):
        return []

    entries = payload["content"].get("lotto649Res") or []
    results = []
    for entry in entries:
        numbers = entry.get("drawNumberSize") or []
        if len(numbers) < 7:
            continue
        results.append({
            "period": str(entry["period"]),
            "date": entry["lotteryDate"][:10],
            "numbers": sorted(numbers[:6]),
            "special": numbers[6],
        })
    return results


def month_range(start_year: int, start_month: int, end_year: int, end_month: int):
    y, m = start_year, start_month
    while (y, m) <= (end_year, end_month):
        yield y, m
        m += 1
        if m > 12:
            m = 1
            y += 1


def load_existing() -> dict[str, dict]:
    if not OUTPUT_PATH.exists():
        return {}
    with OUTPUT_PATH.open(encoding="utf-8") as f:
        data = json.load(f)
    return {item["period"]: item for item in data}


def save(by_period: dict[str, dict]) -> None:
    ordered = sorted(by_period.values(), key=lambda item: item["date"], reverse=True)
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with OUTPUT_PATH.open("w", encoding="utf-8") as f:
        json.dump(ordered, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"寫入 {len(ordered)} 筆資料到 {OUTPUT_PATH}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--backfill",
        action="store_true",
        help="從頭回補所有歷史資料（較慢，通常只需執行一次）",
    )
    args = parser.parse_args()

    today = date.today()
    by_period = load_existing()

    if args.backfill:
        months = list(month_range(BACKFILL_START_YEAR, BACKFILL_START_MONTH, today.year, today.month))
    else:
        prev_month = today.month - 1 or 12
        prev_year = today.year if today.month > 1 else today.year - 1
        months = [(prev_year, prev_month), (today.year, today.month)]

    for year, month in months:
        print(f"抓取 {year}-{month:02d} ...")
        for item in fetch_month(year, month):
            by_period[item["period"]] = item
        time.sleep(0.5)

    save(by_period)


if __name__ == "__main__":
    main()
