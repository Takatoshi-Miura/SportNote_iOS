//
//  Definition.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

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

enum WeatherString: String {
    case sunny = "晴れ"
    case cloudy = "くもり"
    case rainy = "雨"
}

enum OldNoteType: String {
    case practice = "練習記録"
    case Tournament = "大会記録"
}

enum Color: Int, CaseIterable {
    case red
    case pink
    case orange
    case yellow
    case green
    case blue
    case purple
    case gray
    
    var title: String {
        switch self {
        case .red: return TITLE_RED
        case .pink: return TITLE_PINK
        case .orange: return TITLE_ORANGE
        case .yellow: return TITLE_YELLOW
        case .green: return TITLE_GREEN
        case .blue: return TITLE_BLUE
        case .purple: return TITLE_PURPLE
        case .gray: return TITLE_GRAY
        }
    }
    
    var color: UIColor {
        switch self {
        case .red: return UIColor.systemRed
        case .pink: return UIColor.systemPink
        case .orange: return UIColor.systemOrange
        case .yellow: return UIColor.systemYellow
        case .green: return UIColor.systemGreen
        case .blue: return UIColor.systemBlue
        case .purple: return UIColor.systemPurple
        case .gray: return UIColor.systemGray
        }
    }
}

enum Month: Int, CaseIterable {
    case January
    case February
    case March
    case April
    case May
    case June
    case July
    case August
    case September
    case October
    case November
    case December
    
    var title: String {
        switch self {
        case .January: return TITLE_JANUARY
        case .February: return TITLE_FEBRUARY
        case .March: return TITLE_MARCH
        case .April: return TITLE_APRIL
        case .May: return TITLE_MAY
        case .June: return TITLE_JUNE
        case .July: return TITLE_JULY
        case .August: return TITLE_AUGUST
        case .September: return TITLE_SEPTEMBER
        case .October: return TITLE_OCTOBER
        case .November: return TITLE_NOVEMBER
        case .December: return TITLE_DECEMBER
        }
    }
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

extension Array where Element: Equatable {
    typealias E = Element

    func subtracting(_ other: [E]) -> [E] {
        return self.compactMap { element in
            if (other.filter { $0 == element }).count == 0 {
                return element
            } else {
                return nil
            }
        }
    }

    mutating func subtract(_ other: [E]) {
        self = subtracting(other)
    }
}
