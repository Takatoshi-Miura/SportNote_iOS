//
//  DataManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/02/23.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class DataManager {
    
    //MARK:- データ配列
    
    var noteDataArray = [Note_old]()
    var freeNoteData = FreeNote_old()
    var taskDataArray = [Task_old]()
    var targetDataArray = [Target_old]()
    
    
    //MARK:- ノートデータ
    
    /**
     ノートデータを取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getNoteData(_ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "ノート情報を取得しています。")
        
        // 配列の初期化
        noteDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
        db.collection("NoteData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .order(by: "date", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標データを反映
                    let dataCollection = document.data()
                    let noteData = Note_old()
                    noteData.setNoteID(dataCollection["noteID"] as! Int)
                    noteData.setNoteType(dataCollection["noteType"] as! String)
                    noteData.setYear(dataCollection["year"] as! Int)
                    noteData.setMonth(dataCollection["month"] as! Int)
                    noteData.setDate(dataCollection["date"] as! Int)
                    noteData.setDay(dataCollection["day"] as! String)
                    noteData.setWeather(dataCollection["weather"] as! String)
                    noteData.setTemperature(dataCollection["temperature"] as! Int)
                    noteData.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    noteData.setPurpose(dataCollection["purpose"] as! String)
                    noteData.setDetail(dataCollection["detail"] as! String)
                    noteData.setTarget(dataCollection["target"] as! String)
                    noteData.setConsciousness(dataCollection["consciousness"] as! String)
                    noteData.setResult(dataCollection["result"] as! String)
                    noteData.setReflection(dataCollection["reflection"] as! String)
                    noteData.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    noteData.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    noteData.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    noteData.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    noteData.setUserID(dataCollection["userID"] as! String)
                    noteData.setCreated_at(dataCollection["created_at"] as! String)
                    noteData.setUpdated_at(dataCollection["updated_at"] as! String)
                    // ノートデータを格納
                    self.noteDataArray.append(noteData)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを取得(ID指定)
     - Parameters:
      - noteID: ノートID
      - completion: データ取得後に実行する処理
     */
    func getNoteData(_ noteID:Int, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "ノート情報を取得しています。")
        
        // 配列の初期化
        noteDataArray = []
        
        // ユーザーIDを取得
        let noteData = Note_old()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
        db.collection("NoteData")
            .whereField("userID", isEqualTo: userID)
            .whereField("noteID", isEqualTo: noteID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標データを反映
                    let dataCollection = document.data()
                    noteData.setNoteID(dataCollection["noteID"] as! Int)
                    noteData.setNoteType(dataCollection["noteType"] as! String)
                    noteData.setYear(dataCollection["year"] as! Int)
                    noteData.setMonth(dataCollection["month"] as! Int)
                    noteData.setDate(dataCollection["date"] as! Int)
                    noteData.setDay(dataCollection["day"] as! String)
                    noteData.setWeather(dataCollection["weather"] as! String)
                    noteData.setTemperature(dataCollection["temperature"] as! Int)
                    noteData.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    noteData.setPurpose(dataCollection["purpose"] as! String)
                    noteData.setDetail(dataCollection["detail"] as! String)
                    noteData.setTarget(dataCollection["target"] as! String)
                    noteData.setConsciousness(dataCollection["consciousness"] as! String)
                    noteData.setResult(dataCollection["result"] as! String)
                    noteData.setReflection(dataCollection["reflection"] as! String)
                    noteData.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    noteData.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    noteData.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    noteData.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    noteData.setUserID(dataCollection["userID"] as! String)
                    noteData.setCreated_at(dataCollection["created_at"] as! String)
                    noteData.setUpdated_at(dataCollection["updated_at"] as! String)
                    // ノートデータを格納
                    self.noteDataArray.append(noteData)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを取得(日付指定)
     - Parameters:
      - year:  年
      - month: 月
      - date:  日
      - completion: データ取得後に実行する処理
     */
    func getNoteData(_ year:Int, _ month:Int, _ date:Int, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show(withStatus: "ノート情報を取得しています。")
        
        // 配列の初期化
        noteDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
        db.collection("NoteData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("year", isEqualTo: year)
            .whereField("month", isEqualTo: month)
            .whereField("date", isEqualTo: date)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // オブジェクトを作成
                    let noteData = Note_old()
                    
                    // 目標データを反映
                    let dataCollection = document.data()
                    noteData.setNoteID(dataCollection["noteID"] as! Int)
                    noteData.setNoteType(dataCollection["noteType"] as! String)
                    noteData.setYear(dataCollection["year"] as! Int)
                    noteData.setMonth(dataCollection["month"] as! Int)
                    noteData.setDate(dataCollection["date"] as! Int)
                    noteData.setDay(dataCollection["day"] as! String)
                    noteData.setWeather(dataCollection["weather"] as! String)
                    noteData.setTemperature(dataCollection["temperature"] as! Int)
                    noteData.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    noteData.setPurpose(dataCollection["purpose"] as! String)
                    noteData.setDetail(dataCollection["detail"] as! String)
                    noteData.setTarget(dataCollection["target"] as! String)
                    noteData.setConsciousness(dataCollection["consciousness"] as! String)
                    noteData.setResult(dataCollection["result"] as! String)
                    noteData.setReflection(dataCollection["reflection"] as! String)
                    noteData.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    noteData.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    noteData.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    noteData.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    noteData.setUserID(dataCollection["userID"] as! String)
                    noteData.setCreated_at(dataCollection["created_at"] as! String)
                    noteData.setUpdated_at(dataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.noteDataArray.append(noteData)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを更新
     - Parameters:
      - noteData: 更新したいノート
      - completion: データ取得後に実行する処理
     */
    func updateNoteData(_ noteData:Note_old, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 更新日時に現在時刻をセット
        noteData.setUpdated_at(getCurrentTime())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        let data = db.collection("NoteData").document("\(noteData.getUserID())_\(noteData.getNoteID())")
        data.updateData([
            "year"                  : noteData.getYear(),
            "month"                 : noteData.getMonth(),
            "date"                  : noteData.getDate(),
            "day"                   : noteData.getDay(),
            "weather"               : noteData.getWeather(),
            "temperature"           : noteData.getTemperature(),
            "physicalCondition"     : noteData.getPhysicalCondition(),
            "purpose"               : noteData.getPurpose(),
            "detail"                : noteData.getDetail(),
            "target"                : noteData.getTarget(),
            "consciousness"         : noteData.getConsciousness(),
            "result"                : noteData.getResult(),
            "reflection"            : noteData.getReflection(),
            "taskTitle"             : noteData.getTaskTitle(),
            "measuresTitle"         : noteData.getMeasuresTitle(),
            "measuresEffectiveness" : noteData.getMeasuresEffectiveness(),
            "isDeleted"             : noteData.getIsDeleted(),
            "updated_at"            : noteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("ノート(ID:\(noteData.getNoteID()))を更新しました")
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを保存
     - Parameters:
      - noteData: 保存したいノート
      - completion: データ取得後に実行する処理
     */
    func saveNoteData(_ noteData:Note_old, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーUIDをセット
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        noteData.setUserID(userID)
        
        // 日時に現在時刻をセット
        noteData.setUpdated_at(getCurrentTime())
        noteData.setCreated_at(getCurrentTime())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(noteData.getUserID())_\(noteData.getNoteID())").setData([
            "noteID"                : noteData.getNoteID(),
            "noteType"              : noteData.getNoteType(),
            "year"                  : noteData.getYear(),
            "month"                 : noteData.getMonth(),
            "date"                  : noteData.getDate(),
            "day"                   : noteData.getDay(),
            "weather"               : noteData.getWeather(),
            "temperature"           : noteData.getTemperature(),
            "physicalCondition"     : noteData.getPhysicalCondition(),
            "purpose"               : noteData.getPurpose(),
            "detail"                : noteData.getDetail(),
            "target"                : noteData.getTarget(),
            "consciousness"         : noteData.getConsciousness(),
            "result"                : noteData.getResult(),
            "reflection"            : noteData.getReflection(),
            "taskTitle"             : noteData.getTaskTitle(),
            "measuresTitle"         : noteData.getMeasuresTitle(),
            "measuresEffectiveness" : noteData.getMeasuresEffectiveness(),
            "isDeleted"             : noteData.getIsDeleted(),
            "userID"                : noteData.getUserID(),
            "created_at"            : noteData.getCreated_at(),
            "updated_at"            : noteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("ノート(ID:\(noteData.getNoteID()))を保存しました")
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを保存(複製する際に使用)
     - Parameters:
      - noteData: 保存したいノート
      - completion: データ取得後に実行する処理
     */
    func copyNoteData(_ noteData:Note_old, _ completion: @escaping () -> ()) {
        // ユーザーUIDをセット
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        noteData.setUserID(userID)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(noteData.getUserID())_\(noteData.getNoteID())").setData([
            "noteID"                : noteData.getNoteID(),
            "noteType"              : noteData.getNoteType(),
            "year"                  : noteData.getYear(),
            "month"                 : noteData.getMonth(),
            "date"                  : noteData.getDate(),
            "day"                   : noteData.getDay(),
            "weather"               : noteData.getWeather(),
            "temperature"           : noteData.getTemperature(),
            "physicalCondition"     : noteData.getPhysicalCondition(),
            "purpose"               : noteData.getPurpose(),
            "detail"                : noteData.getDetail(),
            "target"                : noteData.getTarget(),
            "consciousness"         : noteData.getConsciousness(),
            "result"                : noteData.getResult(),
            "reflection"            : noteData.getReflection(),
            "taskTitle"             : noteData.getTaskTitle(),
            "measuresTitle"         : noteData.getMeasuresTitle(),
            "measuresEffectiveness" : noteData.getMeasuresEffectiveness(),
            "isDeleted"             : noteData.getIsDeleted(),
            "userID"                : noteData.getUserID(),
            "created_at"            : noteData.getCreated_at(),
            "updated_at"            : noteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("ノート(ID:\(noteData.getNoteID()))を保存しました")
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     ノートデータを削除
     - Parameters:
      - noteData: 削除したいノート
      - completion: データ取得後に実行する処理
     */
    func deleteNoteData(_ noteData:Note_old, _ completion: @escaping () -> ()) {
        // isDeletedをセット
        noteData.setIsDeleted(true)
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let data = db.collection("NoteData").document("\(userID)_\(noteData.getNoteID())")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "isDeleted"  : true,
            "updated_at" : getCurrentTime()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("ノート(ID:\(noteData.getNoteID()))を削除しました")
                // 完了処理
                completion()
            }
        }
    }
    
    
    //MARK:- フリーノートデータ
    
    /**
     フリーノートデータを新規作成(初回のみ実行)
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func createFreeNoteData(_ completion: @escaping () -> ()) {
        // ユーザーUIDをセット
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        freeNoteData.setUserID(userID)
        
        // 現在時刻をセット
        freeNoteData.setCreated_at(getCurrentTime())
        freeNoteData.setUpdated_at(freeNoteData.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("FreeNoteData").document("\(freeNoteData.getUserID())").setData([
            "title"      : freeNoteData.getTitle(),
            "detail"     : freeNoteData.getDetail(),
            "userID"     : freeNoteData.getUserID(),
            "created_at" : freeNoteData.getCreated_at(),
            "updated_at" : freeNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("フリーノートを作成しました")
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     フリーノートデータを取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getFreeNoteData(_ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 現在のユーザーのフリーノートデータを取得する
        let db = Firestore.firestore()
        db.collection("FreeNoteData")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // フリーノートデータを反映
                    let freeNoteDataCollection = document.data()
                    self.freeNoteData.setTitle(freeNoteDataCollection["title"] as! String)
                    self.freeNoteData.setDetail(freeNoteDataCollection["detail"] as! String)
                    self.freeNoteData.setUserID(freeNoteDataCollection["userID"] as! String)
                    self.freeNoteData.setCreated_at(freeNoteDataCollection["created_at"] as! String)
                    self.freeNoteData.setUpdated_at(freeNoteDataCollection["updated_at"] as! String)
                }
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     フリーノートデータを更新
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func updateFreeNoteData(_ title:String, _ detail:String, _ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // テキストデータをセット
        freeNoteData.setTitle(title)
        freeNoteData.setDetail(detail)
        
        // 更新日時を現在時刻にする
        freeNoteData.setUpdated_at(getCurrentTime())
        
        // 更新したいデータを取得
        let db = Firestore.firestore()
        let data = db.collection("FreeNoteData").document("\(userID)")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "title"      : freeNoteData.getTitle(),
            "detail"     : freeNoteData.getDetail(),
            "updated_at" : freeNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("フリーノート(タイトル:\(self.freeNoteData.getTitle()))を更新しました")
                // 完了処理
                completion()
            }
        }
    }
    
    
    //MARK:- 課題データ
    
    /**
     全ての課題を取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getAllTaskData(_ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // データ取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)            // ログインユーザのデータ
            .whereField("isDeleted", isEqualTo: false)          // 削除されていない
            .order(by: "taskID", descending: true)              // 古い課題を下、新しい課題を上に表示させる
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 取得データを基に、課題データを作成
                    let taskCollection = document.data()
                    let databaseTask = self.createTaskFromCollection(taskCollection)
                    self.taskDataArray.append(databaseTask)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     未解決の課題を取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getUnresolvedTaskData(_ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // データ取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)            // ログインユーザのデータ
            .whereField("isDeleted", isEqualTo: false)          // 削除されていない
            .whereField("taskAchievement", isEqualTo: false)    // 未解決の課題
            .order(by: "taskID", descending: true)              // 古い課題を下、新しい課題を上に表示させる
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 取得データを基に、課題データを作成
                    let taskCollection = document.data()
                    let databaseTask = self.createTaskFromCollection(taskCollection)
                    self.taskDataArray.append(databaseTask)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     解決済みの課題を取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getResolvedTaskData(_ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // データ取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)            // ログインユーザのデータ
            .whereField("isDeleted", isEqualTo: false)          // 削除されていない
            .whereField("taskAchievement", isEqualTo: true)     // 解決済みの課題
            .order(by: "taskID", descending: true)              // 古い課題を下、新しい課題を上に表示させる
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        // 取得データを基に、課題データを作成
                        let taskCollection = document.data()
                        let databaseTask = self.createTaskFromCollection(taskCollection)
                        self.taskDataArray.append(databaseTask)
                    }
                    // HUDで処理中を非表示
                    SVProgressHUD.dismiss()
                    // 完了処理
                    completion()
                }
            }
    }
    
    /**
     DBからの取得データから課題データを作成
     - Parameters:
      - documents: querySnapshot!.documents
     - Returns: 課題データ
     */
    func createTaskFromCollection(_ taskCollection: [String: Any]) -> Task_old {
        let databaseTask = Task_old()
        
        databaseTask.setTaskID(taskCollection["taskID"] as! Int)
        databaseTask.setTitle(taskCollection["taskTitle"] as! String)
        databaseTask.setCause(taskCollection["taskCause"] as! String)
        let order: Int? = taskCollection["order"] as? Int
        if let order = order {
            databaseTask.setOrder(order)
        }
        databaseTask.setAchievement(taskCollection["taskAchievement"] as! Bool)
        databaseTask.setIsDeleted(taskCollection["isDeleted"] as! Bool)
        databaseTask.setUserID(taskCollection["userID"] as! String)
        databaseTask.setCreated_at(taskCollection["created_at"] as! String)
        databaseTask.setUpdated_at(taskCollection["updated_at"] as! String)
        databaseTask.setMeasuresData(taskCollection["measuresData"] as! [String:[[String:Int]]])
        databaseTask.setMeasuresPriority(taskCollection["measuresPriority"] as! String)
        
        return databaseTask
    }
    
    /**
     課題データを更新
     - Parameters:
      - task: 更新したいTask
      - completion: 処理完了後に実行する処理
     */
    func updateTaskData(_ taskData:Task_old, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新日時を現在時刻にする
        taskData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(userID)_\(taskData.getTaskID())")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "taskTitle"        : taskData.getTitle(),
            "taskCause"        : taskData.getCause(),
            "order"            : taskData.getOrder(),
            "taskAchievement"  : taskData.getAchievement(),
            "isDeleted"        : taskData.getIsDeleted(),
            "updated_at"       : taskData.getUpdated_at(),
            "measuresData"     : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     課題データを保存
     - Parameters:
      - title: タイトル
      - cause: 原因
      - completion: 処理完了後に実行する処理
     */
    func saveTaskData(title:String,
                      cause:String,
                      measuresTitleArray:[String],
                      measuresPriority:String,
                      _ completion: @escaping () -> ())
    {
        // ユーザーIDをセット
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let taskData = Task_old()
        taskData.setUserID(userID)
        
        // 入力されたテキストをTaskDataにセット
        taskData.setTitle(title)
        taskData.setCause(cause)
        
        // 現在時刻をセット
        taskData.setCreated_at(self.getCurrentTime())
        taskData.setUpdated_at(taskData.getCreated_at())
        
        // 最有力の対策を設定
        taskData.setMeasuresPriority(measuresPriority)
    
        // 対策をセット
        for measuresTitle in measuresTitleArray {
            taskData.addMeasures(title: measuresTitle,effectiveness: "連動したノートが表示されます")
        }
        
        // taskIDの設定
        taskData.setNewTaskID({
            self.saveTask(taskData, completion)
        })
    }
    
    /**
     課題データを保存(複製する際に使用)
     - Parameters:
      - taskData: 保存したいTask
      - completion: 処理完了後に実行する処理
     */
    func copyTaskData(_ taskData:Task_old, _ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        taskData.setUserID(userID)
        
        // 課題データを保存
        self.saveTask(taskData, completion)
    }
    
    /**
     課題データを保存
     - Parameters:
      - taskData: 保存したいTask
      - completion: 処理完了後に実行する処理
     */
    func saveTask(_ taskData: Task_old, _ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("TaskData").document("\(taskData.getUserID())_\(taskData.getTaskID())").setData([
            "taskID"           : taskData.getTaskID(),
            "taskTitle"        : taskData.getTitle(),
            "taskCause"        : taskData.getCause(),
            "order"            : taskData.getOrder(),
            "taskAchievement"  : taskData.getAchievement(),
            "isDeleted"        : taskData.getIsDeleted(),
            "userID"           : taskData.getUserID(),
            "created_at"       : taskData.getCreated_at(),
            "updated_at"       : taskData.getUpdated_at(),
            "measuresData"     : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("課題データ(ID:\(taskData.getTaskID()))を保存しました")
                completion()
            }
        }
    }
    
    /**
     現在の課題の並び順をorderに反映
     */
    func setTaskOrder() {
        var index: Int = 0
        for task in self.taskDataArray {
            task.setOrder(index)
            index += 1
        }
    }
    
    /**
     保存されたorderの昇順で課題を並び替える
     */
    func sortTaskByOrder() {
        self.taskDataArray.sort(by: {$0.getOrder() < $1.getOrder()})
    }
    
    
    //MARK:- 目標データ
    
    /**
     目標データを取得
     - Parameters:
      - completion: データ取得後に実行する処理
     */
    func getTargetData(_ completion: @escaping () -> ()) {
        // targetDataArrayを初期化
        targetDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーの目標データを取得する
        let db = Firestore.firestore()
        db.collection("TargetData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標データを反映
                    let targetDataCollection = document.data()
                    let target = Target_old()
                    target.setYear(targetDataCollection["year"] as! Int)
                    target.setMonth(targetDataCollection["month"] as! Int)
                    target.setDetail(targetDataCollection["detail"] as! String)
                    target.setIsDeleted(targetDataCollection["isDeleted"] as! Bool)
                    target.setUserID(targetDataCollection["userID"] as! String)
                    target.setCreated_at(targetDataCollection["created_at"] as! String)
                    target.setUpdated_at(targetDataCollection["updated_at"] as! String)
                    // 取得データを格納
                    self.targetDataArray.append(target)
                }
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     目標データを更新
     - Parameters:
      - targetData: 目標データ
      - completion: データ取得後に実行する処理
     */
    func updateTargetData(_ targetData:Target_old, _ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新日時を現在時刻にする
        targetData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let data = db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     目標データを保存（新規目標追加時のみ使用）
     - Parameters:
      - year:  年
      - month: 月
      - date:  日
      - completion: データ取得後に実行する処理
     */
    func saveTargetData(_ year:Int, _ month:Int, _ detail:String, _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 目標データを作成
        let targetData = Target_old()
        targetData.setYear(year)
        targetData.setMonth(month)
        targetData.setDetail(detail)
        targetData.setUserID(userID)
        targetData.setCreated_at(getCurrentTime())
        targetData.setUpdated_at(targetData.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())").setData([
            "year"       : targetData.getYear(),
            "month"      : targetData.getMonth(),
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "userID"     : targetData.getUserID(),
            "created_at" : targetData.getCreated_at(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("目標データを保存しました")
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                // 完了処理
                completion()
            }
        }
    }
    
    /**
     目標データを保存（複製する際に使用）
     - Parameters:
      - targetData: 保存したい目標データ
      - completion: データ取得後に実行する処理
     */
    func copyTargetData(_ targetData:Target_old, _ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        targetData.setUserID(userID)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())").setData([
            "year"       : targetData.getYear(),
            "month"      : targetData.getMonth(),
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "userID"     : targetData.getUserID(),
            "created_at" : targetData.getCreated_at(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("目標データを保存しました")
                // 完了処理
                completion()
            }
        }
    }
    
    
    //MARK:- その他
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    
}
