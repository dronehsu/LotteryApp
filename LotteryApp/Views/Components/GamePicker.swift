//
//  GamePicker.swift
//  LotteryApp
//
//  最上方的彩種切換：大樂透／威力彩／今彩539
//

import SwiftUI

struct GamePicker: View {
    @Binding var selection: LotteryGame

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                ForEach(LotteryGame.allCases) { game in
                    let selected = selection == game
                    Button {
                        selection = game
                    } label: {
                        Text(game.name)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selected ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(Theme.card))
                            )
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(Theme.gold.opacity(selected ? 0 : 0.45), lineWidth: 1.2))
                            .foregroundStyle(selected ? Theme.redInk : Theme.text)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("\(selection.ruleText)・\(selection.drawDaysText)")
                .font(.caption)
                .foregroundStyle(Theme.subtext)
        }
    }
}
