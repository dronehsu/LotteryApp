//
//  ChineseHour.swift
//  LotteryApp
//

import Foundation

/// 傳統十二時辰。
enum ChineseHour: Int, CaseIterable {
    case zi = 0, chou, yin, mao, chen, si, wu, wei, shen, you, xu, hai

    var displayName: String {
        switch self {
        case .zi: return "子時（23:00–01:00）"
        case .chou: return "丑時（01:00–03:00）"
        case .yin: return "寅時（03:00–05:00）"
        case .mao: return "卯時（05:00–07:00）"
        case .chen: return "辰時（07:00–09:00）"
        case .si: return "巳時（09:00–11:00）"
        case .wu: return "午時（11:00–13:00）"
        case .wei: return "未時（13:00–15:00）"
        case .shen: return "申時（15:00–17:00）"
        case .you: return "酉時（17:00–19:00）"
        case .xu: return "戌時（19:00–21:00）"
        case .hai: return "亥時（21:00–23:00）"
        }
    }

    /// 依當下時間換算所屬時辰。
    static func current(at date: Date = Date(), calendar: Calendar = .current) -> ChineseHour {
        let hour = calendar.component(.hour, from: date)
        let index = ((hour + 1) / 2) % 12
        return ChineseHour(rawValue: index) ?? .zi
    }

    /// 時辰對應號碼參考表：吉時規則來源待確認，暫以時辰序位對照。
    var referenceNumbers: [Int] {
        [rawValue * 4 + 1, rawValue * 4 + 2, rawValue * 4 + 3]
    }
}
