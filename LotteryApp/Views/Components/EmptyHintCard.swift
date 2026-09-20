//
//  EmptyHintCard.swift
//  LotteryApp
//
//  尚未輸入必要資訊時，取代 StatSuggestionCard 顯示的提示卡片。
//

import SwiftUI

struct EmptyHintCard: View {
    let title: String
    let hint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(.yellow)
            Text(hint)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.10)))
    }
}

#Preview {
    EmptyHintCard(title: "生日 + 星座幸運號", hint: "請先在上方輸入生日")
        .padding()
        .background(Color.black)
}
