//
//  DataConverter.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

class DataConverter {
    
    private let firebaseManager = FirebaseManager()
    private let realmManager = RealmManager()
    
    private var groupArray: [Group] = []
    private var taskArray: [Task] = []
    private var measuresArray: [Measures] = []
    private var memoArray: [Memo] = []
    private var targetArray: [Target] = []
    private var noteArray: [Note] = []
    
    /// 旧データを新データに変換してRealmに保存
    func convertOldToRealm(completion: @escaping () -> ()) {
        convertOldDataToNewData(completion: {
            if self.realmManager.getAllGroup().count == 0 {
                // 未分類グループを自動生成
                let group = Group()
                group.title = TITLE_UNCATEGORIZED
                group.color = Color.gray.rawValue
                self.groupArray = []
                self.groupArray.append(group)
                // 課題を未分類グループに所属させる
                for task in self.taskArray {
                    task.groupID = group.groupID
                }
            }
            self.createRealmWithUpdate()
            completion()
        })
    }
    
    /// 全ての新データをRealmに保存
    private func createRealmWithUpdate() {
        var resultArray: [Bool] = []
        repeat {
            resultArray = []
            resultArray.append(realmManager.createRealmWithUpdate(objects: groupArray))
            resultArray.append(realmManager.createRealmWithUpdate(objects: taskArray))
            resultArray.append(realmManager.createRealmWithUpdate(objects: measuresArray))
            resultArray.append(realmManager.createRealmWithUpdate(objects: memoArray))
            resultArray.append(realmManager.createRealmWithUpdate(objects: targetArray))
            resultArray.append(realmManager.createRealmWithUpdate(objects: noteArray))
        } while resultArray.contains(false) // 成功するまで繰り返す
    }
    
    /// 全ての旧データを変換
    private func convertOldDataToNewData(completion: @escaping () -> ()) {
        var completionNumber = 0
        
        print("OldTask変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldTask(completion: {
                print("OldTask変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldTarget変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldTarget(completion: {
                print("OldTarget変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldFreeNote変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldFreeNote(completion: {
                print("OldFreeNote変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldNote変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldNote(completion: {
                print("OldNote変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
    }
    
    /// 全ての旧課題データを変換&旧データをFIrebaseから削除
    private func convertOldTask(completion: @escaping () -> ()) {
        firebaseManager.getOldTask({
            let oldTaskArray = self.firebaseManager.oldTaskArray
            for oldTask in oldTaskArray {
                let dic = self.convertToTaskMeasuresMemo(oldTask: oldTask)
                self.taskArray.append(contentsOf: dic["task"]!.first as! [Task])
                self.measuresArray.append(contentsOf: dic["measures"]!.first as! [Measures])
                self.memoArray.append(contentsOf: dic["memo"]!.first as! [Memo])
                self.firebaseManager.deleteOldTask(oldTask: oldTask, completion: {})
            }
            completion()
        })
    }
    
    /// 全ての旧目標データを変換&旧データをFIrebaseから削除
    private func convertOldTarget(completion: @escaping () -> ()) {
        firebaseManager.getOldTarget({
            let oldTargetArray = self.firebaseManager.oldTargetArray
            for oldTarget in oldTargetArray {
                self.targetArray.append(self.convertToTarget(oldTarget: oldTarget))
                self.firebaseManager.deleteOldTarget(oldTarget: oldTarget, completion: {})
            }
            completion()
        })
    }
    
    /// 全ての旧フリーノートデータを変換&旧データをFIrebaseから削除
    private func convertOldFreeNote(completion: @escaping () -> ()) {
        firebaseManager.getOldFreeNote({
            let oldFreeNote = self.firebaseManager.oldFreeNote
            if oldFreeNote.getUserID() != "FreeNoteIsEmpty" {
                self.noteArray.append(self.convertToFreeNote(oldFreeNote: oldFreeNote))
                self.firebaseManager.deleteOldFreeNote(oldFreeNote: oldFreeNote, completion: {})
            }
            completion()
        })
    }
    
    /// 全ての旧ノートデータを変換&旧データをFIrebaseから削除
    private func convertOldNote(completion: @escaping () -> ()) {
        firebaseManager.getOldNote({
            let oldNoteArray = self.firebaseManager.oldNoteArray
            for oldNote in oldNoteArray {
                let note = self.convertToNote(oldNote: oldNote)
                self.noteArray.append(note)
                self.firebaseManager.deleteOldNote(oldNote: oldNote, completion: {})
            }
            completion()
        })
    }
    
    /// 旧データ変換終了後の処理
    /// - Parameters:
    ///   - completion: 完了処理
    ///   - completionNumber: タスク完了数
    private func convertCompletion(completion: @escaping () -> (), completionNumber: Int) {
        // 課題、対策、ノート全ての変換が終了した場合のみ完了処理を実行
        if completionNumber == 4 {
            completion()
        }
    }
    
    /// 年月日文字列からDate型に変換
    /// - Parameters:
    ///   - year: 年
    ///   - month: 月
    ///   - date: 日
    /// - Returns: Date型の日付
    private func convertToDate(year: Int, month: Int, date: Int) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'年'M'月'd'日"
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.date(from: "\(year)年\(month)月\(date)日")!
    }

    /// 天気文字列からWeather型に変換
    /// - Parameters:
    ///    - weather: 天気文字列
    /// - Returns: Weather型の天気
    private func convertToWeather(weather: String) -> Int {
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
    
    /// 旧課題を新課題、対策、メモに変換
    /// - Parameters:
    ///   - oldTask: 旧課題データ
    /// - Returns: ["task": 新課題1つ,  "measures": 対策群,  "memo": メモ群]
    private func convertToTaskMeasuresMemo(oldTask: Task_old) -> [String: [Any]] {
        // 課題データ作成
        let task = Task()
        task.title = oldTask.getTitle()
        task.cause = oldTask.getCause()
        task.order = oldTask.getOrder()
        task.isComplete = oldTask.getAchievement()
        task.isDeleted = oldTask.getIsDeleted()
        var taskArray: [Task] = []
        taskArray.append(task)
        
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
        newDataDic["task"]?.append(taskArray)
        newDataDic["measures"]?.append(measuresArray)
        newDataDic["memo"]?.append(memoArray)
        return newDataDic
    }
    
    /// 旧目標を新目標に変換
    /// - Parameters:
    ///   - oldTarget: 旧目標データ
    /// - Returns: 新目標データ
    private func convertToTarget(oldTarget: Target_old) -> Target {
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
    private func convertToFreeNote(oldFreeNote: FreeNote_old) -> Note {
        let note = Note()
        note.noteType = NoteType.free.rawValue
        note.title = oldFreeNote.getTitle()
        note.detail = oldFreeNote.getDetail()
        return note
    }

    /// 旧ノート(練習、大会)を新ノートに変換
    /// - Parameters:
    ///   - oldNote: 旧ノートデータ
    /// - Returns: 新ノートデータ
    private func convertToNote(oldNote: Note_old) -> Note {
        let note = Note()
        // 旧ノートのnoteIDは番号だが、対策と紐付ける必要があるため新たにUUIDを付けることはしない
        // 新ノートからUUIDでID付けを行う
        note.noteID = String(oldNote.getNoteID())
        note.weather = convertToWeather(weather: oldNote.getWeather())
        note.temperature = oldNote.getTemperature()
        note.condition = oldNote.getPhysicalCondition()
        note.reflection = oldNote.getReflection()
        note.date = convertToDate(year: oldNote.getYear(), month: oldNote.getMonth(), date: oldNote.getDate())
        
        if oldNote.getNoteType() == OldNoteType.practice.rawValue {
            note.noteType = NoteType.practice.rawValue
            note.purpose = oldNote.getPurpose()
            note.detail = oldNote.getDetail()
        } else {
            note.noteType = NoteType.tournament.rawValue
            note.target = oldNote.getTarget()
            note.consciousness = oldNote.getConsciousness()
            note.result = oldNote.getResult()
        }
        return note
    }

}

