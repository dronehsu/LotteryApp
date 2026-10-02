//
//  ChineseZodiac.swift
//  LotteryApp
//

import Foundation

/// 十二生肖。
enum ChineseZodiac: Int, CaseIterable {
    case rat = 0, ox, tiger, rabbit, dragon, snake, horse, goat, monkey, rooster, dog, pig

    var displayName: String {
        switch self {
        case .rat: return "鼠"
        case .ox: return "牛"
        case .tiger: return "虎"
        case .rabbit: return "兔"
        case .dragon: return "龍"
        case .snake: return "蛇"
        case .horse: return "馬"
        case .goat: return "羊"
        case .monkey: return "猴"
        case .rooster: return "雞"
        case .dog: return "狗"
        case .pig: return "豬"
        }
    }

    /// 依西元年份換算生肖（以地支序位對照，1900 年為鼠年基準）。
    static func from(year: Int) -> ChineseZodiac {
        let index = ((year - 4) % 12 + 12) % 12
        return ChineseZodiac(rawValue: index) ?? .rat
    }

    /// 生肖對應號碼參考表：依生肖所屬地支換算五行，再對照河圖數理展開。
    var referenceNumbers: [Int] {
        FiveElement.fromEarthlyBranch(index: rawValue).referenceNumbers
    }
}
