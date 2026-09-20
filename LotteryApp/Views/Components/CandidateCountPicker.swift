//
//  CandidateCountPicker.swift
//  LotteryApp
//
//  全域「候選號碼數量 N」設定（6～10），所有選號功能共用同一組值。
//

import SwiftUI

struct CandidateCountPicker: View {
    @AppStorage("candidateCount") private var candidateCount: Int = 6

    private let options = Array(6...10)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("候選號碼數量")
                .font(.caption)
                .foregroundStyle(.gray)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { value in
                    Button {
                        candidateCount = value
                    } label: {
                        Text("\(value)")
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(candidateCount == value ? Color.yellow : Color(white: 0.14))
                            )
                            .foregroundStyle(candidateCount == value ? Color.black : Color.white)
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
        .background(Color.black)
}
