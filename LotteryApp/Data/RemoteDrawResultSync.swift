//
//  RemoteDrawResultSync.swift
//  LotteryApp
//
//  歷史開獎資料的解碼與連線更新邏輯。
//  資料來源：docs/<彩種>.json，由 scripts/update_lottery_data.py
//  定期抓取台灣彩券官網的公開查詢端點產生，經 GitHub Actions 排程更新。
//

import Foundation

enum RemoteDrawResultSync {
    /// GitHub repo 上由排程自動更新的 JSON（raw content）
    static func remoteURL(for game: LotteryGame) -> URL {
        URL(string: "https://raw.githubusercontent.com/dronehsu/LotteryApp/main/docs/\(game.dataFileName).json")!
    }

    private struct DTO: Decodable {
        let period: String
        let date: String
        let numbers: [Int]
        let special: Int?
    }

    /// 嘗試連網抓取最新資料；成功時會快取到本機，失敗回傳 nil（呼叫端應保留原本資料）。
    static func refresh(game: LotteryGame) async -> [DrawResult]? {
        guard let (data, response) = try? await URLSession.shared.data(from: remoteURL(for: game)),
              let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200,
              let results = try? decode(data),
              !results.isEmpty
        else {
            return nil
        }
        try? data.write(to: cacheURL(for: game), options: .atomic)
        return results
    }

    static func loadCachedIfAvailable(game: LotteryGame) -> [DrawResult]? {
        guard let data = try? Data(contentsOf: cacheURL(for: game)),
              let results = try? decode(data), !results.isEmpty
        else { return nil }
        return results
    }

    static func loadBundled(game: LotteryGame) -> [DrawResult]? {
        guard let url = Bundle.main.url(forResource: game.dataFileName, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return try? decode(data)
    }

    private static func cacheURL(for game: LotteryGame) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("\(game.dataFileName)_cache.json")
    }

    private static func decode(_ data: Data) throws -> [DrawResult] {
        let items = try JSONDecoder().decode([DTO].self, from: data)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        formatter.calendar = Calendar(identifier: .gregorian)
        return items.compactMap { dto in
            guard let date = formatter.date(from: dto.date) else { return nil }
            return DrawResult(id: dto.period, date: date, numbers: dto.numbers, specialNumber: dto.special)
        }
    }
}
