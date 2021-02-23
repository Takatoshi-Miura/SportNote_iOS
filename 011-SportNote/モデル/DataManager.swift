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
    
    var noteDataArray = [NoteData]()
    var freeNoteArray = [FreeNote]()
    var taskDataArray = [TaskData]()
    var targetDataArray = [TargetData]()
    
    
    //MARK:- ノートデータ
    
    
    //MARK:- フリーノートデータ
    
    
    //MARK:- 課題データ
    
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
                    let taskDataCollection = document.data()
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                    databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                    databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                    databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                    databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                    databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                    databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                    databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                    databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
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
                        let taskDataCollection = document.data()
                        let databaseTaskData = TaskData()
                        databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                        databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                        databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                        databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                        databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                        databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                        databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                        databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                        databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                        databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                        // 課題データを格納
                        self.taskDataArray.append(databaseTaskData)
                    }
                    // HUDで処理中を非表示
                    SVProgressHUD.dismiss()
                    // 完了処理
                    completion()
                }
            }
    }
    
    /**
     課題データをを更新
     - Parameters:
      - task: 更新したいTaskData
      - completion: 処理完了後に実行する処理
     */
    func updateTaskData(task taskData:TaskData, _ completion: @escaping () -> ()) {
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
            "taskTitle"        : taskData.getTaskTitle(),
            "taskCause"        : taskData.getTaskCouse(),
            "taskAchievement"  : taskData.getTaskAchievement(),
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
    // Firebaseにデータを保存するメソッド
    func saveTaskData(title:String, cause:String, measuresTitleArray:[String], _ completion: @escaping () -> ()) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDをセット
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let taskData = TaskData()
        taskData.setUserID(userID)
        
        // 入力されたテキストをTaskDataにセット
        taskData.setTaskTitle(title)
        taskData.setTaskCause(cause)
        
        // 現在時刻をセット
        taskData.setCreated_at(self.getCurrentTime())
        taskData.setUpdated_at(taskData.getCreated_at())
        
        // TODO: 最有力の対策を設定するコード
    
        // 対策をセット
        for measuresTitle in measuresTitleArray {
            taskData.addMeasures(title: measuresTitle,effectiveness: "課題データに追記したノートデータ")
        }
        
        // taskIDの設定
        taskData.setNewTaskID({
            // 課題データを保存
            let db = Firestore.firestore()
            db.collection("TaskData").document("\(userID)_\(taskData.getTaskID())").setData([
                "taskID"           : taskData.getTaskID(),
                "taskTitle"        : taskData.getTaskTitle(),
                "taskCause"        : taskData.getTaskCouse(),
                "taskAchievement"  : taskData.getTaskAchievement(),
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
                    print("Document successfully written!")
                    // HUDで処理中を非表示
                    SVProgressHUD.dismiss()
                    // 完了処理
                    completion()
                }
            }
        })
    }
    
    
    //MARK:- 目標データ
    
    
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
