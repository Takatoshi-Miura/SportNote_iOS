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
    private var taskID:Int = 0          // タスクID
    private var taskTitle:String = ""   // タイトル
    private var taskCause:String = ""   // 原因
    
    
    
    // タスクデータをセットするメソッド
    func setTaskData(_ taskTitle:String,_ taskCause:String) {
        self.taskTitle = taskTitle
        self.taskCause = taskCause
    }
    
    
    // Firebaseにデータを保存するメソッド
    func saveTaskData() {
        // Firebaseにアクセス
        let db = Firestore.firestore()
        db.collection("TaskData").document("\(self.taskID)").setData([
            "taskID"    : self.taskID,
            "taskTitle" : self.taskTitle,
            "taskCause" : self.taskCause
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    
}
