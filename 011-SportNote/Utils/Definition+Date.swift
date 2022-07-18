//
//  Definition+Date.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/07/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

/// 月
enum Month: Int, CaseIterable {
    case January = 1
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

/// 曜日
enum WeekDay: Int, CaseIterable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
    var title: String {
        switch self {
        case .sunday:   return "Sun"
        case .monday:   return "Mon"
        case .tuesday:  return "Tue"
        case .wednesday:return "Wed"
        case .thursday: return "Thu"
        case .friday:   return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var color: UIColor {
        switch self {
        case .sunday:   return UIColor.red
        case .monday:   return UIColor.label
        case .tuesday:  return UIColor.label
        case .wednesday:return UIColor.label
        case .thursday: return UIColor.label
        case .friday:   return UIColor.label
        case .saturday: return UIColor.blue
        }
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

/// 時刻を変換
/// - Parameters:
///    - date: 変換したいDate
/// - Returns: 現在時刻（yyyy/MM/dd）
func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = "yyyy/MM/dd"
    return dateFormatter.string(from: date)
}
