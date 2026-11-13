//
//  DrawResult.swift
//  LotteryApp
//

import Foundation

/// 一期開獎結果。
struct DrawResult: Identifiable, Hashable {
    /// 期別字串，例如 "115000092"，同時作為唯一識別碼。
    let id: String
    var period: String { id }
    let date: Date
    /// 一般開獎號碼（大樂透、威力彩第一區 6 顆；今彩539 5 顆），已由小到大排序。
    let numbers: [Int]
    /// 大樂透：特別號；威力彩：第二區號碼；今彩539：沒有（nil）。
    let specialNumber: Int?
}
