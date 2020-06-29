//
//  TaskData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
import Firebase

class TaskData {
    
    // 保持するデータ
    static var taskCount:Int = 0                // 課題の数
    private var taskID:Int = 0                  // 課題ID
    private var taskTitle:String = ""           // タイトル
    private var taskCause:String = ""           // 原因
    private var taskAchievement:Bool = false    // 解決済み：true, 未解決：false
    private var isDeleted:Bool = false          // 削除：true, 削除しない：false
    private var userID:String = ""              // ユーザーUID
    private var created_at:String = ""          // 作成日
    private var updated_at:String = ""          // 更新日
    
    // 課題データを格納する配列
    var taskDataArray = [TaskData]()
    
    
    // 課題データをセットするメソッド(データベースの課題用)
    func setDatabaseTaskData(_ taskID:Int,_ taskTitle:String,_ taskCause:String,_ taskAchievement:Bool,_ isDeleted:Bool,_ userID:String,_ created_at:String,_ updated_at:String) {
        self.taskID = taskID
        self.taskTitle = taskTitle
        self.taskCause = taskCause
        self.taskAchievement = taskAchievement
        self.isDeleted = isDeleted
        self.userID = userID
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    // テキストデータをセットするメソッド
    func setTextData(taskTitle:String,taskCause:String) {
        self.taskTitle = taskTitle
        self.taskCause = taskCause
    }
    
    // 非表示対象の課題にするメソッド
    func deleteTask() {
        self.isDeleted = true
    }
    
    // taskTitleのゲッター
    func getTaskTitle() -> String {
        return self.taskTitle
    }
    
    // taskCauseのゲッター
    func getTaskCouse() -> String {
        return self.taskCause
    }
    
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    
    // Firebaseにデータを保存するメソッド
    func saveTaskData() {
        // 課題IDは課題IDの最大値＋１で設定
        TaskData.taskCount += 1
        self.taskID = TaskData.taskCount
        
        // 現在時刻を取得
        self.created_at = getCurrentTime()
        self.updated_at = self.created_at
        
        // ユーザーUIDを取得
        self.userID = Auth.auth().currentUser!.uid
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        db.collection("TaskData").document("\(self.userID)_\(self.taskID)").setData([
            "taskID"         : self.taskID,
            "taskTitle"      : self.taskTitle,
            "taskCause"      : self.taskCause,
            "taskAchievement": self.taskAchievement,
            "isDeleted"      : self.isDeleted,
            "userID"         : self.userID,
            "created_at"     : self.created_at,
            "updated_at"     : self.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    // Firebaseの課題データを取得するメソッド
    func loadTaskData() {
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // ユーザーの課題データ取得
        // ログインユーザーの課題データで、かつisDeletedがfalseの課題を取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setDatabaseTaskData(taskDataCollection["taskID"] as! Int,
                                                         taskDataCollection["taskTitle"] as! String,
                                                         taskDataCollection["taskCause"] as! String,
                                                         taskDataCollection["taskAchievement"] as! Bool,
                                                         taskDataCollection["isDeleted"] as! Bool,
                                                         taskDataCollection["userID"] as! String,
                                                         taskDataCollection["created_at"] as! String,
                                                         taskDataCollection["updated_at"] as! String)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
                    
                    // 課題IDの重複対策
                    // データベースの課題IDの最大値を取得し、新規投稿時のIDは最大値＋１で設定
                    if databaseTaskData.taskID > TaskData.taskCount {
                        TaskData.taskCount = databaseTaskData.taskID
                    }
                }
            }
        }
    }
    
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData() {
        // 更新日時を現在時刻にする
        self.updated_at = getCurrentTime()
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let taskData = db.collection("TaskData").document("\(userID)_\(self.taskID)")

        // 変更する可能性のあるデータのみ更新
        taskData.updateData([
            "taskTitle"      : self.taskTitle,
            "taskCause"      : self.taskCause,
            "taskAchievement": self.taskAchievement,
            "isDeleted"      : self.isDeleted,
            "updated_at"     : self.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
}
