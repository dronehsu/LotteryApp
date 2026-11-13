//
//  LotteryBallView.swift
//  LotteryApp
//

import SwiftUI

/// 單顆號碼球：金色球、紅字；特別號為紅球金字。
struct LotteryBallView: View {
    let number: Int
    var isSpecial: Bool = false
    var size: CGFloat = 38

    var body: some View {
        Text(String(format: "%02d", number))
            .font(.system(size: size * 0.44, weight: .heavy, design: .rounded))
            .foregroundStyle(isSpecial ? Theme.gold : Theme.redInk)
            .frame(width: size, height: size)
            .background(
                Circle().fill(
                    RadialGradient(
                        colors: isSpecial
                            ? [Color(red: 0.95, green: 0.30, blue: 0.25), Color(red: 0.60, green: 0.05, blue: 0.05)]
                            : [Color(red: 1.0, green: 0.95, blue: 0.70), Theme.gold, Theme.goldDeep],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 1, endRadius: size * 0.7
                    )
                )
            )
            .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 2, y: 2)
    }
}

#Preview {
    HStack {
        LotteryBallView(number: 7)
        LotteryBallView(number: 42, isSpecial: true)
    }
    .padding()
    .background(Theme.background)
}
