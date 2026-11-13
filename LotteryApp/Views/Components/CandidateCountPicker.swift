//
//  CandidateCountPicker.swift
//  LotteryApp
//
//  全域「候選號碼數量 N」設定（6～10），所有選號功能共用同一組值。
//

import SwiftUI

struct CandidateCountPicker: View {
    @AppStorage("candidateCount") private var candidateCount: Int = 6
    /// 最少要選幾個（今彩539 為 5，其他為 6）
    var minimum: Int = 6

    private var options: [Int] { Array(minimum...10) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("候選號碼數量")
                .font(.caption)
                .foregroundStyle(Theme.subtext)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { value in
                    let selected = max(candidateCount, minimum) == value
                    Button {
                        candidateCount = value
                    } label: {
                        Text("\(value)")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(selected ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(Theme.card))
                            )
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.gold.opacity(selected ? 0 : 0.35), lineWidth: 1))
                            .foregroundStyle(selected ? Theme.redInk : Theme.text)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    CandidateCountPicker()
        .padding()
        .background(Theme.background)
}
