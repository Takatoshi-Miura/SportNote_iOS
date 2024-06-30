//
//  DataConverter.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation
import RealmSwift

class DataConverter {
    
    private let firebaseManager = FirebaseManager()
    private let realmManager = RealmManager()
    
    private var groupArray: [Group] = []
    private var taskArray: [TaskData] = []
    private var measuresArray: [Measures] = []
    private var memoArray: [Memo] = []
    private var targetArray: [Target] = []
    private var noteArray: [Note] = []
    
    /// 旧データを新データに変換してRealmに保存
    func convertOldToRealm() async {
        // 旧データを新データに変換
        await convertOldDataToNewData()
        
        let realmGroupArray: [Group] = await realmManager.getAllGroup()
        if realmGroupArray.isEmpty {
            // 未分類グループを自動生成
            let defaultGroup = Group(title: TITLE_UNCATEGORIZED, color: Color.gray, order: 0)
            self.groupArray = [defaultGroup]
            // 課題を未分類グループに所属させる
            for task in self.taskArray {
                task.groupID = defaultGroup.groupID
            }
        }
        
        // 新規ユーザの場合、フリーノートを自動作成
        if let _ = await realmManager.getFreeNote() {
        } else {
            let freeNote = Note(freeWithTitle: TITLE_FREE_NOTE)
            freeNote.detail = MESSAGE_FREE_NOTE
            self.noteArray.append(freeNote)
        }
        
        createAndUpdateRealm()
    }
    
    /// 全ての新データをRealmに保存
    private func createAndUpdateRealm() {
        let arrays = [groupArray, taskArray, measuresArray, memoArray, targetArray, noteArray] as [Any]
        for array in arrays {
            var success = false
            repeat {
                success = realmManager.createRealmWithUpdate(objects: array as! [Object])
            } while !success // 失敗したらリトライ
        }
    }
    
    /// 旧データを新データに変換（Swift Concurrency）
    /// 各々のデータ変換処理が全て終わるのを待つ
    private func convertOldDataToNewData() async {
        print("開始:旧データ変換----------")
        async let oldTask: Void = convertOldTask()
        async let oldTarget: Void = convertOldTarget()
        async let oldFreeNote: Void = convertOldFreeNote()
        async let oldNote: Void = convertOldNote()
        
        let _: [Void] = await [oldTask, oldTarget, oldFreeNote, oldNote]
        print("終了:旧データ変換----------")
    }
    
    /// 全ての旧Taskを変換&FIrebaseから削除
    private func convertOldTask() async {
        print("OldTask変換開始")
        
        // Firebaseの旧Taskを全取得(取得完了を待つ)
        let oldTaskArray: [Task_old] = await firebaseManager.getOldTask()
        
        for oldTask in oldTaskArray {
            let dic = self.convertToTaskMeasuresMemo(oldTask: oldTask)
            self.taskArray.append(contentsOf: dic["task"]!.first as! [TaskData])
            self.measuresArray.append(contentsOf: dic["measures"]!.first as! [Measures])
            self.memoArray.append(contentsOf: dic["memo"]!.first as! [Memo])
            self.firebaseManager.deleteOldTask(oldTask: oldTask, completion: {})
        }
        print("OldTask変換終了")
    }
    
    /// 全ての旧Targetを変換&FIrebaseから削除
    private func convertOldTarget() async {
        print("OldTarget変換開始")
        
        // Firebaseの旧Targetを全取得(取得完了を待つ)
        let oldTargetArray: [Target_old] = await firebaseManager.getOldTarget()
        
        for oldTarget in oldTargetArray {
            self.targetArray.append(self.convertToTarget(oldTarget: oldTarget))
            self.firebaseManager.deleteOldTarget(oldTarget: oldTarget, completion: {})
        }
        print("OldTarget変換終了")
    }
    
    /// 全ての旧FreeNoteを変換&FIrebaseから削除
    private func convertOldFreeNote() async {
        print("OldFreeNote変換開始")
        
        // Firebaseの旧FreeNoteを取得(取得完了を待つ)
        if let oldFreeNote = await firebaseManager.getOldFreeNote() {
            self.noteArray.append(self.convertToFreeNote(oldFreeNote: oldFreeNote))
            self.firebaseManager.deleteOldFreeNote(oldFreeNote: oldFreeNote, completion: {})
        }
        print("OldFreeNote変換終了")
    }
    
    /// 全ての旧ノートデータを変換&旧データをFIrebaseから削除
    private func convertOldNote() async {
        print("OldNote変換開始")
        
        // Firebaseの旧Noteを全取得(取得完了を待つ)
        let oldNoteArray: [Note_old] = await firebaseManager.getOldNote()
        for oldNote in oldNoteArray {
            let note = self.convertToNote(oldNote: oldNote)
            self.noteArray.append(note)
            self.firebaseManager.deleteOldNote(oldNote: oldNote, completion: {})
        }
        print("OldNote変換終了")
    }

    /// 天気文字列からWeather型に変換
    /// - Parameters:
    ///    - weather: 天気文字列
    /// - Returns: Weather型の天気
    private func convertToWeather(weather: String) -> Int {
        switch weather {
        case OldWeather.sunny.rawValue:
            return Weather.sunny.rawValue
        case OldWeather.cloudy.rawValue:
            return Weather.cloudy.rawValue
        case OldWeather.rainy.rawValue:
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
        let task = TaskData()
        task.title = oldTask.getTitle()
        task.cause = oldTask.getCause()
        task.order = oldTask.getOrder()
        task.isComplete = oldTask.getAchievement()
        task.isDeleted = oldTask.getIsDeleted()
        var taskArray: [TaskData] = []
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
        let note = Note(freeWithTitle: oldFreeNote.getTitle())
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

