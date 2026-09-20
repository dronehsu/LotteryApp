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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.yellow)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.gray)
            HStack(spacing: 10) {
                ForEach(Array(numbers.enumerated()), id: \.offset) { index, number in
                    VStack(spacing: 4) {
                        LotteryBallView(number: number)
                        if index < captions.count, !captions[index].isEmpty {
                            Text(captions[index])
                                .font(.system(size: 10))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.10)))
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
    .background(Color.black)
}
