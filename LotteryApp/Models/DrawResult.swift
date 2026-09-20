//
//  DrawResult.swift
//  LotteryApp
//

import Foundation

/// 一期大樂透開獎結果。
struct DrawResult: Identifiable, Hashable {
    /// 期別字串，例如 "115074"，同時作為唯一識別碼。
    let id: String
    var period: String { id }
    let date: Date
    /// 6 顆一般開獎號碼，已由小到大排序。
    let numbers: [Int]
    /// 特別號。
    let specialNumber: Int
}
