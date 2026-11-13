//
//  LotteryGame.swift
//  LotteryApp
//
//  三種彩券的規則：大樂透、威力彩、今彩539。
//

import Foundation

enum LotteryGame: String, CaseIterable, Identifiable, Codable {
    case lotto649
    case superLotto638
    case daily539

    var id: String { rawValue }

    var name: String {
        switch self {
        case .lotto649: return "大樂透"
        case .superLotto638: return "威力彩"
        case .daily539: return "今彩539"
        }
    }

    /// 一般號碼（威力彩為第一區）的範圍
    var numberRange: ClosedRange<Int> {
        switch self {
        case .lotto649: return 1...49
        case .superLotto638: return 1...38
        case .daily539: return 1...39
        }
    }

    /// 一注要選幾個號碼
    var pickCount: Int {
        switch self {
        case .lotto649, .superLotto638: return 6
        case .daily539: return 5
        }
    }

    /// 威力彩第二區（1～8），其他彩種沒有
    var secondZoneRange: ClosedRange<Int>? {
        self == .superLotto638 ? 1...8 : nil
    }

    /// 大樂透開獎時另外開出的特別號
    var hasSpecialNumber: Bool { self == .lotto649 }

    /// 開獎資料檔名（App 內建與 GitHub 上的 JSON 同名）
    var dataFileName: String {
        switch self {
        case .lotto649: return "lotto649"
        case .superLotto638: return "superlotto638"
        case .daily539: return "daily539"
        }
    }

    var drawDaysText: String {
        switch self {
        case .lotto649: return "每週二、五開獎"
        case .superLotto638: return "每週一、四開獎"
        case .daily539: return "每週一至六開獎"
        }
    }

    /// 號碼範圍說明，例如「1～49 選 6 個」
    var ruleText: String {
        var text = "\(numberRange.lowerBound)～\(numberRange.upperBound) 選 \(pickCount) 個"
        if let second = secondZoneRange {
            text += "，第二區 \(second.lowerBound)～\(second.upperBound) 選 1 個"
        }
        return text
    }
}
