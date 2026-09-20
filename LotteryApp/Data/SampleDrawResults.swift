//
//  SampleDrawResults.swift
//  LotteryApp
//
//  暫時性假資料，供「歷史開獎查詢」畫面開發與預覽使用。
//  待 PRD 待確認事項「歷史開獎資料的取得方式」拍板後，
//  改由真實 API / 爬蟲 / CSV 匯入資料取代。
//

import Foundation

enum SampleDrawResults {
    static let all: [DrawResult] = {
        let calendar = Calendar(identifier: .gregorian)

        let raw: [(year: Int, month: Int, day: Int, period: String, numbers: [Int], special: Int)] = [
            (2026, 9, 15, "115074", [3, 11, 19, 24, 31, 42], 8),
            (2026, 9, 11, "115073", [2, 9, 17, 28, 35, 44], 21),
            (2026, 9, 8,  "115072", [5, 13, 22, 27, 38, 46], 14),
            (2026, 9, 4,  "115071", [1, 7, 16, 25, 33, 40], 29),
            (2026, 9, 1,  "115070", [4, 12, 18, 23, 36, 49], 6),
            (2026, 8, 28, "115069", [8, 14, 21, 30, 34, 45], 17),
            (2026, 8, 25, "115068", [2, 6, 19, 26, 39, 47], 33),
            (2026, 8, 21, "115067", [9, 15, 20, 28, 37, 43], 11),
            (2026, 8, 18, "115066", [3, 10, 24, 29, 32, 48], 20),
            (2026, 8, 14, "115065", [6, 13, 17, 22, 35, 41], 5),
            (2026, 8, 11, "115064", [1, 8, 19, 27, 38, 44], 30),
            (2026, 8, 7,  "115063", [4, 11, 16, 25, 31, 46], 12),
            (2026, 8, 4,  "115062", [7, 14, 20, 23, 36, 42], 27),
            (2026, 7, 31, "115061", [2, 9, 18, 29, 33, 49], 15),
            (2026, 7, 28, "115060", [5, 12, 21, 26, 34, 40], 24),
        ]

        return raw.map { entry in
            let components = DateComponents(year: entry.year, month: entry.month, day: entry.day)
            let date = calendar.date(from: components) ?? Date()
            return DrawResult(
                id: entry.period,
                date: date,
                numbers: entry.numbers,
                specialNumber: entry.special
            )
        }
    }()
}
