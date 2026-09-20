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
    @AppStorage("userBirthdayTimestamp") private var birthdayTimestamp: Double = 0
    @AppStorage("userName") private var userName: String = ""

    @State private var birthdayDraft: Date = Date()
    @State private var now: Date = Date()
    @State private var freeText: String = ""
    @State private var selectedRules: Set<SelectionRule> = []
    @State private var resultNumbers: [Int]?
    @State private var resultRuleNames: [String] = []

    private let repository: DrawResultRepository = MockDrawResultRepository()
    @State private var drawResults: [DrawResult] = []

    private let calendar = Calendar(identifier: .gregorian)
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    private var hasBirthday: Bool { birthdayTimestamp > 0 }
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
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        resultSection
                        generateButton
                        CandidateCountPicker()
                        basicInfoSection

                        VStack(alignment: .leading, spacing: 12) {
                            Text("選號規則（可複選）")
                                .font(.caption)
                                .foregroundStyle(.gray)
                            ForEach(SelectionRule.allCases) { rule in
                                ruleRow(rule)
                            }
                        }

                        Text("以上規則多為民俗參考或簡化版換算，正式規則來源待確認；大樂透開獎結果完全隨機，僅供參考娛樂，不保證中獎機率。")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                }
            }
            .navigationTitle("超樂透幸運選號")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .tint(.yellow)
        .preferredColorScheme(.dark)
        .onAppear {
            if hasBirthday {
                birthdayDraft = birthday
            }
            if drawResults.isEmpty {
                drawResults = repository.fetchAll()
            }
        }
        .onReceive(timer) { now = $0 }
    }

    // MARK: - 結果

    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let resultNumbers {
                StatSuggestionCard(
                    title: "幸運號碼",
                    subtitle: resultRuleNames.isEmpty ? "" : "依據：\(resultRuleNames.joined(separator: "、"))",
                    numbers: resultNumbers
                )
            } else {
                EmptyHintCard(title: "幸運號碼", hint: "勾選下方想用的規則，按「產生號碼」")
            }
        }
    }

    // MARK: - 生日 / 姓名

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("生日")
                    .font(.caption)
                    .foregroundStyle(.gray)
                HStack(spacing: 10) {
                    DatePicker("", selection: $birthdayDraft, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(.yellow)
                    Button("設定生日") {
                        birthdayTimestamp = birthdayDraft.timeIntervalSince1970
                    }
                    .font(.caption.bold())
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.yellow))
                }
                Text(hasBirthday ? "已設定：\(formattedDate(birthday))" : "尚未設定，請選擇日期後點「設定生日」")
                    .font(.system(size: 11))
                    .foregroundStyle(hasBirthday ? .green : .gray)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("姓名")
                    .font(.caption)
                    .foregroundStyle(.gray)
                TextField("輸入姓名", text: $userName)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.12)))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.10)))
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
                        .foregroundStyle(isSelected ? .yellow : .gray)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rule.title(candidateCount: candidateCount))
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                        Text(rule.subtitle)
                            .font(.caption)
                            .foregroundStyle(.gray)
                        if let hint = unavailableHint(for: rule) {
                            Text(hint)
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if rule == .freeText {
                TextField("想打什麼都行，幹話、心情、亂打一通都可以", text: $freeText)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color(white: 0.12)))
                    .padding(.leading, 32)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(white: 0.10)))
    }

    private func unavailableHint(for rule: SelectionRule) -> String? {
        switch rule {
        case .birthdayZodiac, .chineseZodiac:
            return hasBirthday ? nil : "尚未設定生日"
        case .nameStroke:
            return userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "尚未輸入姓名" : nil
        case .freeText:
            return freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "尚未輸入文字" : nil
        case .topFrequent, .leastFrequent, .dueNumbers, .chineseHour:
            return nil
        }
    }

    // MARK: - 產生號碼

    private var generateButton: some View {
        Button {
            generate()
        } label: {
            Text("產生號碼")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .foregroundStyle(.black)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
        .disabled(selectedRules.isEmpty)
        .opacity(selectedRules.isEmpty ? 0.4 : 1)
    }

    private func contribution(for rule: SelectionRule) -> (numbers: [Int], seed: Int)? {
        switch rule {
        case .topFrequent:
            return (LotteryStatsEngine.topFrequent(in: drawResults, count: candidateCount).map(\.number), 0)
        case .leastFrequent:
            return (LotteryStatsEngine.leastFrequent(in: drawResults, count: candidateCount).map(\.number), 0)
        case .dueNumbers:
            return (LotteryStatsEngine.dueNumbers(in: drawResults, count: candidateCount).map(\.number), 0)
        case .birthdayZodiac:
            guard hasBirthday, let zodiacSign else { return nil }
            return (zodiacSign.referenceLuckyNumbers, Int(birthdayTimestamp))
        case .chineseHour:
            let seed = calendar.component(.hour, from: now) &+ calendar.component(.day, from: now) &* 31
            return (currentHour.referenceNumbers, seed)
        case .chineseZodiac:
            guard hasBirthday, let chineseZodiac, let fiveElement else { return nil }
            return (chineseZodiac.referenceNumbers + fiveElement.referenceNumbers, Int(birthdayTimestamp) &+ 17)
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
            usedNames.append(rule.title(candidateCount: candidateCount))
        }

        guard !pools.isEmpty else {
            resultNumbers = nil
            resultRuleNames = []
            return
        }

        var interleaved: [Int] = []
        var seen = Set<Int>()
        var index = 0
        while interleaved.count < candidateCount {
            var addedAny = false
            for pool in pools where index < pool.count {
                let n = pool[index]
                if seen.insert(n).inserted {
                    interleaved.append(n)
                    addedAny = true
                    if interleaved.count == candidateCount { break }
                }
            }
            index += 1
            if !addedAny, pools.allSatisfy({ index >= $0.count }) { break }
        }

        let combinedSeed = seeds.reduce(0) { $0 ^ $1 }
        resultNumbers = LuckyNumberGenerator.generate(seed: combinedSeed, preferredNumbers: interleaved, count: candidateCount)
        resultRuleNames = usedNames
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
