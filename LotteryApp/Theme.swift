//
//  Theme.swift
//  LotteryApp
//
//  紅金發財風的共用配色。
//

import SwiftUI

enum Theme {
    /// 背景：深紅漸層
    static let background = LinearGradient(
        colors: [Color(red: 0.70, green: 0.07, blue: 0.07), Color(red: 0.40, green: 0.02, blue: 0.03)],
        startPoint: .top, endPoint: .bottom
    )
    /// 卡片底色（比背景再深一點的紅）
    static let card = Color(red: 0.36, green: 0.03, blue: 0.04).opacity(0.85)
    /// 金色
    static let gold = Color(red: 1.00, green: 0.80, blue: 0.26)
    static let goldDeep = Color(red: 0.86, green: 0.58, blue: 0.10)
    static let goldGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.88, blue: 0.45), Color(red: 0.93, green: 0.65, blue: 0.15)],
        startPoint: .top, endPoint: .bottom
    )
    /// 主要文字（米白）與次要文字
    static let text = Color(red: 1.0, green: 0.95, blue: 0.86)
    static let subtext = Color(red: 1.0, green: 0.95, blue: 0.86).opacity(0.65)
    /// 深紅文字（放在金色上）
    static let redInk = Color(red: 0.55, green: 0.04, blue: 0.04)
}

/// 紅底金邊卡片
struct FortuneCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.gold.opacity(0.45), lineWidth: 1.2))
    }
}

extension View {
    func fortuneCard() -> some View { modifier(FortuneCard()) }
}

/// 頂部的魔酷熊吉祥物＋對話泡泡
struct MokuMascot: View {
    let imageName: String
    let message: String
    var bounce: Int = 0
    @State private var scale: CGFloat = 1

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 120)
                .scaleEffect(scale, anchor: .bottom)
                .onChange(of: bounce) { _, _ in
                    // 每次產生號碼，魔酷熊開心地跳一下
                    scale = 1.18
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.4)) { scale = 1 }
                }
            VStack(alignment: .leading, spacing: 6) {
                Text("超樂透幸運選號")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.goldGradient)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 2)
                Text(message)
                    .font(.subheadline.bold())
                    .foregroundStyle(Theme.redInk)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Theme.text))
                    .overlay(alignment: .leading) {
                        // 對話泡泡的小尖角
                        Triangle()
                            .fill(Theme.text)
                            .frame(width: 10, height: 12)
                            .offset(x: -8)
                    }
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}
