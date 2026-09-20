//
//  LotteryBallView.swift
//  LotteryApp
//

import SwiftUI

/// 單顆開獎號碼球，特別號以紅色標示。
struct LotteryBallView: View {
    let number: Int
    var isSpecial: Bool = false

    private var fillColor: Color {
        isSpecial ? Color(red: 0.90, green: 0.24, blue: 0.24) : Color(white: 0.16)
    }

    private var textColor: Color {
        isSpecial ? .white : .yellow
    }

    var body: some View {
        Text(String(format: "%02d", number))
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(textColor)
            .frame(width: 32, height: 32)
            .background(Circle().fill(fillColor))
            .overlay(Circle().stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

#Preview {
    HStack {
        LotteryBallView(number: 7)
        LotteryBallView(number: 42, isSpecial: true)
    }
    .padding()
    .background(Color.black)
}
