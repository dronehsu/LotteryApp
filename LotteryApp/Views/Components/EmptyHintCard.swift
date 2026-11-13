//
//  EmptyHintCard.swift
//  LotteryApp
//
//  尚未產生號碼時，取代 StatSuggestionCard 顯示的提示卡片。
//

import SwiftUI

struct EmptyHintCard: View {
    let title: String
    let hint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.gold)
            Text(hint)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
            // 六顆空的金框球，暗示號碼會出現在這裡
            HStack(spacing: 6) {
                ForEach(0..<6, id: \.self) { _ in
                    Circle()
                        .stroke(Theme.gold.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                        .frame(width: 38, height: 38)
                }
            }
        }
        .fortuneCard()
    }
}

#Preview {
    EmptyHintCard(title: "幸運號碼", hint: "勾選下方想用的規則，按「產生號碼」")
        .padding()
        .background(Theme.background)
}
