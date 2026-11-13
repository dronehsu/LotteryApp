//
//  SavedTickets.swift
//  LotteryApp
//
//  「我的號碼」：最多收藏 10 組號碼，存在手機裡，
//  並自動和最新一期開獎號碼對獎。
//

import SwiftUI
import UIKit

struct SavedTicket: Codable, Identifiable, Equatable {
    var id = UUID()
    var game: LotteryGame = .lotto649
    let numbers: [Int]
    /// 威力彩第二區
    var secondZone: Int? = nil
    /// 在投注站已經照這組號碼下注了
    var bought: Bool = false
    let rules: [String]
    let createdAt: Date

    init(game: LotteryGame, numbers: [Int], secondZone: Int?, rules: [String], createdAt: Date) {
        self.game = game
        self.numbers = numbers
        self.secondZone = secondZone
        self.rules = rules
        self.createdAt = createdAt
    }

    // 舊版存的號碼沒有 game 欄位，一律當成大樂透
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        game = try c.decodeIfPresent(LotteryGame.self, forKey: .game) ?? .lotto649
        numbers = try c.decode([Int].self, forKey: .numbers)
        secondZone = try c.decodeIfPresent(Int.self, forKey: .secondZone)
        bought = try c.decodeIfPresent(Bool.self, forKey: .bought) ?? false
        rules = try c.decodeIfPresent([String].self, forKey: .rules) ?? []
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }
}

enum SavedTicketStore {
    static let maxCount = 10
    private static let key = "savedTicketsV1"

    static func load() -> [SavedTicket] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let tickets = try? JSONDecoder().decode([SavedTicket].self, from: data)
        else { return [] }
        return tickets
    }

    static func save(_ tickets: [SavedTicket]) {
        if let data = try? JSONEncoder().encode(tickets) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

/// 「我的號碼」區塊
struct SavedTicketsSection: View {
    @Binding var tickets: [SavedTicket]
    /// 目前選的彩種：只顯示這個彩種的號碼
    let game: LotteryGame
    /// 這個彩種最新一期開獎（沒有資料時為 nil）
    let latestDraw: DrawResult?

    private var gameTickets: [SavedTicket] { tickets.filter { $0.game == game } }
    @State private var showShopMode = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("⭐ 我的\(game.name)號碼")
                    .font(.headline)
                    .foregroundStyle(Theme.gold)
                Spacer()
                Text("共 \(tickets.count) / \(SavedTicketStore.maxCount) 組")
                    .font(.caption.bold())
                    .foregroundStyle(Theme.subtext)
            }

            if let latestDraw {
                VStack(alignment: .leading, spacing: 6) {
                    Text("最新開獎：第 \(latestDraw.period) 期（\(Self.dateText(latestDraw.date))）")
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                    HStack(spacing: 4) {
                        ForEach(latestDraw.numbers, id: \.self) { n in
                            LotteryBallView(number: n, size: 28)
                        }
                        if let special = latestDraw.specialNumber {
                            Text(game == .superLotto638 ? "二區" : "特")
                                .font(.caption2.bold())
                                .foregroundStyle(Theme.subtext)
                                .padding(.leading, 2)
                            LotteryBallView(number: special, isSpecial: true, size: 28)
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.2)))
            }

            if !tickets.isEmpty {
                Button {
                    showShopMode = true
                } label: {
                    Label("到投注站：大字顯示全部號碼", systemImage: "storefront.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(Theme.redInk)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.goldGradient))
                }
                .buttonStyle(.plain)
            }

            if gameTickets.isEmpty {
                Text("產生號碼後按「收藏這組」，三種彩券合計最多可以存 10 組，之後再來對獎。")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
            } else {
                ForEach(gameTickets) { ticket in
                    ticketRow(ticket)
                }
            }
        }
        .fortuneCard()
        .fullScreenCover(isPresented: $showShopMode) {
            ShopModeView(tickets: $tickets)
        }
    }

    private func ticketRow(_ ticket: SavedTicket) -> some View {
        let hits = matchCount(ticket)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(Self.dateText(ticket.createdAt))
                    .font(.caption.bold())
                    .foregroundStyle(Theme.text)
                if ticket.bought {
                    Text("已下注")
                        .font(.caption2.bold())
                        .foregroundStyle(Theme.redInk)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Capsule().fill(Theme.gold))
                }
                if latestDraw != nil {
                    Text(hitText(hits, special: hasSpecial(ticket)))
                        .font(.caption.bold())
                        .foregroundStyle(isWinning(ticket) ? Theme.gold : Theme.subtext)
                }
                Spacer()
                Button {
                    tickets.removeAll { $0.id == ticket.id }
                    SavedTicketStore.save(tickets)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.subtext)
                        .frame(width: 36, height: 30)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("刪除這組號碼")
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 6),
                      alignment: .leading, spacing: 6) {
                ForEach(ticket.numbers, id: \.self) { n in
                    let hit = isHit(n)
                    LotteryBallView(number: n, isSpecial: game == .lotto649 && n == latestDraw?.specialNumber, size: 34)
                        .opacity(latestDraw == nil || hit ? 1 : 0.4)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: hit ? 2.5 : 0)
                        )
                }
            }
            if let second = ticket.secondZone {
                HStack(spacing: 6) {
                    Text("第二區")
                        .font(.caption.bold())
                        .foregroundStyle(Theme.subtext)
                    LotteryBallView(number: second, isSpecial: true, size: 34)
                        .opacity(latestDraw == nil || latestDraw?.specialNumber == second ? 1 : 0.4)
                        .overlay(Circle().stroke(Color.white, lineWidth: latestDraw?.specialNumber == second ? 2.5 : 0))
                }
            }
            if !ticket.rules.isEmpty {
                Text("依據：\(ticket.rules.joined(separator: "、"))")
                    .font(.caption2)
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(2)
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.18)))
    }

    // MARK: - 對獎

    private func isHit(_ n: Int) -> Bool {
        guard let latestDraw else { return false }
        if latestDraw.numbers.contains(n) { return true }
        // 大樂透的特別號也算對中；威力彩第二區另外比
        return game == .lotto649 && latestDraw.specialNumber == n
    }

    private func matchCount(_ ticket: SavedTicket) -> Int {
        guard let latestDraw else { return 0 }
        return ticket.numbers.filter { latestDraw.numbers.contains($0) }.count
    }

    private func hasSpecial(_ ticket: SavedTicket) -> Bool {
        guard let latestDraw, let special = latestDraw.specialNumber else { return false }
        switch game {
        case .lotto649: return ticket.numbers.contains(special)
        case .superLotto638: return ticket.secondZone == special
        case .daily539: return false
        }
    }

    private func hitText(_ hits: Int, special: Bool) -> String {
        if hits == 0 && !special { return "最新一期沒對中" }
        let extra = special ? (game == .superLotto638 ? "＋第二區" : "＋特別號") : ""
        return "最新一期對中 \(hits) 個" + extra
    }

    /// 達到最低獎的門檻：今彩539 對中 2 個；大樂透 3 個；威力彩 第一區 1 個＋第二區或第一區 3 個
    private func isWinning(_ ticket: SavedTicket) -> Bool {
        let hits = matchCount(ticket)
        switch game {
        case .daily539: return hits >= 2
        case .lotto649: return hits >= 3 || (hits >= 2 && hasSpecial(ticket))
        case .superLotto638: return hits >= 3 || (hits >= 1 && hasSpecial(ticket))
        }
    }

    static func dateText(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_Hant_TW")
        f.dateFormat = "yyyy/MM/dd"
        return f.string(from: date)
    }
}


/// 投注站模式：全部收藏號碼用大字顯示，依彩種分組，螢幕不會自動變暗
struct ShopModeView: View {
    @Binding var tickets: [SavedTicket]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("🏪 投注站模式")
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(Theme.goldGradient)
                        Spacer()
                        Button("完成") { dismiss() }
                            .font(.title3.bold())
                            .foregroundStyle(Theme.redInk)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(Capsule().fill(Theme.goldGradient))
                    }
                    Text("照著號碼填單或念給老闆聽；下注完按「標記已下注」。")
                        .font(.subheadline)
                        .foregroundStyle(Theme.subtext)

                    ForEach(LotteryGame.allCases) { game in
                        let list = tickets.filter { $0.game == game }
                        if !list.isEmpty {
                            Text(game.name)
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundStyle(Theme.gold)
                                .padding(.top, 6)
                            ForEach(Array(list.enumerated()), id: \.element.id) { index, ticket in
                                bigTicket(ticket, index: index + 1)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .preferredColorScheme(.dark)
        // 在投注站看號碼時，螢幕不要自動變暗、鎖定
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    private func bigTicket(_ ticket: SavedTicket, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("第 \(index) 組")
                    .font(.title3.bold())
                    .foregroundStyle(Theme.text)
                Spacer()
                Button {
                    toggleBought(ticket)
                } label: {
                    Label(ticket.bought ? "已下注" : "標記已下注",
                          systemImage: ticket.bought ? "checkmark.circle.fill" : "circle")
                        .font(.subheadline.bold())
                        .foregroundStyle(ticket.bought ? Theme.redInk : Theme.gold)
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .background(Capsule().fill(ticket.bought ? AnyShapeStyle(Theme.goldGradient) : AnyShapeStyle(Color.clear)))
                        .overlay(Capsule().stroke(Theme.gold, lineWidth: ticket.bought ? 0 : 1.5))
                }
                .buttonStyle(.plain)
            }
            // 大顆號碼，一排最多 5 顆
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5),
                      alignment: .leading, spacing: 10) {
                ForEach(ticket.numbers, id: \.self) { n in
                    LotteryBallView(number: n, size: 56)
                }
            }
            if let second = ticket.secondZone {
                HStack(spacing: 10) {
                    Text("第二區")
                        .font(.title3.bold())
                        .foregroundStyle(Theme.gold)
                    LotteryBallView(number: second, isSpecial: true, size: 56)
                }
            }
        }
        .fortuneCard()
        .opacity(ticket.bought ? 0.6 : 1)
    }

    private func toggleBought(_ ticket: SavedTicket) {
        guard let i = tickets.firstIndex(where: { $0.id == ticket.id }) else { return }
        tickets[i].bought.toggle()
        SavedTicketStore.save(tickets)
    }
}
