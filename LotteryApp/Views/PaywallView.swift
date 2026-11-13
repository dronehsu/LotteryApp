//
//  PaywallView.swift
//  LotteryApp
//
//  今天的免費次數用完時顯示：一次購買 NT$50，永久無限選號
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(PurchaseManager.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 18) {
                Image("moku_ingot")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 170)
                    .padding(.top, 24)

                Text("今天的 \(PurchaseManager.freeDailyLimit) 次免費選號用完囉！")
                    .font(.title2.bold())
                    .foregroundStyle(Theme.gold)
                    .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 10) {
                    benefit("不限次數產生號碼，三種彩券都能用")
                    benefit("一次購買，永久有效，不是訂閱")
                    benefit("換手機時可以免費恢復購買")
                }
                .fortuneCard()

                Text("不想購買也沒關係：明天又有 \(PurchaseManager.freeDailyLimit) 次免費機會，收藏的號碼和投注站模式隨時都能用。")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
                    .multilineTextAlignment(.center)

                HStack(spacing: 12) {
                    Button {
                        Task {
                            await store.purchase()
                            if store.isUnlocked { dismiss() }
                        }
                    } label: {
                        Group {
                            if store.isPurchasing {
                                ProgressView().tint(Theme.redInk)
                            } else {
                                VStack(spacing: 2) {
                                    Text("🧧 解鎖無限選號")
                                    Text(store.product?.displayPrice ?? "")
                                        .font(.subheadline.bold())
                                }
                            }
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .foregroundStyle(Theme.redInk)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.goldGradient))
                    }
                    .buttonStyle(.plain)
                    .disabled(store.isPurchasing)
                    .layoutPriority(1)

                    Button { dismiss() } label: {
                        Text("明天再來")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .foregroundStyle(Theme.gold)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Theme.gold, lineWidth: 2)
                            )
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .frame(width: 120)
                }

                Button {
                    Task {
                        await store.restore()
                        if store.isUnlocked { dismiss() }
                    }
                } label: {
                    Text("已經買過？恢復購買")
                        .font(.footnote)
                        .underline()
                        .foregroundStyle(Theme.subtext)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
        .alert("提示", isPresented: Binding(
            get: { store.errorMessage != nil },
            set: { if !$0 { store.errorMessage = nil } }
        )) {
            Button("好") { store.errorMessage = nil }
        } message: {
            Text(store.errorMessage ?? "")
        }
    }

    private func benefit(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Theme.gold)
            Text(text)
                .foregroundStyle(Theme.text)
        }
        .font(.body)
    }
}
