#!/usr/bin/env python3
"""抓取台灣彩券大樂透、威力彩、今彩539 歷史開獎資料，寫成 App 需要的 JSON 格式。

資料來源：台灣彩券官網本身在用的公開 API 端點
https://api.taiwanlottery.com/TLCAPIWeB/Lottery/<端點>
  大樂透  Lotto649Result
  威力彩  SuperLotto638Result
  今彩539 Daily539Result
這些端點沒有官方文件、非正式對外開放的 API，本腳本僅做唯讀查詢，
使用風險（例如官網改版導致失效、存取政策疑慮）請自行評估承擔。

輸出（每個彩種一個檔）：docs/lotto649.json、docs/superlotto638.json、docs/daily539.json
每筆格式：{"period": "...", "date": "YYYY-MM-DD", "numbers": [...], "special": 數字或 null}
  大樂透 special = 特別號；威力彩 special = 第二區；今彩539 沒有 special（null）

用法：
    python3 scripts/update_lottery_data.py                 # 三個彩種都只補最近兩個月（排程用）
    python3 scripts/update_lottery_data.py --backfill      # 從頭回補所有歷史資料（只需執行一次）
    python3 scripts/update_lottery_data.py --game daily539 # 只更新某一個彩種
"""
import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

API_BASE = "https://api.taiwanlottery.com/TLCAPIWeB/Lottery/"
DOCS_DIR = Path(__file__).resolve().parent.parent / "docs"

# 彩種代號: (API 端點, 回應裡的清單欄位, 一般號碼數量, 號碼範圍, 是否有特別號/第二區, 第二區範圍)
GAMES = {
    "lotto649": ("Lotto649Result", "lotto649Res", 6, (1, 49), True, (1, 49)),
    "superlotto638": ("SuperLotto638Result", "superLotto638Res", 6, (1, 38), True, (1, 8)),
    "daily539": ("Daily539Result", "daily539Res", 5, (1, 39), False, None),
}

# 回補起始月份；官方 API 只保留部分年份，抓不到的月份會自動略過。
BACKFILL_START_YEAR = 2015
BACKFILL_START_MONTH = 1


def fetch_month(game: str, year: int, month: int) -> list[dict]:
    endpoint, list_key, count, (lo, hi), has_special, special_range = GAMES[game]
    url = f"{API_BASE}{endpoint}?period&month={year:04d}-{month:02d}&pageSize=40"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            payload = json.load(resp)
    except (urllib.error.URLError, urllib.error.HTTPError, TimeoutError, ValueError) as exc:
        print(f"  [警告] {game} {year}-{month:02d} 讀取失敗：{exc}", file=sys.stderr)
        return []

    if payload.get("rtCode") != 0 or not payload.get("content"):
        return []

    content = payload["content"]
    entries = content.get(list_key)
    if entries is None:
        # 欄位名稱若有變動，就找回應裡第一個清單
        entries = next((v for v in content.values() if isinstance(v, list)), [])

    results = []
    for entry in entries or []:
        numbers = entry.get("drawNumberSize") or []
        need = count + (1 if has_special else 0)
        if len(numbers) < need:
            continue
        main = sorted(numbers[:count])
        special = numbers[count] if has_special else None
        # 檢查號碼範圍，避免寫入異常資料
        if not all(lo <= n <= hi for n in main) or len(set(main)) != count:
            print(f"  [略過] {game} 第 {entry.get('period')} 期號碼異常：{numbers}", file=sys.stderr)
            continue
        if has_special and not (special_range[0] <= special <= special_range[1]):
            print(f"  [略過] {game} 第 {entry.get('period')} 期特別號異常：{numbers}", file=sys.stderr)
            continue
        results.append({
            "period": str(entry["period"]),
            "date": entry["lotteryDate"][:10],
            "numbers": main,
            "special": special,
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


def output_path(game: str) -> Path:
    return DOCS_DIR / f"{game}.json"


def load_existing(game: str) -> dict[str, dict]:
    path = output_path(game)
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as f:
        data = json.load(f)
    return {item["period"]: item for item in data}


def save(game: str, by_period: dict[str, dict]) -> None:
    ordered = sorted(by_period.values(), key=lambda item: (item["date"], item["period"]), reverse=True)
    path = output_path(game)
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        json.dump(ordered, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"寫入 {len(ordered)} 筆資料到 {path}")


def update_game(game: str, backfill: bool) -> None:
    today = date.today()
    by_period = load_existing(game)
    if backfill:
        months = list(month_range(BACKFILL_START_YEAR, BACKFILL_START_MONTH, today.year, today.month))
    else:
        prev_month = today.month - 1 or 12
        prev_year = today.year if today.month > 1 else today.year - 1
        months = [(prev_year, prev_month), (today.year, today.month)]

    for year, month in months:
        print(f"抓取 {game} {year}-{month:02d} ...")
        for item in fetch_month(game, year, month):
            by_period[item["period"]] = item
        time.sleep(0.5)

    save(game, by_period)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--backfill", action="store_true", help="從頭回補所有歷史資料（較慢，通常只需執行一次）")
    parser.add_argument("--game", choices=["all", *GAMES.keys()], default="all", help="只更新某一個彩種")
    args = parser.parse_args()

    games = list(GAMES.keys()) if args.game == "all" else [args.game]
    for game in games:
        update_game(game, args.backfill)


if __name__ == "__main__":
    main()
