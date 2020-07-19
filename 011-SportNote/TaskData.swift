//
//  TaskData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
import Firebase

class TaskData {
    
    //MARK:- 保持データ
    static var taskCount:Int = 0                // 課題の数
    private var taskID:Int = 0                  // 課題ID
    private var taskTitle:String = ""           // タイトル
    private var taskCause:String = ""           // 原因
    private var taskAchievement:Bool = false    // 解決済み：true, 未解決：false
    private var isDeleted:Bool = false          // 削除：true, 削除しない：false
    private var userID:String = ""              // ユーザーUID
    private var created_at:String = ""          // 作成日
    private var updated_at:String = ""          // 更新日
    private var measuresData:[String:[[String:Int]]] = [:]   // [対策タイトル,[ [対策の有効性コメント：ノートID],[対策の有効性コメント：ノートID] ] ]
    private var measuresPriorityIndex:Int = 0                // 最優先の対策が格納されているIndex
    
    // 課題データを格納する配列
    var taskDataArray = [TaskData]()
    
    
    
    //MARK:- セッター
    
    func setTaskID(_ taskID:Int) {
        self.taskID = taskID
    }
    
    func setTaskTitle(_ taskTitle:String) {
        self.taskTitle = taskTitle
    }
    
    func setTaskCause(_ taskCause:String) {
        self.taskCause = taskCause
    }
    
    func setTaskAchievement(_ taskAchievement:Bool) {
        self.taskAchievement = taskAchievement
    }
    
    func setIsDeleted(_ isDeleted:Bool) {
        self.isDeleted = isDeleted
    }
    
    func setUserID(_ userID:String) {
        self.userID = userID
    }
    
    func setCreated_at(_ created_at:String) {
        self.created_at = created_at
    }
    
    func setUpdated_at(_ updated_at:String) {
        self.updated_at = updated_at
    }
    
    func setMeasuresData(_ measuresData:[String:[[String:Int]]]) {
        self.measuresData = measuresData
    }
    
    func setMeasuresPriorityIndex(_ measuresPriorityIndex:Int) {
        self.measuresPriorityIndex = measuresPriorityIndex
    }
    
    // 新規課題用の課題IDを設定するメソッド
    func setNewTaskID() {
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // ユーザーの課題データを取得
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                    // 課題IDの重複対策
                    // データベースの課題IDの最大値を取得
                    if taskDataCollection["taskID"] as! Int  > TaskData.taskCount {
                        TaskData.taskCount = taskDataCollection["taskID"] as! Int
                    }
                }
                // 課題IDは課題IDの最大値＋１で設定
                TaskData.taskCount += 1
                self.taskID = TaskData.taskCount
            }
        }
    }
    
    
    
    
    //MARK:- ゲッター
    
    func getTaskID() -> Int {
        return self.taskID
    }
    
    func getTaskTitle() -> String {
        return self.taskTitle
    }
    
    func getTaskCouse() -> String {
        return self.taskCause
    }
    
    func getTaskAchievement() -> Bool {
        return self.taskAchievement
    }
    
    func getIsDeleted() -> Bool {
        return self.isDeleted
    }
    
    func getUserID() -> String {
        return self.userID
    }
    
    func getCreated_at() -> String {
        return self.created_at
    }
    
    func getUpdated_at() -> String {
        return self.updated_at
    }
    
    func getMeasuresData() -> [String:[[String:Int]]] {
        return self.measuresData
    }
    
    func getMeasuresTitleArray() -> [String] {
        // キーだけの配列を作成（.keysで取得すると[""]が付いてしまうため、これを防止する）
        let stringArray = Array(self.measuresData.keys)
        return stringArray
    }
    
    func getMeasuresEffectiveness(at index:Int) -> String {
        // index番目の対策タイトルを取得
        let measuresTitle = getMeasuresTitleArray()[index]
        
        // 有効性コメントリストを取得
        let measuresEffectivenessArray = self.measuresData[measuresTitle]!
        
        // .keysのまま表示すると [""]が表示されるため、キーだけの配列を作成
        let stringArray = Array(measuresEffectivenessArray[0].keys)
        
        // 先頭の有効性コメントを返却
        return stringArray[0]
    }
    
    func getMeasuresEffectivenessArray(at index:Int) -> [[String:Int]] {
        // index番目の対策タイトルを取得
        let measuresTitle = getMeasuresTitleArray()[index]
        // 有効性コメントリストを返却
        return self.measuresData[measuresTitle]!
    }
    
    func getMeasuresPriorityIndex() -> Int {
        return self.measuresPriorityIndex
    }
    
    
    
    //MARK:- データベース関連
    
    // Firebaseの未解決課題データを取得するメソッド
    func loadUnresolvedTaskData() {
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // ユーザーの未解決課題データ取得
        // ログインユーザーの課題データで、かつisDeletedがfalseの課題を取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("taskAchievement", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                
                    // 取得データを基に、課題データを作成
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
                    databaseTaskData.setMeasuresPriorityIndex(taskDataCollection["measuresPriorityIndex"] as! Int)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
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
            "updated_at"     : self.updated_at,
            "measuresData"   : self.measuresData,
            "measuresPriorityIndex" : self.measuresPriorityIndex
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // 対策を追加するメソッド（ノート追加時には使用しないメソッドのため、ノートIDは存在しない0番を設定）
    func addMeasures(title measuresTitle:String,effectiveness measuresEffectiveness:String) {
        // Firebaseはリストされた配列を扱えないため、[対策の有効性コメント：ノートID]型のオブジェクトを作成
        let obj = [measuresEffectiveness : 0]
        // [対策タイトル：[対策の有効性コメント：ノートID]]の形式で追加
        self.measuresData.updateValue([obj], forKey: measuresTitle)
    }
    
    // 対策タイトルを更新するメソッド
    func updateMeasuresTitle(newTitle newMeasuresTitle:String,at index:Int) {
        // 名前が変更になる対策の"有効性コメントリスト"を取得
        let effectivenessArray = getMeasuresEffectivenessArray(at: index)
        
        // 古い名前の対策を削除
        self.deleteMeasures(at: index)
        
        // 新しい名前の対策を追加
        self.measuresData.updateValue(effectivenessArray, forKey: newMeasuresTitle)
    }
    
    // 有効性コメントを追加するメソッド（ノート追加時に使用するメソッド）
    func addEffectiveness(title measuresTitle:String,effectiveness measuresEffectiveness:String,noteID:Int) {
        let obj = [measuresEffectiveness : noteID]
        self.measuresData[measuresTitle]!.insert(obj, at: 0)
    }
    
    // 対策を削除するメソッド
    func deleteMeasures(at index:Int) {
        self.measuresData[getMeasuresTitleArray()[index]] = nil
    }
    
    // 解決、未解決を反転するメソッド
    func changeAchievement() {
        self.taskAchievement.toggle()
    }
    
}
