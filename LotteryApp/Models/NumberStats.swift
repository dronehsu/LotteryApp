//
//  NumberStats.swift
//  LotteryApp
//

import Foundation

/// 單一號碼在指定範圍內的出現次數。
struct NumberFrequency: Identifiable, Hashable {
    let number: Int
    let count: Int
    var id: Int { number }
}

/// 單一號碼的遺漏值（距上次開出的期數）。
struct NumberGap: Identifiable, Hashable {
    let number: Int
    let gap: Int
    var id: Int { number }
}
