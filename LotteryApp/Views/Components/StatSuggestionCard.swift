//
//  StatSuggestionCard.swift
//  LotteryApp
//

import SwiftUI

/// 一組選號建議卡片：標題、說明，以及一排號碼球與各自的輔助說明文字。
struct StatSuggestionCard: View {
    let title: String
    let subtitle: String
    let numbers: [Int]
    var captions: [String] = []
    /// 威力彩第二區號碼（其他彩種為 nil）
    var secondZone: Int? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.gold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
            // 號碼較多時自動換行，6～10 顆都放得下
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: min(max(numbers.count, 1), 6)),
                      alignment: .leading, spacing: 8) {
                ForEach(Array(numbers.enumerated()), id: \.offset) { index, number in
                    VStack(spacing: 4) {
                        LotteryBallView(number: number)
                        if index < captions.count, !captions[index].isEmpty {
                            Text(captions[index])
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.subtext)
                        }
                    }
                }
            }
            if let secondZone {
                HStack(spacing: 8) {
                    Text("第二區")
                        .font(.subheadline.bold())
                        .foregroundStyle(Theme.gold)
                    LotteryBallView(number: secondZone, isSpecial: true)
                }
            }
        }
        .fortuneCard()
    }
}

#Preview {
    StatSuggestionCard(
        title: "前 6 大常開獎號碼",
        subtitle: "依全部歷史資料統計出現頻率最高",
        numbers: [3, 11, 19, 24, 31, 42],
        captions: ["3 次", "2 次", "2 次", "2 次", "1 次", "1 次"]
    )
    .padding()
    .background(Theme.background)
}
