//
//  DrawResultRepository.swift
//  LotteryApp
//

import Foundation

/// 歷史開獎資料來源協定，讓 UI 不需關心資料實際從哪裡來。
protocol DrawResultRepository {
    func fetchAll() -> [DrawResult]
}

/// 以 App 內建的歷史開獎資料快照為基礎（見 Resources/lotto649.json），
/// 若先前已成功連網更新過，優先使用快取的最新資料。
/// 即時更新由 `RemoteDrawResultSync.refresh()` 另外處理。
struct BundledDrawResultRepository: DrawResultRepository {
    func fetchAll() -> [DrawResult] {
        let results = RemoteDrawResultSync.loadCachedIfAvailable() ?? RemoteDrawResultSync.loadBundled() ?? []
        return results.sorted { $0.date > $1.date }
    }
}
