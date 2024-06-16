//
//  Definition+Date.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/07/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

/// 年
enum Year {
    
    /// 1950~今年の10年後まで
    static var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1950...currentYear + 10)
    }
    
    /// 今年の年のインデックスを取得
    /// - Returns: 今年の年のインデックス
    static func getCurrentYearIndex() -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let index = years.firstIndex(of: currentYear) else {
            fatalError("Current year not found in the 'years' array.")
        }
        return index
    }
    
}

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
    
    /// 今月のMonthを取得
    /// - Returns: 今月のMonthの値
    static func getCurrentMonth() -> Month {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        return Month(rawValue: currentMonth) ?? .January
    }
    
    /// 今月のMonthのインデックスを取得
    /// - Returns: 今月のMonthのインデックス
    static func getCurrentMonthIndex() -> Int {
        return Month.getCurrentMonth().rawValue - 1
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
///    - format: 変換後の形式
/// - Returns: 変換後の時刻文字列
func formatDate(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ja_JP")
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

/// 年月日文字列からDate型に変換
/// - Parameters:
///   - year: 年
///   - month: 月
///   - date: 日
/// - Returns: Date型の日付
func convertToDate(year: Int, month: Int, date: Int) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy'年'M'月'd'日"
    dateFormatter.locale = Locale(identifier: "ja_JP")
    return dateFormatter.date(from: "\(year)年\(month)月\(date)日")!
}
