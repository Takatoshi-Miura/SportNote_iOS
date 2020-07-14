//
//  NoteData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/08.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import Foundation
import Firebase

class NoteData {
    
    //MARK:- 保持データ
    static var noteCount:Int = 0                    // ノートの数
    private var noteID:Int = 0                      // ID
    private var noteType:String = "練習記録"         // 種別（"練習記録" or "大会記録"）
    private var year:Int  = 2020                    // 年
    private var month:Int = 1                       // 月
    private var date:Int  = 1                       // 日
    private var day:String = "日"                   // 曜日
    private var weather:String = ""                 // 天気
    private var temperature:Int = 0                 // 気温
    private var physicalCondition:String = ""       // 体調
    private var purpose:String = ""                 // 練習の目的
    private var detail:String = ""                  // 練習の内容
    private var target:String = ""                  // 目標
    private var consciousness:String = ""           // 意識すること
    private var result:String = ""                  // 結果
    private var reflection:String = ""              // 反省
    
    private var taskTitle:[String] = []             // 課題タイトル
    private var measuresTitle:[String] = []         // 対策タイトル
    private var measuresEffectiveness:[String] = [] // 対策の有効性
    
    private var isDeleted:Bool = false          // 削除フラグ
    private var userID:String = ""              // ユーザーUID
    private var created_at:String = ""          // 作成日
    private var updated_at:String = ""          // 更新日
    
    // データ格納用
    var noteDataArray = [NoteData]()
    
    
    
    //MARK:- セッター
    func setNoteID(_ noteID:Int) {
        self.noteID = noteID
    }
    
    func setNoteType(_ noteType:String) {
        self.noteType = noteType
    }
    
    func setYear(_ year:Int) {
        self.year = year
    }
    
    func setMonth(_ month:Int) {
        self.month = month
    }
    
    func setDate(_ date:Int) {
        self.date = date
    }
    
    func setDay(_ day:String) {
        self.day = day
    }
    
    func setWeather(_ weather:String) {
        self.weather = weather
    }
    
    func setTemperature(_ temperature:Int) {
        self.temperature = temperature
    }
    
    func setPhysicalCondition(_ physicalCondition:String) {
        self.physicalCondition = physicalCondition
    }
    
    func setTarget(_ target:String) {
        self.target = target
    }
    
    func setConsciousness(_ consciousness:String) {
        self.consciousness = consciousness
    }
    
    func setResult(_ result:String) {
        self.result = result
    }
    
    func setPurpose(_ purpose:String) {
        self.purpose = purpose
    }
    
    func setDetail(_ detail:String) {
        self.detail = detail
    }
    
    func setReflection(_ reflection:String) {
        self.reflection = reflection
    }
    
    func setTaskTitle(_ taskTitle:[String]) {
        self.taskTitle = taskTitle
    }
    
    func setMeasuresTitle(_ measuresTitle:[String]) {
        self.measuresTitle = measuresTitle
    }
    
    func setMeasuresEffectiveness(_ measuresEffectiveness:[String]) {
        self.measuresEffectiveness = measuresEffectiveness
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
    
    
    
    //MARK:- ゲッター
    func getNoteID() -> Int {
        return self.noteID
    }
    
    func getNoteType() -> String {
        return self.noteType
    }
    
    func getYear() -> Int {
        return self.year
    }
    
    func getMonth() -> Int {
        return self.month
    }
    
    func getDate() -> Int {
        return self.date
    }
    
    func getDay() -> String {
        return self.day
    }
    
    func getWeather() -> String {
        return self.weather
    }
    
    func getTemperature() -> Int {
        return self.temperature
    }
    
    func getPhysicalCondition() -> String {
        return self.physicalCondition
    }
    
    func getTarget() -> String {
        return self.target
    }
    
    func getConsciousness() -> String {
        return self.consciousness
    }
    
    func getResult() -> String {
        return self.result
    }
    
    func getPurpose() -> String {
        return self.purpose
    }
    
    func getDetail() -> String {
        return self.detail
    }
    
    func getReflection() -> String {
        return self.reflection
    }
    
    func getTaskTitle() -> [String] {
        return taskTitle
    }
    
    func getMeasuresTitle() -> [String] {
        return measuresTitle
    }
    
    func getMeasuresEffectiveness() -> [String] {
        return measuresEffectiveness
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
    
    
    
    //MARK:- データベース関連
    
    // Firebaseにデータを保存するメソッド
    func saveNoteData() {
        // ノートIDをセット
        NoteData.noteCount += 1
        setNoteID(NoteData.noteCount)
        
        // 現在時刻をセット
        setCreated_at(getCurrentTime())
        setUpdated_at(created_at)
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("NoteData").document("\(self.userID)_\(self.noteID)").setData([
            "noteID"                : self.noteID,
            "noteType"              : self.noteType,
            "year"                  : self.year,
            "month"                 : self.month,
            "date"                  : self.date,
            "day"                   : self.day,
            "weather"               : self.weather,
            "temperature"           : self.temperature,
            "physicalCondition"     : self.physicalCondition,
            "purpose"               : self.purpose,
            "detail"                : self.detail,
            "target"                : self.target,
            "consciousness"         : self.consciousness,
            "result"                : self.result,
            "reflection"            : self.reflection,
            "taskTitle"             : self.taskTitle,
            "measuresTitle"         : self.measuresTitle,
            "measuresEffectiveness" : self.measuresEffectiveness,
            "isDeleted"             : self.isDeleted,
            "userID"                : self.userID,
            "created_at"            : self.created_at,
            "updated_at"            : self.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        // noteDataArrayを初期化
        noteDataArray = []
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーのデータを取得する
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
                    // オブジェクトを作成
                    let noteData = NoteData()
                    
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
                    
                    // ノートIDの重複対策
                    if dataCollection["noteID"] as! Int > NoteData.noteCount {
                        NoteData.noteCount = dataCollection["noteID"] as! Int
                    }
                    
                    // 取得データを格納
                    self.noteDataArray.append(noteData)
                }
            }
        }
    }
    
    // Firebaseのデータを更新するメソッド
    func updateNoteData() {
        // 更新日時を現在時刻にする
        self.updated_at = getCurrentTime()
        
        // ユーザーUIDを取得
        let userID = Auth.auth().currentUser!.uid
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let noteData = db.collection("NoteData").document("\(userID)_\(self.noteID)")

        // 変更する可能性のあるデータのみ更新
        noteData.updateData([
            "year"                  : self.year,
            "month"                 : self.month,
            "date"                  : self.date,
            "day"                   : self.day,
            "weather"               : self.weather,
            "temperature"           : self.temperature,
            "physicalCondition"     : self.physicalCondition,
            "purpose"               : self.purpose,
            "detail"                : self.detail,
            "target"                : self.target,
            "consciousness"         : self.consciousness,
            "result"                : self.result,
            "reflection"            : self.reflection,
            "taskTitle"             : self.taskTitle,
            "measuresTitle"         : self.measuresTitle,
            "measuresEffectiveness" : self.measuresEffectiveness,
            "isDeleted"             : self.isDeleted,
            "updated_at"            : self.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
  
    
    
    //MARK:- その他メソッド
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // ノートセルに表示させるタイトルを取得するメソッド
    func getCellTitle() -> String {
        return "\(self.getYear())年\(self.getMonth())月\(self.getDate())日(\(self.day))：\(self.getWeather())\(self.getTemperature())℃"
    }
    
    // ナビゲーションバーに表示させるタイトルを取得するメソッド
    func getNavigationTitle() -> String {
        return "\(self.getYear())年\(self.getMonth())月\(self.getDate())日(\(self.day))"
    }
    
}
