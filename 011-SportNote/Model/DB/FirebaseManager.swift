//
//  FirebaseManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Firebase

class FirebaseManager {
    
    // MARK: - Variable
    
    // 旧データ(Firebaseにのみ存在)
    var oldTaskArray = [Task_old]()
    var oldTargetArray = [Target_old]()
    var oldFreeNote = FreeNote_old()
    var oldNoteArray = [Note_old]()
    
    // 新データ
    var groupArray = [Group]()
    var taskArray = [Task]()
    var measuresArray = [Measures]()
    var memoArray = [Memo]()
    var freeNote = FreeNote()
    var practiceNoteArray = [PracticeNote]()
    var tournamentNoteArray = [TournamentNote]()
    
    // MARK: - Create
    
    
    
    

    // MARK: - Select
    
    /// 旧課題データを取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getOldTask(_ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.oldTaskArray = []
                for document in querySnapshot!.documents {
                    let taskCollection = document.data()
                    let task = Task_old()
                    task.setTaskID(taskCollection["taskID"] as! Int)
                    task.setTitle(taskCollection["taskTitle"] as! String)
                    task.setCause(taskCollection["taskCause"] as! String)
                    task.setAchievement(taskCollection["taskAchievement"] as! Bool)
                    task.setIsDeleted(taskCollection["isDeleted"] as! Bool)
                    task.setUserID(taskCollection["userID"] as! String)
                    task.setCreated_at(taskCollection["created_at"] as! String)
                    task.setUpdated_at(taskCollection["updated_at"] as! String)
                    task.setMeasuresData(taskCollection["measuresData"] as! [String:[[String:Int]]])
                    task.setMeasuresPriority(taskCollection["measuresPriority"] as! String)
                    if let order = taskCollection["order"] as? Int {
                        task.setOrder(order)
                    }
                    self.oldTaskArray.append(task)
                }
                // 完了処理
                completion()
            }
        }
    }
    
    /// 旧目標データを取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getOldTarget(_ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("TargetData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.oldTargetArray = []
                for document in querySnapshot!.documents {
                    let targetDataCollection = document.data()
                    let target = Target_old()
                    target.setYear(targetDataCollection["year"] as! Int)
                    target.setMonth(targetDataCollection["month"] as! Int)
                    target.setDetail(targetDataCollection["detail"] as! String)
                    target.setIsDeleted(targetDataCollection["isDeleted"] as! Bool)
                    target.setUserID(targetDataCollection["userID"] as! String)
                    target.setCreated_at(targetDataCollection["created_at"] as! String)
                    target.setUpdated_at(targetDataCollection["updated_at"] as! String)
                    self.oldTargetArray.append(target)
                }
                // 完了処理
                completion()
            }
        }
    }
    
    /// 旧フリーノートデータを取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getOldFreeNote(_ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("FreeNoteData")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.oldFreeNote = FreeNote_old()
                for document in querySnapshot!.documents {
                    let freeNoteDataCollection = document.data()
                    self.oldFreeNote.setTitle(freeNoteDataCollection["title"] as! String)
                    self.oldFreeNote.setDetail(freeNoteDataCollection["detail"] as! String)
                    self.oldFreeNote.setUserID(freeNoteDataCollection["userID"] as! String)
                    self.oldFreeNote.setCreated_at(freeNoteDataCollection["created_at"] as! String)
                    self.oldFreeNote.setUpdated_at(freeNoteDataCollection["updated_at"] as! String)
                }
                // 完了処理
                completion()
            }
        }
    }
    
    /// 旧ノートデータを取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getOldNote(_ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
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
                self.oldNoteArray = []
                for document in querySnapshot!.documents {
                    let dataCollection = document.data()
                    let note = Note_old()
                    note.setNoteID(dataCollection["noteID"] as! Int)
                    note.setNoteType(dataCollection["noteType"] as! String)
                    note.setYear(dataCollection["year"] as! Int)
                    note.setMonth(dataCollection["month"] as! Int)
                    note.setDate(dataCollection["date"] as! Int)
                    note.setDay(dataCollection["day"] as! String)
                    note.setWeather(dataCollection["weather"] as! String)
                    note.setTemperature(dataCollection["temperature"] as! Int)
                    note.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    note.setPurpose(dataCollection["purpose"] as! String)
                    note.setDetail(dataCollection["detail"] as! String)
                    note.setTarget(dataCollection["target"] as! String)
                    note.setConsciousness(dataCollection["consciousness"] as! String)
                    note.setResult(dataCollection["result"] as! String)
                    note.setReflection(dataCollection["reflection"] as! String)
                    note.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    note.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    note.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    note.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    note.setUserID(dataCollection["userID"] as! String)
                    note.setCreated_at(dataCollection["created_at"] as! String)
                    note.setUpdated_at(dataCollection["updated_at"] as! String)
                    self.oldNoteArray.append(note)
                }
                // 完了処理
                completion()
            }
        }
    }

}

