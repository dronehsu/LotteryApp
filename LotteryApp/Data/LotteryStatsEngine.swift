//
//  LotteryStatsEngine.swift
//  LotteryApp
//
//  PRD 功能 2：選號建議（仿股票技術分析邏輯）的統計運算。
//

import Foundation

enum LotteryStatsEngine {
    static let numberRange = 1...49

    /// 統計每個號碼在給定歷史資料中的出現次數（僅計算 6 顆一般號碼，不含特別號）。
    static func frequencies(in results: [DrawResult]) -> [NumberFrequency] {
        var counts = [Int: Int](minimumCapacity: numberRange.count)
        for n in numberRange { counts[n] = 0 }
        for result in results {
            for n in result.numbers {
                counts[n, default: 0] += 1
            }
        }
        return counts.map { NumberFrequency(number: $0.key, count: $0.value) }
    }

    /// 前 N 大常開獎號碼：出現頻率最高的 N 碼。
    static func topFrequent(in results: [DrawResult], count: Int) -> [NumberFrequency] {
        frequencies(in: results)
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.number < $1.number }
            .prefix(count)
            .map { $0 }
    }

    /// N 個最少開獎號碼：出現頻率最低的 N 碼。
    static func leastFrequent(in results: [DrawResult], count: Int) -> [NumberFrequency] {
        frequencies(in: results)
            .sorted { $0.count != $1.count ? $0.count < $1.count : $0.number < $1.number }
            .prefix(count)
            .map { $0 }
    }

    /// 拖牌預測：依「前 windowSize 期」走勢，計算每個號碼的遺漏值（距上次開出的期數），
    /// 回傳遺漏值最大（最久未開出）的 N 個號碼。
    static func dueNumbers(in results: [DrawResult], windowSize: Int = 50, count: Int) -> [NumberGap] {
        let recent = Array(results.sorted { $0.date > $1.date }.prefix(windowSize))

        var gaps = [Int: Int](minimumCapacity: numberRange.count)
        for n in numberRange {
            if let index = recent.firstIndex(where: { $0.numbers.contains(n) }) {
                gaps[n] = index
            } else {
                gaps[n] = recent.count
            }
        }

        return gaps.map { NumberGap(number: $0.key, gap: $0.value) }
            .sorted { $0.gap != $1.gap ? $0.gap > $1.gap : $0.number < $1.number }
            .prefix(count)
            .map { $0 }
    }
}
