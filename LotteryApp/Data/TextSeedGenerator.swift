//
//  TextSeedGenerator.swift
//  LotteryApp
//
//  「無腦選號」用：把任意一段文字轉成穩定的種子值，內容本身沒有意義，
//  純粹圖個樂——輸入什麼都行，同一段文字永遠換算出同一組號碼。
//

import Foundation

enum TextSeedGenerator {
    /// 穩定字串雜湊（DJB2），不受 Swift 內建 Hasher 的隨機加鹽影響，確保結果可重現。
    static func seed(from text: String) -> Int {
        var hash: UInt64 = 5381
        for byte in text.utf8 {
            hash = ((hash << 5) &+ hash) &+ UInt64(byte)
        }
        return Int(hash & 0x7fff_ffff_ffff_ffff)
    }
}
