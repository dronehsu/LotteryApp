//
//  PurchaseManager.swift
//  LotteryApp
//
//  App 內購買：「解鎖無限選號」（一次購買、永久有效，NT$50）
//  以及每天免費 2 次的使用次數計算。
//

import Foundation
import StoreKit
import Observation

@Observable
final class PurchaseManager {
    /// App Store Connect 裡建立的產品 ID，兩邊要一模一樣
    static let unlimitedID = "com.jungping.LotteryApp.unlimited"
    /// 每天免費可以產生號碼的次數
    static let freeDailyLimit = 2

    private(set) var isUnlocked: Bool = UserDefaults.standard.bool(forKey: "unlimitedUnlocked")
    private(set) var product: Product?
    private(set) var isPurchasing = false
    var errorMessage: String?

    /// 今天已經用了幾次（換日自動歸零）
    private(set) var usedToday: Int = 0

    private var updatesTask: Task<Void, Never>?

    init() {
        usedToday = Self.loadUsedToday()
    }

    // MARK: - 使用次數

    var remainingToday: Int { max(0, Self.freeDailyLimit - usedToday) }
    var canGenerate: Bool { isUnlocked || remainingToday > 0 }

    /// 成功產生一次號碼後呼叫
    func recordUse() {
        guard !isUnlocked else { return }
        usedToday = Self.loadUsedToday() + 1
        let d = UserDefaults.standard
        d.set(Self.todayKey(), forKey: "usageDay")
        d.set(usedToday, forKey: "usageCount")
    }

    /// App 回到前景時呼叫，跨日要歸零
    func refreshDay() {
        usedToday = Self.loadUsedToday()
    }

    private static func loadUsedToday() -> Int {
        let d = UserDefaults.standard
        guard d.string(forKey: "usageDay") == todayKey() else { return 0 }
        return d.integer(forKey: "usageCount")
    }

    private static func todayKey() -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.timeZone = TimeZone(identifier: "Asia/Taipei")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    // MARK: - StoreKit

    /// App 一啟動就呼叫：讀取產品、確認是否已購買、監聽交易
    func start() async {
        if updatesTask == nil {
            updatesTask = Task { [weak self] in
                for await result in Transaction.updates {
                    await self?.handle(result)
                }
            }
        }
        await loadProduct()
        await refreshEntitlement()
    }

    func loadProduct() async {
        do {
            product = try await Product.products(for: [Self.unlimitedID]).first
        } catch {
            print("讀取產品失敗：\(error)")
        }
    }

    func purchase() async {
        if product == nil { await loadProduct() }
        guard let product else {
            errorMessage = "暫時連不上 App Store，請稍後再試"
            return
        }
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            errorMessage = "購買沒有完成：\(error.localizedDescription)"
        }
    }

    /// 換手機或重新安裝時，用「恢復購買」找回
    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            errorMessage = "恢復購買沒有完成：\(error.localizedDescription)"
        }
        await refreshEntitlement()
        if !isUnlocked && errorMessage == nil {
            errorMessage = "這個 Apple ID 沒有找到購買紀錄"
        }
    }

    private func refreshEntitlement() async {
        var unlocked = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Self.unlimitedID, t.revocationDate == nil {
                unlocked = true
            }
        }
        setUnlocked(unlocked)
    }

    private func handle(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        if transaction.productID == Self.unlimitedID {
            setUnlocked(transaction.revocationDate == nil)
        }
        await transaction.finish()
    }

    private func setUnlocked(_ value: Bool) {
        isUnlocked = value
        UserDefaults.standard.set(value, forKey: "unlimitedUnlocked")
    }
}
