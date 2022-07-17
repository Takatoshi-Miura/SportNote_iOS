//
//  Definition+Note.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/07/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

/// ノート種別
enum NoteType: Int, CaseIterable {
    case free
    case practice
    case tournament
}

/// 天気
enum Weather: Int, CaseIterable {
    case sunny
    case cloudy
    case rainy
    
    var title: String {
        switch self {
        case .sunny: return TITLE_SUNNY
        case .cloudy: return TITLE_CLOUDY
        case .rainy: return TITLE_RAINY
        }
    }
}


// MARK: - OldData

/// 旧データのノート種別
enum OldNoteType: String {
    case practice = "練習記録"
    case Tournament = "大会記録"
}

/// 旧データの天気
enum OldWeather: String {
    case sunny = "晴れ"
    case cloudy = "くもり"
    case rainy = "雨"
}
