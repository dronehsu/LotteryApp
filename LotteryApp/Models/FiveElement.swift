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

    /// 十二地支對應的五行屬性（子水、丑土、寅木、卯木、辰土、巳火、午火、未土、申金、酉金、戌土、亥水），
    /// 命理學傳統分類；生肖與時辰皆以地支為基礎，共用這組對照。
    static func fromEarthlyBranch(index: Int) -> FiveElement {
        switch index {
        case 0, 11: return .water
        case 2, 3: return .wood
        case 5, 6: return .fire
        case 8, 9: return .metal
        default: return .earth
        }
    }

    /// 河圖五行數理對應（天一生水地六成之、地二生火天七成之、天三生木地八成之、
    /// 地四生金天九成之、天五生土地十成之），命理學常見的五行對應數字系統，
    /// 在 1～49 範圍內依序展開成完整號碼參考表。
    var referenceNumbers: [Int] {
        let base: Int
        switch self {
        case .water: base = 1
        case .fire: base = 2
        case .wood: base = 3
        case .metal: base = 4
        case .earth: base = 5
        }
        return Array(stride(from: base, through: 49, by: 5))
    }
}
