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
    private var deleteFlag:Bool = false         // 削除：true, 削除しない：false
    
    // 課題データを格納する配列
    var taskDataArray = [TaskData]()
    
    
    // 課題データをセットするメソッド
    func setTaskData(_ taskTitle:String,_ taskCause:String,_ taskAchievement:Bool,_ deleteFlag:Bool) {
        self.taskTitle = taskTitle
        self.taskCause = taskCause
        self.taskAchievement = taskAchievement
        self.deleteFlag = deleteFlag
    }
    
    // 課題IDをセットするメソッド(データベースの課題用)
    func setTaskID(_ taskID:Int) {
        self.taskID = taskID
    }
    
    // taskTitleのゲッター
    func getTaskTitle() -> String {
        return self.taskTitle
    }
    
    // taskCauseのゲッター
    func getTaskCouse() -> String {
        return self.taskCause
    }
    
    
    // Firebaseにデータを保存するメソッド
    func saveTaskData() {
        // 課題IDは課題IDの最大値＋１で設定
        TaskData.taskCount += 1
        self.taskID = TaskData.taskCount
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        db.collection("TaskData_\(userID)").document("\(self.taskID)").setData([
            "taskID"         : self.taskID,
            "taskTitle"      : self.taskTitle,
            "taskCause"      : self.taskCause,
            "taskAchievement": self.taskAchievement,
            "deleteFlag"     : self.deleteFlag
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    // Firebaseの課題データを取得するメソッド
    func loadDatabase() {
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // データ取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData_\(userID)").order(by: "taskID", descending: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 取得データ(画像以外)をコレクションに格納
                    // 画像はPostTableViewCellにて取得するため、ここでは取得しない。
                    let taskDataCollection = document.data()
                    //print("\(document.documentID) => \(taskDataCollection)")
                
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskData(taskDataCollection["taskTitle"] as! String,
                                                 taskDataCollection["taskCause"] as! String,
                                                 taskDataCollection["taskAchievement"] as! Bool,
                                                 taskDataCollection["deleteFlag"] as! Bool)
                    
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
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // 課題データにアクセス
        let db = Firestore.firestore()
        let taskData = db.collection("TaskData_\(userID)").document("\(self.taskID)")

        // データを更新
        taskData.updateData([
            "taskTitle"      : self.taskTitle,
            "taskCause"      : self.taskCause,
            "taskAchievement": self.taskAchievement,
            "deleteFlag"     : self.deleteFlag
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    
}
