//
//  DBDataFormatter.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

class DBDataFormatter {
    
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

    /// 天気文字列からWeather型に変換
    /// - Parameters:
    ///    - weather: 天気文字列
    /// - Returns: Weather型の天気
    func convertToWeather(weather: String) -> Int {
        switch weather {
        case WeatherString.sunny.rawValue:
            return Weather.sunny.rawValue
        case WeatherString.cloudy.rawValue:
            return Weather.cloudy.rawValue
        case WeatherString.rainy.rawValue:
            return Weather.rainy.rawValue
        default:
            return Weather.sunny.rawValue
        }
    }

    /// 旧ノートがRealmに新ノートとして保存されてるかチェックはdeletedで行う



    /// 旧ノートを新ノートに変換
    /// - Parameters:
    ///   - oldNote: 旧ノートデータ
    /// - Returns: 新ノートデータ(PracticeNote or TournamentNote)
    func convertToNote(oldNote: Note_old) -> Any {
        if oldNote.getNoteType() == OldNoteType.practice.rawValue {
            let practiceNote = PracticeNote()
            practiceNote.weather = convertToWeather(weather: oldNote.getWeather())
            practiceNote.temperature = oldNote.getTemperature()
            practiceNote.condition = oldNote.getPhysicalCondition()
            practiceNote.purpose = oldNote.getPurpose()
            practiceNote.detail = oldNote.getDetail()
            practiceNote.reflection = oldNote.getReflection()
            practiceNote.date = convertToDate(year: oldNote.getYear(), month: oldNote.getMonth(), date: oldNote.getDate())
            return practiceNote
        } else {
            let tournamentNote = TournamentNote()
            tournamentNote.weather = convertToWeather(weather: oldNote.getWeather())
            tournamentNote.temperature = oldNote.getTemperature()
            tournamentNote.condition = oldNote.getPhysicalCondition()
            tournamentNote.target = oldNote.getTarget()
            tournamentNote.consciousness = oldNote.getConsciousness()
            tournamentNote.result = oldNote.getResult()
            tournamentNote.reflection = oldNote.getReflection()
            tournamentNote.date = convertToDate(year: oldNote.getYear(), month: oldNote.getMonth(), date: oldNote.getDate())
            return tournamentNote
        }
    }

}

