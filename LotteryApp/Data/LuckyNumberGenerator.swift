//
//  LuckyNumberGenerator.swift
//  LotteryApp
//
//  依規則換算出的「參考號碼」優先採用，不足指定數量時，
//  以種子值決定式地補滿，確保同樣輸入永遠得到同樣結果。
//

import Foundation

enum LuckyNumberGenerator {
    static func generate(seed: Int, preferredNumbers: [Int], count: Int,
                         range: ClosedRange<Int> = 1...49) -> [Int] {
        let size = range.count
        var result = Set<Int>()

        // 先放範圍內的參考號碼，再放超出範圍、換算回範圍內的號碼
        for n in preferredNumbers where range.contains(n) && result.count < count {
            result.insert(n)
        }
        for n in preferredNumbers where !range.contains(n) && result.count < count {
            result.insert(wrap(n, range: range))
        }

        var state = UInt64(bitPattern: Int64(seed))
        func next() -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int((state >> 33) % UInt64(size)) + range.lowerBound
        }

        var attempts = 0
        while result.count < min(count, size) && attempts < 1000 {
            result.insert(next())
            attempts += 1
        }

        return result.sorted()
    }

    /// 威力彩第二區：用種子值決定式地選一個號碼
    static func secondZone(seed: Int, range: ClosedRange<Int>) -> Int {
        var state = UInt64(bitPattern: Int64(seed)) ^ 0x9E37_79B9_7F4A_7C15
        state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Int((state >> 33) % UInt64(range.count)) + range.lowerBound
    }

    private static func wrap(_ n: Int, range: ClosedRange<Int>) -> Int {
        let size = range.count
        return ((n - range.lowerBound) % size + size) % size + range.lowerBound
    }
}
