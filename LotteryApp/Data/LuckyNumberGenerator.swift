//
//  LuckyNumberGenerator.swift
//  LotteryApp
//
//  依規則換算出的「參考號碼」優先採用，不足指定數量時，
//  以種子值決定式地補滿，確保同樣輸入永遠得到同樣結果。
//

import Foundation

enum LuckyNumberGenerator {
    static func generate(seed: Int, preferredNumbers: [Int], count: Int) -> [Int] {
        var result = Set<Int>()

        for n in preferredNumbers where result.count < count {
            result.insert(clamp(n))
        }

        var state = UInt64(bitPattern: Int64(seed))
        func next() -> Int {
            state = state &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
            return Int((state >> 33) % 49) + 1
        }

        var attempts = 0
        while result.count < count && attempts < 1000 {
            result.insert(next())
            attempts += 1
        }

        return result.sorted()
    }

    private static func clamp(_ n: Int) -> Int {
        ((n - 1) % 49 + 49) % 49 + 1
    }
}
