//
//  ZodiacSign.swift
//  LotteryApp
//

import Foundation

/// 西洋十二星座。
enum ZodiacSign: String, CaseIterable {
    case aries = "牡羊座"
    case taurus = "金牛座"
    case gemini = "雙子座"
    case cancer = "巨蟹座"
    case leo = "獅子座"
    case virgo = "處女座"
    case libra = "天秤座"
    case scorpio = "天蠍座"
    case sagittarius = "射手座"
    case capricorn = "摩羯座"
    case aquarius = "水瓶座"
    case pisces = "雙魚座"

    /// 依生日的月、日換算西洋星座。
    static func from(month: Int, day: Int) -> ZodiacSign {
        switch (month, day) {
        case (3, 21...31), (4, 1...19): return .aries
        case (4, 20...30), (5, 1...20): return .taurus
        case (5, 21...31), (6, 1...20): return .gemini
        case (6, 21...30), (7, 1...22): return .cancer
        case (7, 23...31), (8, 1...22): return .leo
        case (8, 23...31), (9, 1...22): return .virgo
        case (9, 23...30), (10, 1...22): return .libra
        case (10, 23...31), (11, 1...21): return .scorpio
        case (11, 22...30), (12, 1...21): return .sagittarius
        case (12, 22...31), (1, 1...19): return .capricorn
        case (1, 20...31), (2, 1...18): return .aquarius
        default: return .pisces
        }
    }

    /// 民間常見的星座幸運數字參考表，非官方標準，僅供選號趣味參考。
    var referenceLuckyNumbers: [Int] {
        switch self {
        case .aries: return [9, 18, 27]
        case .taurus: return [6, 15, 24]
        case .gemini: return [5, 14, 23]
        case .cancer: return [2, 11, 20]
        case .leo: return [1, 10, 19]
        case .virgo: return [5, 14, 23]
        case .libra: return [6, 15, 24]
        case .scorpio: return [4, 13, 22]
        case .sagittarius: return [3, 12, 21]
        case .capricorn: return [8, 17, 26]
        case .aquarius: return [4, 13, 22]
        case .pisces: return [7, 16, 25]
        }
    }
}
