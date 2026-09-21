//
//  SelectionRule.swift
//  LotteryApp
//
//  單一首頁、勾選式選號規則。使用者可複選任意數量的規則，
//  按下「產生號碼」後把各規則算出的候選號碼合併成一組結果。
//

import Foundation

enum SelectionRule: String, CaseIterable, Identifiable {
    case freeText
    case topFrequent
    case leastFrequent
    case dueNumbers
    case birthdayZodiac
    case chineseHour
    case chineseZodiac
    case nameStroke

    var id: String { rawValue }

    func title(candidateCount: Int) -> String {
        switch self {
        case .topFrequent: return "前 \(candidateCount) 大常開獎號碼"
        case .leastFrequent: return "\(candidateCount) 個最少開獎號碼"
        case .dueNumbers: return "拖牌預測"
        case .birthdayZodiac: return "生日 + 星座幸運號"
        case .chineseHour: return "吉時幸運號"
        case .chineseZodiac: return "生肖 / 五行幸運號"
        case .nameStroke: return "姓名筆劃選號"
        case .freeText: return "無腦選號"
        }
    }

    var subtitle: String {
        switch self {
        case .topFrequent: return "依全部歷史資料統計出現頻率最高"
        case .leastFrequent: return "依全部歷史資料統計出現頻率最低"
        case .dueNumbers: return "依前 50 期走勢計算遺漏值，推薦最久未開出的號碼"
        case .birthdayZodiac: return "依生日換算星座，搭配星座參考幸運數字（需先設定生日）"
        case .chineseHour: return "依當下時辰對照參考表產生（規則來源待確認）"
        case .chineseZodiac: return "依生日換算生肖與五行，對照參考表產生（需先設定生日，規則來源待確認）"
        case .nameStroke: return "依姓名筆劃數換算產生（需先輸入姓名，簡化版估算）"
        case .freeText: return "打的內容不重要，文字直接轉換成一組號碼，純娛樂"
        }
    }
}
