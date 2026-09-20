//
//  DrawResultRepository.swift
//  LotteryApp
//

import Foundation

/// 歷史開獎資料來源協定，讓 UI 不需關心資料實際從哪裡來。
protocol DrawResultRepository {
    func fetchAll() -> [DrawResult]
}

/// 暫時以假資料實作，待資料來源（API / 爬蟲 / CSV）確定後替換。
struct MockDrawResultRepository: DrawResultRepository {
    func fetchAll() -> [DrawResult] {
        SampleDrawResults.all.sorted { $0.date > $1.date }
    }
}
