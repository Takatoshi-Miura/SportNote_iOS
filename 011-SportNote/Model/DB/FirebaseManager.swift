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
    var targetArray = [Target]()
    var noteArray = [Note]()
    
    // MARK: - Create
    
    /// グループデータを保存
    /// - Parameters:
    ///   - group: グループデータ
    ///   - completion: 完了処理
    func saveGroup(group: Group, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Group").document("\(group.userID)_\(group.groupID)").setData([
            "userID"        : group.userID,
            "groupID"       : group.groupID,
            "title"         : group.title,
            "color"         : group.color,
            "order"         : group.order,
            "isDeleted"     : group.isDeleted,
            "created_at"    : group.created_at,
            "updated_at"    : group.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    /// 課題データを保存
    /// - Parameters:
    ///   - task: 課題データ
    ///   - completion: 完了処理
    func saveTask(task: Task, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Task").document("\(task.userID)_\(task.taskID)").setData([
            "userID"        : task.userID,
            "taskID"        : task.taskID,
            "groupID"       : task.groupID,
            "title"         : task.title,
            "cause"         : task.cause,
            "order"         : task.order,
            "isComplete"    : task.isComplete,
            "isDeleted"     : task.isDeleted,
            "created_at"    : task.created_at,
            "updated_at"    : task.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    /// 対策データを保存
    /// - Parameters:
    ///   - measures: 対策データ
    ///   - completion: 完了処理
    func saveMeasures(measures: Measures, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Measures").document("\(measures.userID)_\(measures.measuresID)").setData([
            "userID"        : measures.userID,
            "measuresID"    : measures.measuresID,
            "taskID"        : measures.taskID,
            "title"         : measures.title,
            "order"         : measures.order,
            "isDeleted"     : measures.isDeleted,
            "created_at"    : measures.created_at,
            "updated_at"    : measures.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    /// メモデータを保存
    /// - Parameters:
    ///   - memo: メモデータ
    ///   - completion: 完了処理
    func saveMemo(memo: Memo, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Memo").document("\(memo.userID)_\(memo.memoID)").setData([
            "userID"        : memo.userID,
            "memoID"        : memo.memoID,
            "noteID"        : memo.noteID,
            "measuresID"    : memo.measuresID,
            "detail"        : memo.detail,
            "isDeleted"     : memo.isDeleted,
            "created_at"    : memo.created_at,
            "updated_at"    : memo.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    /// 目標データを保存
    /// - Parameters:
    ///   - target: 目標データ
    ///   - completion: 完了処理
    func saveTarget(target: Target, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Target").document("\(target.userID)_\(target.targetID)").setData([
            "userID"        : target.userID,
            "targetID"      : target.targetID,
            "title"         : target.title,
            "year"          : target.year,
            "month"         : target.month,
            "isYearlyTarget": target.isYearlyTarget,
            "isDeleted"     : target.isDeleted,
            "created_at"    : target.created_at,
            "updated_at"    : target.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    /// ノート(フリー、練習、大会)を保存
    /// - Parameters:
    ///   - note: ノートデータ
    ///   - completion: 完了処理
    func saveNote(note: Note, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        db.collection("Note").document("\(note.userID)_\(note.noteID)").setData([
            "userID"        : note.userID,
            "noteID"        : note.noteID,
            "noteType"      : note.noteType,
            "isDeleted"     : note.isDeleted,
            "created_at"    : note.created_at,
            "updated_at"    : note.updated_at,
            "title"         : note.title,
            "date"          : note.date,
            "weather"       : note.weather,
            "temperature"   : note.temperature,
            "condition"     : note.condition,
            "reflection"    : note.reflection,
            "purpose"       : note.purpose,
            "detail"        : note.detail,
            "target"        : note.target,
            "consciousness" : note.consciousness,
            "result"        : note.result
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                completion()
            }
        }
    }
    
    
    // MARK: - Select
    
    /// グループを全取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getAllGroup(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Group")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { [self] (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.groupArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let group = Group()
                        group.userID = collection["userID"] as! String
                        group.groupID = collection["groupID"] as! String
                        group.title = collection["title"] as! String
                        group.color = collection["color"] as! Int
                        group.order = collection["order"] as! Int
                        group.isDeleted = collection["isDeleted"] as! Bool
                        group.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        group.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        self.groupArray.append(group)
                    }
                    completion()
                }
            }
    }
    
    /// 課題を全取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getAllTask(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Task")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.taskArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let task = Task()
                        task.userID = collection["userID"] as! String
                        task.taskID = collection["taskID"] as! String
                        task.groupID = collection["groupID"] as! String
                        task.title = collection["title"] as! String
                        task.cause = collection["cause"] as! String
                        task.order = collection["order"] as! Int
                        task.isComplete = collection["isComplete"] as! Bool
                        task.isDeleted = collection["isDeleted"] as! Bool
                        task.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        task.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        self.taskArray.append(task)
                    }
                    completion()
                }
            }
    }
    
    /// 対策を全取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getAllMeasures(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Measures")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.measuresArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let measures = Measures()
                        measures.userID = collection["userID"] as! String
                        measures.measuresID = collection["measuresID"] as! String
                        measures.taskID = collection["taskID"] as! String
                        measures.title = collection["title"] as! String
                        measures.order = collection["order"] as! Int
                        measures.isDeleted = collection["isDeleted"] as! Bool
                        measures.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        measures.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        self.measuresArray.append(measures)
                    }
                    completion()
                }
            }
    }
    
    /// メモを全取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getAllMemo(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Memo")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.memoArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let memo = Memo()
                        memo.userID = collection["userID"] as! String
                        memo.memoID = collection["memoID"] as! String
                        memo.noteID = collection["noteID"] as! String
                        memo.measuresID = collection["measuresID"] as! String
                        memo.detail = collection["detail"] as! String
                        memo.isDeleted = collection["isDeleted"] as! Bool
                        memo.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        memo.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        self.memoArray.append(memo)
                    }
                    completion()
                }
            }
    }
    
    /// 目標データを取得
    /// - Parameters:
    ///   - completion: 完了処理
    func getAllTarget(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Target")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.targetArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let target = Target()
                        target.userID = collection["userID"] as! String
                        target.targetID = collection["targetID"] as! String
                        target.title = collection["title"] as! String
                        target.year = collection["year"] as! Int
                        target.month = collection["month"] as! Int
                        target.isYearlyTarget = collection["isYearlyTarget"] as! Bool
                        target.isDeleted = collection["isDeleted"] as! Bool
                        target.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        target.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        self.targetArray.append(target)
                    }
                    completion()
                }
            }
    }
    
    /// ノート(フリー、練習、大会)を取得
    /// - Parameters:
    ///   - completion: 完了処理
    func getAllNote(completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("Note")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.noteArray = []
                    for document in querySnapshot!.documents {
                        let collection = document.data()
                        let note = Note()
                        note.userID = collection["userID"] as! String
                        note.noteID = collection["noteID"] as! String
                        note.noteType = collection["noteType"] as! Int
                        note.isDeleted = collection["isDeleted"] as! Bool
                        note.created_at = (collection["created_at"] as! Timestamp).dateValue()
                        note.updated_at = (collection["updated_at"] as! Timestamp).dateValue()
                        note.title = collection["title"] as! String
                        note.date = (collection["date"] as! Timestamp).dateValue()
                        note.weather = collection["weather"] as! Int
                        note.temperature = collection["temperature"] as! Int
                        note.condition = collection["condition"] as! String
                        note.reflection = collection["reflection"] as! String
                        note.purpose = collection["purpose"] as! String
                        note.detail = collection["detail"] as! String
                        note.target = collection["target"] as! String
                        note.consciousness = collection["consciousness"] as! String
                        note.result = collection["result"] as! String
                        self.noteArray.append(note)
                    }
                    completion()
                }
            }
    }
    
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
                    if querySnapshot!.documents.count == 0 {
                        // FreeNoteが存在しない場合
                        self.oldFreeNote.setUserID("FreeNoteIsEmpty")
                        completion()
                        return
                    }
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
    
    // MARK: - Update
    
    /// グループを更新
    /// - Parameters:
    ///   - group: グループデータ
    func updateGroup(group: Group) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let database = db.collection("Group").document("\(userID)_\(group.groupID)")
        database.updateData([
            "title"         : group.title,
            "color"         : group.color,
            "order"         : group.order,
            "isDeleted"     : group.isDeleted,
            "updated_at"    : group.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// 課題を更新
    /// - Parameters:
    ///   - task: 課題データ
    func updateTask(task: Task) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let database = db.collection("Task").document("\(userID)_\(task.taskID)")
        database.updateData([
            "groupID"       : task.groupID,
            "title"         : task.title,
            "cause"         : task.cause,
            "order"         : task.order,
            "isComplete"    : task.isComplete,
            "isDeleted"     : task.isDeleted,
            "updated_at"    : task.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// 対策を更新
    /// - Parameters:
    ///   - measures: 対策データ
    func updateMeasures(measures: Measures) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let database = db.collection("Measures").document("\(userID)_\(measures.measuresID)")
        database.updateData([
            "title"         : measures.title,
            "order"         : measures.order,
            "isDeleted"     : measures.isDeleted,
            "updated_at"    : measures.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// メモを更新
    /// - Parameters:
    ///   - memo: メモデータ
    func updateMemo(memo: Memo) {
        let db = Firestore.firestore()
        let database = db.collection("Memo").document("\(memo.userID)_\(memo.memoID)")
        database.updateData([
            "detail"        : memo.detail,
            "isDeleted"     : memo.isDeleted,
            "updated_at"    : memo.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// 目標を更新
    /// - Parameters:
    ///   - target: 目標
    func updateTarget(target: Target) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let database = db.collection("Target").document("\(userID)_\(target.targetID)")
        database.updateData([
            "title"         : target.title,
            "year"          : target.year,
            "month"         : target.month,
            "isYearlyTarget": target.isYearlyTarget,
            "isDeleted"     : target.isDeleted,
            "updated_at"    : target.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// ノート(フリー、練習、大会)を更新
    /// - Parameters:
    ///   - note: ノート
    func updateNote(note: Note) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        let database = db.collection("Note").document("\(userID)_\(note.noteID)")
        database.updateData([
            "isDeleted"     : note.isDeleted,
            "updated_at"    : note.updated_at,
            "title"         : note.title,
            "date"          : note.date,
            "weather"       : note.weather,
            "temperature"   : note.temperature,
            "condition"     : note.condition,
            "reflection"    : note.reflection,
            "purpose"       : note.purpose,
            "detail"        : note.detail,
            "target"        : note.target,
            "consciousness" : note.consciousness,
            "result"        : note.result
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
            }
        }
    }
    
    /// 旧課題を更新(削除用)
    /// - Parameters:
    ///   - oldTask: 旧課題
    ///   - completion: 完了処理
    func deleteOldTask(oldTask: Task_old, completion: @escaping () -> ()) {
        oldTask.setIsDeleted(true)
        oldTask.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(oldTask.getUserID())_\(oldTask.getTaskID())")
        database.updateData([
            "taskTitle"        : oldTask.getTitle(),
            "taskCause"        : oldTask.getCause(),
            "order"            : oldTask.getOrder(),
            "taskAchievement"  : oldTask.getAchievement(),
            "isDeleted"        : oldTask.getIsDeleted(),
            "updated_at"       : oldTask.getUpdated_at(),
            "measuresData"     : oldTask.getMeasuresData(),
            "measuresPriority" : oldTask.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully deleted")
                // 完了処理
                completion()
            }
        }
    }
    
    /// 旧目標を更新(削除用)
    /// - Parameters:
    ///   - oldTarget: 旧目標
    ///   - completion: 完了処理
    func deleteOldTarget(oldTarget: Target_old, completion: @escaping () -> ()) {
        oldTarget.setIsDeleted(true)
        oldTarget.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let data = db.collection("TargetData").document("\(oldTarget.getUserID())_\(oldTarget.getYear())_\(oldTarget.getMonth())")
        data.updateData([
            "detail"     : oldTarget.getDetail(),
            "isDeleted"  : oldTarget.getIsDeleted(),
            "updated_at" : oldTarget.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully deleted")
                // 完了処理
                completion()
            }
        }
    }
    
    /// 旧フリーノートを更新(削除用)
    /// - Parameters:
    ///   - oldFreeNote: 旧フリーノート
    ///   - completion: 完了処理
    func deleteOldFreeNote(oldFreeNote: FreeNote_old, completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let data = db.collection("FreeNoteData").document("\(oldFreeNote.getUserID())")
        data.delete()
        completion()
    }
    
    /// 旧ノートを更新(削除用)
    /// - Parameters:
    ///   - oldNote: 旧ノート
    ///   - completion: 完了処理
    func deleteOldNote(oldNote: Note_old, completion: @escaping () -> ()) {
        // 削除フラグを更新
        oldNote.setIsDeleted(true)
        oldNote.setUpdated_at(getCurrentTime())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        let data = db.collection("NoteData").document("\(oldNote.getUserID())_\(oldNote.getNoteID())")
        data.updateData([
            "year"                  : oldNote.getYear(),
            "month"                 : oldNote.getMonth(),
            "date"                  : oldNote.getDate(),
            "day"                   : oldNote.getDay(),
            "weather"               : oldNote.getWeather(),
            "temperature"           : oldNote.getTemperature(),
            "physicalCondition"     : oldNote.getPhysicalCondition(),
            "purpose"               : oldNote.getPurpose(),
            "detail"                : oldNote.getDetail(),
            "target"                : oldNote.getTarget(),
            "consciousness"         : oldNote.getConsciousness(),
            "result"                : oldNote.getResult(),
            "reflection"            : oldNote.getReflection(),
            "taskTitle"             : oldNote.getTaskTitle(),
            "measuresTitle"         : oldNote.getMeasuresTitle(),
            "measuresEffectiveness" : oldNote.getMeasuresEffectiveness(),
            "isDeleted"             : oldNote.getIsDeleted(),
            "updated_at"            : oldNote.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully deleted")
                // 完了処理
                completion()
            }
        }
    }
    
}

