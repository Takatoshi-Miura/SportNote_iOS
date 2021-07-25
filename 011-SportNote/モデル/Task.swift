//
//  Task.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//
import Firebase

class Task {
    
    //MARK:- 保持データ
    static var count: Int = 0                    // 課題の数
    private var taskID: Int = 0                  // 課題ID
    private var title: String = ""               // タイトル
    private var cause: String = ""               // 原因
    private var order: Int = 0                   // 並び順
    private var isAchieve: Bool = false          // 解決済み：true, 未解決：false
    private var isDeleted: Bool = false          // 削除：true, 削除しない：false
    private var userID: String = ""              // ユーザーUID
    private var created_at: String = ""          // 作成日
    private var updated_at: String = ""          // 更新日
    private var measures: [String: [[String: Int]]] = [:]   // [対策タイトル, [ [対策の有効性コメント：ノートID], [対策の有効性コメント：ノートID] ] ]
    private var measuresPriorityTitle: String = ""          // 最優先の対策名
    
    
    
    //MARK:- イニシャライザ
    
    init() {
        
    }
    
    
    
    //MARK:- セッター
    
    func setTaskID(_ taskID:Int) {
        self.taskID = taskID
    }
    
    func setTitle(_ taskTitle:String) {
        self.title = taskTitle
    }
    
    func setCause(_ taskCause:String) {
        self.cause = taskCause
    }
    
    func setOrder(_ order: Int) {
        self.order = order
    }
    
    func setAchievement(_ taskAchievement:Bool) {
        self.isAchieve = taskAchievement
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
        self.measures = measuresData
    }
    
    func setMeasuresPriority(_ measuresPriority:String) {
        self.measuresPriorityTitle = measuresPriority
    }
    
    // 新規課題用の課題IDを設定するメソッド
    func setNewTaskID(_ completion: @escaping () -> ()) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
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
                    if taskDataCollection["taskID"] as! Int  > Task.count {
                        Task.count = taskDataCollection["taskID"] as! Int
                    }
                }
                // 課題IDは課題IDの最大値＋１で設定
                Task.count += 1
                self.taskID = Task.count
                // 完了処理
                completion()
            }
        }
    }
    
    
    //MARK:- ゲッター
    
    func getTaskID() -> Int {
        return self.taskID
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getCause() -> String {
        return self.cause
    }
    
    func getOrder() -> Int {
        return self.order
    }
    
    func getAchievement() -> Bool {
        return self.isAchieve
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
        return self.measures
    }
    
    func getMeasuresTitleArray() -> [String] {
        // キーだけの配列を作成（.keysで取得すると[""]が付いてしまうため、これを防止する）
        let stringArray = Array(self.measures.keys)
        return stringArray
    }
    
    func getMeasuresEffectivenessArray(at index:Int) -> [[String:Int]] {
        // index番目の対策タイトルを取得
        let measuresTitle = getMeasuresTitleArray()[index]
        // 有効性コメントリストを返却
        return self.measures[measuresTitle]!
    }
    
    func getMeasuresPriority() -> String {
        return self.measuresPriorityTitle
    }
    
    /**
     最新の有効性コメントを取得
     - Parameters:
    　- index: 取得したいコメントのIndex
     - Returns:最新の有効性コメント
     */
    func getEffectivenessComment(at index: Int) -> String {
        let comments = getEffectivenessComments(at: index)
        if comments.count == 0 {
            return ""
        } else {
            return comments[0]
        }
    }
    
    /**
     有効性コメント配列を取得
     - Parameters:
    　- index: 取得したいコメントのIndex
     - Returns: 有効性コメント配列
     */
    func getEffectivenessComments(at index: Int) -> [String] {
        let measuresEffectiveness: [[String: Int]] = getMeasuresEffectivenessArray(at: index)
        var measuresEffectivenessComments: [String] = []
        for effectiveness in measuresEffectiveness {
            measuresEffectivenessComments.append(contentsOf: effectiveness.keys)
        }
        return measuresEffectivenessComments
    }
    
    /**
     有効性コメントと連動するノートIDを取得
     - Parameters:
      - measureIndex: 対策のIndex
      - effectivenessIndex: 有効性コメントのIndex
      - effectivenessComment: 取得したいノートと連動している有効性コメント
     - Returns: ノートID(連動するノートが無ければnil)
     */
    func getEffectivenessNoteID(at measureIndex: Int , _ effectivenessIndex: Int, _ effectivenessComment: String) -> Int? {
        let measuresEffectiveness: [[String: Int]] = getMeasuresEffectivenessArray(at: measureIndex)
        let noteID = measuresEffectiveness[effectivenessIndex][effectivenessComment]
        if noteID == 0 {
            return nil
        } else {
            return noteID
        }
    }
    
    
    //MARK:- その他のメソッド
    
    // 対策を追加するメソッド（ノート追加時には使用しないメソッドのため、ノートIDは存在しない0番を設定）
    func addMeasures(title measuresTitle:String,effectiveness measuresEffectiveness:String) {
        // Firebaseはリストされた配列を扱えないため、[対策の有効性コメント：ノートID]型のオブジェクトを作成
        let obj = [measuresEffectiveness : 0]
        
        // [対策タイトル：[対策の有効性コメント：ノートID]]の形式で追加
        self.measures.updateValue([obj], forKey: measuresTitle)
    }
    
    // 対策タイトルを更新するメソッド
    func updateMeasuresTitle(newTitle newMeasuresTitle:String,at index:Int) {
        // 名前が変更になる対策の"有効性コメントリスト"を取得
        let effectivenessArray = getMeasuresEffectivenessArray(at: index)
        
        // 古い名前の対策を削除
        self.deleteMeasures(at: index)
        
        // 新しい名前の対策を追加
        self.measures.updateValue(effectivenessArray, forKey: newMeasuresTitle)
    }
    
    // 有効性コメントを追加するメソッド（ノート追加時に使用するメソッド）
    func addEffectiveness(title measuresTitle:String,effectiveness measuresEffectiveness:String,noteID:Int) {
        let obj = [measuresEffectiveness : noteID]
        self.measures[measuresTitle]?.insert(obj, at: 0)
    }
    
    // 対策を削除するメソッド
    func deleteMeasures(at index:Int) {
        self.measures[getMeasuresTitleArray()[index]] = nil
    }
    
    // 有効性を削除するメソッド
    func deleteEffectiveness(measuresTitle title:String,effectivenessArray array:[[String:Int]],at index:Int) {
        // 有効性データを削除
        var effectiveness = array
        effectiveness.remove(at: index)
        
        // データ更新
        self.measures.updateValue(effectiveness, forKey: title)
    }
    
    // 解決、未解決を反転するメソッド
    func changeAchievement() {
        self.isAchieve.toggle()
    }
    
}
