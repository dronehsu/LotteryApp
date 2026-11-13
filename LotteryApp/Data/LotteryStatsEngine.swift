//
//  LotteryStatsEngine.swift
//  LotteryApp
//
//  選號建議（仿股票技術分析邏輯）的統計運算。
//  range 依彩種不同：大樂透 1～49、威力彩第一區 1～38、今彩539 1～39。
//

import Foundation

enum LotteryStatsEngine {
    /// 統計每個號碼在給定歷史資料中的出現次數（只算一般號碼，不含特別號／第二區）。
    static func frequencies(in results: [DrawResult], range: ClosedRange<Int> = 1...49) -> [NumberFrequency] {
        var counts = [Int: Int](minimumCapacity: range.count)
        for n in range { counts[n] = 0 }
        for result in results {
            for n in result.numbers where range.contains(n) {
                counts[n, default: 0] += 1
            }
        }
        return counts.map { NumberFrequency(number: $0.key, count: $0.value) }
    }

    /// 前 N 大常開獎號碼：出現頻率最高的 N 碼。
    static func topFrequent(in results: [DrawResult], count: Int, range: ClosedRange<Int> = 1...49) -> [NumberFrequency] {
        frequencies(in: results, range: range)
            .sorted { $0.count != $1.count ? $0.count > $1.count : $0.number < $1.number }
            .prefix(count)
            .map { $0 }
    }

    /// N 個最少開獎號碼：出現頻率最低的 N 碼。
    static func leastFrequent(in results: [DrawResult], count: Int, range: ClosedRange<Int> = 1...49) -> [NumberFrequency] {
        frequencies(in: results, range: range)
            .sorted { $0.count != $1.count ? $0.count < $1.count : $0.number < $1.number }
            .prefix(count)
            .map { $0 }
    }

    /// 拖牌預測：依「前 windowSize 期」走勢，計算每個號碼的遺漏值（距上次開出的期數），
    /// 回傳遺漏值最大（最久未開出）的 N 個號碼。
    static func dueNumbers(in results: [DrawResult], windowSize: Int = 50, count: Int,
                           range: ClosedRange<Int> = 1...49) -> [NumberGap] {
        let recent = Array(results.sorted { $0.date > $1.date }.prefix(windowSize))

        var gaps = [Int: Int](minimumCapacity: range.count)
        for n in range {
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

    /// 威力彩第二區（1～8）最常開出的號碼；沒有資料時回傳 nil
    static func topSecondZone(in results: [DrawResult], range: ClosedRange<Int>) -> Int? {
        var counts = [Int: Int]()
        for r in results { if let s = r.specialNumber, range.contains(s) { counts[s, default: 0] += 1 } }
        return counts.max { $0.value != $1.value ? $0.value < $1.value : $0.key > $1.key }?.key
    }
}
