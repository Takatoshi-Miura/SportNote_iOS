//
//  DataConverter.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

class DataConverter {
    
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


    
    /// 旧課題を新課題、対策、メモに変換
    /// - Parameters:
    ///   - oldTask: 旧課題データ
    /// - Returns: ["task": 新課題1つ,  "measures": 対策群,  "memo": メモ群]
    func convertToTaskMeasuresMemo(oldTask: Task_old) -> [String: [Any]] {
        // 課題データ作成
        let task = Task()
        task.title = oldTask.getTitle()
        task.cause = oldTask.getCause()
        task.order = oldTask.getOrder()
        task.isComplete = oldTask.getAchievement()
        task.isDeleted = oldTask.getIsDeleted()
        
        var measuresArray: [Measures] = []
        var memoArray: [Memo] = []
        for title in oldTask.getMeasuresTitleArray() {
            // 対策データ作成
            let measures = Measures()
            measures.title = title
            measures.taskID = task.taskID
            measuresArray.append(measures)
            
            // メモデータ作成
            var keyArray: [String] = [] // 有効性コメント
            var valueArray: [Int] = []  // ノートID
            let oldMemoArray = oldTask.getMeasuresData()[title]!  // [有効性:ノートID]配列
            for memo in oldMemoArray {
                keyArray.append(contentsOf: memo.keys)
                valueArray.append(contentsOf: memo.values)
            }
            for index in 0..<oldMemoArray.count {
                let memo = Memo()
                memo.detail = keyArray[index]
                memo.noteID = String(valueArray[index])
                memo.measuresID = measures.measuresID
                memoArray.append(memo)
            }
        }
        
        var newDataDic: [String: [Any]] = [:]
        newDataDic["task"] = newDataDic["task"] ?? []
        newDataDic["measures"] = newDataDic["measures"] ?? []
        newDataDic["memo"] = newDataDic["memo"] ?? []
        newDataDic["task"]?.append([task])
        newDataDic["measures"]?.append(measuresArray)
        newDataDic["memo"]?.append(memoArray)
        return newDataDic
    }
    
    /// 旧目標を新目標に変換
    /// - Parameters:
    ///   - oldTarget: 旧目標データ
    /// - Returns: 新目標データ
    func convertToTarget(oldTarget: Target_old) -> Target {
        let target = Target()
        target.title = oldTarget.getDetail()
        target.year = oldTarget.getYear()
        target.month = oldTarget.getMonth()
        target.isDeleted = oldTarget.getIsDeleted()
        if target.month == 13 { target.isYearlyTarget = true }
        return target
    }
    
    /// 旧フリーノートを新フリーノートに変換
    /// - Parameters:
    ///   - oldFreeNote: 旧フリーノートデータ
    /// - Returns: 新フリーノートデータ
    func convertToFreeNote(oldFreeNote: FreeNote_old) -> FreeNote {
        let freeNote = FreeNote()
        freeNote.title = oldFreeNote.getTitle()
        freeNote.detail = oldFreeNote.getDetail()
        return freeNote
    }

    /// 旧ノートを新ノートに変換
    /// - Parameters:
    ///   - oldNote: 旧ノートデータ
    /// - Returns: 新ノートデータ(PracticeNote or TournamentNote)
    func convertToNote(oldNote: Note_old) -> Any {
        if oldNote.getNoteType() == OldNoteType.practice.rawValue {
            let practiceNote = PracticeNote()
            // 旧ノートのnoteIDは番号だが、対策と紐付ける必要があるため新たにUUIDを付けることはしない
            // 新ノートからUUIDでID付けを行う
            practiceNote.practiceNoteID = String(oldNote.getNoteID())
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
            tournamentNote.tournamentNoteID = String(oldNote.getNoteID())
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

