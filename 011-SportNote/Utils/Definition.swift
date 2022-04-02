//
//  Definition.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

enum Weather: Int {
    case sunny = 0
    case cloudy
    case rainy
}

enum WeatherString: String {
    case sunny = "晴れ"
    case cloudy = "くもり"
    case rainy = "雨"
}

enum OldNoteType: String {
    case practice = "練習記録"
    case Tournament = "大会記録"
}

/// iPad判定
func isiPad() -> Bool {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return true
    } else {
        return false
    }
}

/// 現在時刻を取得
/// - Returns: 現在時刻（yyyy-MM-dd HH:mm:ss）
func getCurrentTime() -> String {
    let now = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return dateFormatter.string(from: now)
}

