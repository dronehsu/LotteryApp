//
//  NameStrokeCalculator.swift
//  LotteryApp
//
//  簡化版姓名筆劃估算：依中文字元的 Unicode 編碼特徵換算「筆劃數」，
//  非康熙字典正式筆劃資料，待建置完整筆劃字典後可替換此邏輯。
//

import Foundation

enum NameStrokeCalculator {
    static func totalStrokes(of name: String) -> Int {
        perCharacterStrokes(of: name).reduce(0, +)
    }

    static func perCharacterStrokes(of name: String) -> [Int] {
        name.unicodeScalars
            .filter { $0.value >= 0x4E00 && $0.value <= 0x9FFF }
            .map { Int($0.value % 23) + 3 }
    }
}
