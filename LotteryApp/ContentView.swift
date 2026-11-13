//
//  ContentView.swift
//  LotteryApp
//
//  單一首頁：所有選號規則都是可勾選項目，可單選或複選，
//  按「產生號碼」後把結果彙總顯示在最上方。
//

import Combine
import SwiftUI

struct ContentView: View {
    @AppStorage("candidateCount") private var candidateCount: Int = 6
    @AppStorage("selectedGame") private var gameRaw: String = LotteryGame.lotto649.rawValue
    private var game: LotteryGame { LotteryGame(rawValue: gameRaw) ?? .lotto649 }
    private var gameBinding: Binding<LotteryGame> {
        Binding(get: { game }, set: { gameRaw = $0.rawValue })
    }
    /// 實際要選幾個：至少是這個彩種一注的數量（今彩539 為 5、其他為 6），最多 10
    private var effectiveCount: Int { min(10, max(candidateCount, game.pickCount)) }
    @AppStorage("userBirthdayTimestamp") private var birthdayTimestamp: Double = 0
    /// 另外記「有沒有設定過生日」：1970 年以前出生的生日數值是負的，不能用 > 0 判斷
    @AppStorage("userBirthdaySet") private var birthdaySet: Bool = false
    @AppStorage("userName") private var userName: String = ""

    @State private var birthdayDraft: Date = Date()
    @State private var now: Date = Date()
    @State private var freeText: String = ""
    @State private var selectedRules: Set<SelectionRule> = []
    @State private var resultNumbers: [Int]?
    @State private var resultRuleNames: [String] = []
    @State private var mascotBounce = 0
    @State private var mascotNote: String?
    @State private var savedTickets: [SavedTicket] = []
    @State private var resultSecondZone: Int?

    private let repository: DrawResultRepository = BundledDrawResultRepository()
    @State private var drawResults: [DrawResult] = []

    private let calendar = Calendar(identifier: .gregorian)
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var hasBirthday: Bool { birthdaySet || birthdayTimestamp > 0 }
    private var birthday: Date { Date(timeIntervalSince1970: birthdayTimestamp) }

    private var zodiacSign: ZodiacSign? {
        guard hasBirthday else { return nil }
        let comps = calendar.dateComponents([.month, .day], from: birthday)
        return ZodiacSign.from(month: comps.month ?? 1, day: comps.day ?? 1)
    }

    private var chineseZodiac: ChineseZodiac? {
        guard hasBirthday else { return nil }
        return ChineseZodiac.from(year: calendar.component(.year, from: birthday))
    }

    private var fiveElement: FiveElement? {
        guard hasBirthday else { return nil }
        return FiveElement.from(year: calendar.component(.year, from: birthday))
    }

    private var currentHour: ChineseHour { ChineseHour.current(at: now) }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        MokuMascot(
                            imageName: mascotNote.map { $0.hasPrefix("收好了") ? "moku_cheer" : "moku_normal" } ?? (resultNumbers == nil ? "moku_wave" : "moku_ingot"),
                            message: mascotNote ?? (resultNumbers == nil ? "勾選方法，我幫你選號碼！" : "發財號碼來囉！"),
                            bounce: mascotBounce
                        )
                        GamePicker(selection: gameBinding)
                        resultSection
                        generateButton
                        SavedTicketsSection(tickets: $savedTickets, game: game, latestDraw: latestDraw)
                        CandidateCountPicker(minimum: game.pickCount)
                        basicInfoSection

                        VStack(alignment: .leading, spacing: 12) {
                            Text("選號規則（可複選）")
                                .font(.caption)
                                .foregroundStyle(Theme.subtext)
                            ForEach(SelectionRule.allCases) { rule in
                                ruleRow(rule)
                            }
                        }

                        Text("以上規則多為民俗命理參考或簡化版換算，並非官方標準；大樂透開獎結果完全隨機，僅供參考娛樂，不保證中獎機率。")
                            .font(.caption2)
                            .foregroundStyle(Theme.subtext)
                    }
                    .padding()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .tint(Theme.gold)
        .preferredColorScheme(.dark)
        .onAppear {
            if hasBirthday {
                birthdayDraft = birthday
            }
            savedTickets = SavedTicketStore.load()
        }
        .task(id: gameRaw) {
            // 切換彩種時：先用手機裡的資料，再連網更新
            let current = game
            drawResults = repository.fetchAll(game: current)
            if let fresh = await RemoteDrawResultSync.refresh(game: current), !fresh.isEmpty, current == game {
                drawResults = fresh
            }
        }
        .onChange(of: gameRaw) { _, _ in
            resultNumbers = nil
            resultSecondZone = nil
            resultRuleNames = []
            mascotNote = "換成\(game.name)囉！"
            mascotBounce += 1
        }
        .onReceive(timer) { now = $0 }
    }

    // MARK: - 結果

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let resultNumbers {
                StatSuggestionCard(
                    title: "\(game.name)幸運號碼",
                    subtitle: resultRuleNames.isEmpty ? "" : "依據：\(resultRuleNames.joined(separator: "、"))",
                    numbers: resultNumbers,
                    secondZone: resultSecondZone
                )
                saveButton(for: resultNumbers)
            } else {
                EmptyHintCard(title: "\(game.name)幸運號碼", hint: "勾選下方想用的規則，按「產生號碼」")
            }
        }
    }

    // MARK: - 收藏

    private var latestDraw: DrawResult? {
        drawResults.max { $0.date < $1.date }
    }

    private func saveButton(for numbers: [Int]) -> some View {
        let alreadySaved = savedTickets.contains { $0.game == game && $0.numbers == numbers && $0.secondZone == resultSecondZone }
        let full = savedTickets.count >= SavedTicketStore.maxCount
        return Button {
            saveTicket(numbers)
        } label: {
            Text(alreadySaved ? "✓ 已收藏" : (full ? "已存滿 10 組，請先刪除一組" : "⭐ 收藏這組號碼"))
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(Theme.gold)
                .background(RoundedRectangle(cornerRadius: 12).stroke(Theme.gold, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .disabled(alreadySaved || full)
        .opacity(alreadySaved || full ? 0.55 : 1)
    }

    private func saveTicket(_ numbers: [Int]) {
        guard savedTickets.count < SavedTicketStore.maxCount,
              !savedTickets.contains(where: { $0.game == game && $0.numbers == numbers && $0.secondZone == resultSecondZone }) else { return }
        // 新的放最上面
        savedTickets.insert(SavedTicket(game: game, numbers: numbers, secondZone: resultSecondZone, rules: resultRuleNames, createdAt: Date()), at: 0)
        SavedTicketStore.save(savedTickets)
        mascotNote = "收好了！開獎後我幫你對獎"
        mascotBounce += 1
    }

    // MARK: - 生日 / 姓名

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TextField("輸入姓名", text: $userName)
                    .foregroundStyle(Theme.text)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.25)))
                    .frame(maxWidth: .infinity)

                DatePicker("", selection: $birthdayDraft, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Theme.gold)
                    .fixedSize()
                    .onChange(of: birthdayDraft) { _, newValue in
                        // 選好日期就直接存起來，不用再按按鈕
                        birthdayTimestamp = newValue.timeIntervalSince1970
                        birthdaySet = true
                    }
            }
            Text(hasBirthday ? "已設定生日：\(formattedDate(birthday))" : "點右邊的日期，選你的生日")
                .font(.system(size: 11))
                .foregroundStyle(hasBirthday ? Theme.gold : Theme.subtext)
        }
        .fortuneCard()
    }

    // MARK: - 規則清單

    private func ruleRow(_ rule: SelectionRule) -> some View {
        let isSelected = selectedRules.contains(rule)
        return VStack(alignment: .leading, spacing: 10) {
            Button {
                if isSelected {
                    selectedRules.remove(rule)
                } else {
                    selectedRules.insert(rule)
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? Theme.gold : Theme.subtext)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.title(candidateCount: effectiveCount))
                            .font(.subheadline.bold())
                            .foregroundStyle(Theme.text)
                        Text(rule.subtitle)
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                        if let hint = unavailableHint(for: rule) {
                            Text(hint)
                                .font(.caption2)
                                .foregroundStyle(Color(red: 1.0, green: 0.75, blue: 0.5))
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if rule == .freeText {
                TextField("想打什麼都行，幹話、心情、亂打一通都可以", text: $freeText)
                    .foregroundStyle(Theme.text)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.25)))
                    .padding(.leading, 32)
            }
        }
        .fortuneCard()
    }

    private func unavailableHint(for rule: SelectionRule) -> String? {
        switch rule {
        case .birthdayZodiac, .chineseZodiac:
            return hasBirthday ? nil : "尚未設定生日"
        case .nameStroke:
            return userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "尚未輸入姓名" : nil
        case .freeText:
            return freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "尚未輸入文字" : nil
        case .topFrequent, .leastFrequent, .dueNumbers:
            return drawResults.isEmpty ? "\(game.name)開獎資料還沒下載，請連上網路" : nil
        case .chineseHour:
            return nil
        }
    }

    // MARK: - 產生號碼

    private var generateButton: some View {
        Button {
            generate()
        } label: {
            Text("🧧 產生號碼")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(Theme.redInk)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.goldGradient))
        .disabled(selectedRules.isEmpty)
        .opacity(selectedRules.isEmpty ? 0.4 : 1)
    }

    private func contribution(for rule: SelectionRule) -> (numbers: [Int], seed: Int)? {
        // 開獎資料還沒下載時，統計類的方法先跳過，避免算出 1、2、3… 這種假結果
        if [.topFrequent, .leastFrequent, .dueNumbers].contains(rule) && drawResults.isEmpty {
            return nil
        }
        switch rule {
        case .topFrequent:
            return (LotteryStatsEngine.topFrequent(in: drawResults, count: effectiveCount, range: game.numberRange).map(\.number), 0)
        case .leastFrequent:
            return (LotteryStatsEngine.leastFrequent(in: drawResults, count: effectiveCount, range: game.numberRange).map(\.number), 0)
        case .dueNumbers:
            return (LotteryStatsEngine.dueNumbers(in: drawResults, count: effectiveCount, range: game.numberRange).map(\.number), 0)
        case .birthdayZodiac:
            guard hasBirthday, let zodiacSign else { return nil }
            return (zodiacSign.referenceLuckyNumbers, Int(birthdayTimestamp))
        case .chineseHour:
            let seed = calendar.component(.hour, from: now) &+ calendar.component(.day, from: now) &* 31
            return (currentHour.referenceNumbers, seed)
        case .chineseZodiac:
            guard hasBirthday, let chineseZodiac, let fiveElement else { return nil }
            // 生肖（地支五行）與生年（天干五行）交錯排列，避免其中一邊號碼較多時獨佔結果。
            let interleaved = zip(chineseZodiac.referenceNumbers, fiveElement.referenceNumbers)
                .flatMap { [$0, $1] }
            return (interleaved, Int(birthdayTimestamp) &+ 17)
        case .nameStroke:
            let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return (NameStrokeCalculator.perCharacterStrokes(of: trimmed), NameStrokeCalculator.totalStrokes(of: trimmed))
        case .freeText:
            let trimmed = freeText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            return ([], TextSeedGenerator.seed(from: trimmed))
        }
    }

    /// 合併多個已勾選規則的候選號碼：輪流從各規則取號碼去重湊滿，
    /// 避免排序在前的規則獨佔結果；數量不足時用合併種子值補滿。
    private func generate() {
        var pools: [[Int]] = []
        var seeds: [Int] = []
        var usedNames: [String] = []

        for rule in SelectionRule.allCases where selectedRules.contains(rule) {
            guard let contribution = contribution(for: rule) else { continue }
            pools.append(contribution.numbers)
            seeds.append(contribution.seed)
            usedNames.append(rule.title(candidateCount: effectiveCount))
        }

        // 勾了但資料還沒填的方法，請魔酷熊提醒
        let missing = SelectionRule.allCases
            .filter { selectedRules.contains($0) }
            .compactMap { unavailableHint(for: $0) }
        let missingText = Array(Set(missing)).sorted().joined(separator: "、")

        guard !pools.isEmpty else {
            resultNumbers = nil
            resultSecondZone = nil
            resultRuleNames = []
            mascotNote = missingText.isEmpty ? "先勾選一種方法喔！" : "還不能選號：\(missingText)"
            mascotBounce += 1
            return
        }
        mascotNote = missingText.isEmpty ? nil : "有些方法先跳過了：\(missingText)"

        var interleaved: [Int] = []
        var seen = Set<Int>()
        var index = 0
        while interleaved.count < effectiveCount {
            var addedAny = false
            for pool in pools where index < pool.count {
                let n = pool[index]
                if seen.insert(n).inserted {
                    interleaved.append(n)
                    addedAny = true
                    if interleaved.count == effectiveCount { break }
                }
            }
            index += 1
            if !addedAny, pools.allSatisfy({ index >= $0.count }) { break }
        }

        let combinedSeed = seeds.reduce(0) { $0 ^ $1 }
        resultNumbers = LuckyNumberGenerator.generate(seed: combinedSeed, preferredNumbers: interleaved,
                                                      count: effectiveCount, range: game.numberRange)
        if let secondRange = game.secondZoneRange {
            // 勾了「常開號碼」就用第二區最常開的號碼，否則用種子值換算
            if selectedRules.contains(.topFrequent),
               let top = LotteryStatsEngine.topSecondZone(in: drawResults, range: secondRange) {
                resultSecondZone = top
            } else {
                resultSecondZone = LuckyNumberGenerator.secondZone(seed: combinedSeed, range: secondRange)
            }
        } else {
            resultSecondZone = nil
        }
        resultRuleNames = usedNames
        mascotBounce += 1   // 魔酷熊跳一下
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}
