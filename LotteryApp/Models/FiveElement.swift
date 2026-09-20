//
//  FiveElement.swift
//  LotteryApp
//

import Foundation

/// 五行屬性：木火土金水。
enum FiveElement: String, CaseIterable {
    case wood = "木"
    case fire = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"

    /// 依西元年份換算天干，再對照五行（甲乙木、丙丁火、戊己土、庚辛金、壬癸水）。
    static func from(year: Int) -> FiveElement {
        let stemIndex = ((year - 4) % 10 + 10) % 10
        switch stemIndex {
        case 0, 1: return .wood
        case 2, 3: return .fire
        case 4, 5: return .earth
        case 6, 7: return .metal
        default: return .water
        }
    }

    /// 五行對應號碼參考表：規則來源待確認，暫以五行區間對照。
    var referenceNumbers: [Int] {
        switch self {
        case .wood: return [3, 4, 30, 31]
        case .fire: return [7, 8, 27, 28]
        case .earth: return [5, 6, 20, 29]
        case .metal: return [9, 10, 24, 25]
        case .water: return [1, 2, 22, 23]
        }
    }
}
