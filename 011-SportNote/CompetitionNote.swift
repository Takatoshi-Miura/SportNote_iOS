//
//  CompetitionNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import Foundation
import Firebase

class CompetitionNote {
    
    //MARK:- 保持データ
    
    private var year:Int  = 2020                // 年
    private var month:Int = 1                   // 月
    private var date:Int  = 1                   // 日
    private var weather:String = ""             // 天気
    private var temperature:Int = 0             // 気温
    private var physicalCondition:String = ""   // 体調
    private var target:String = ""              // 目標
    private var consciousness:String = ""       // 意識すること
    private var result:String = ""              // 結果
    private var reflection:String = ""          // 反省
    private var isDeleted:Bool = false          // 削除フラグ
    private var userID:String = ""              // ユーザーUID
    private var created_at:String = ""          // 作成日
    private var updated_at:String = ""          // 更新日
    
    // データ格納用
    var competitionNoteData = [CompetitionNote]()
    
    
    
    //MARK:- セッター
    
    func setYear(_ year:Int) {
        self.year = year
    }
    
    func setMonth(_ month:Int) {
        self.month = month
    }
    
    func setDate(_ date:Int) {
        self.date = date
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
    
    func setReflection(_ reflection:String) {
        self.reflection = reflection
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
    
    func getYear() -> Int {
        return self.year
    }
    
    func getMonth() -> Int {
        return self.month
    }
    
    func getDate() -> Int {
        return self.date
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
    
    func getReflection() -> String {
        return self.reflection
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
    func saveCompetitionNoteData() {
        // 現在時刻をセット
        setCreated_at(getCurrentTime())
        setUpdated_at(created_at)
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("CompetitionNoteData").document("\(self.userID)_\(self.year)_\(self.month)_\(self.date)").setData([
            "year"              : self.year,
            "month"             : self.month,
            "date"              : self.date,
            "weather"           : self.weather,
            "temperature"       : self.temperature,
            "physicalCondition" : self.physicalCondition,
            "target"            : self.target,
            "consciousness"     : self.consciousness,
            "result"            : self.result,
            "reflection"        : self.reflection,
            "isDeleted"         : self.isDeleted,
            "userID"            : self.userID,
            "created_at"        : self.created_at,
            "updated_at"        : self.updated_at
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // Firebaseからデータを取得するメソッド
    func loadCompetitionNoteData() {
        // competitionNoteDataを初期化
        competitionNoteData = []
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーのデータを取得する
        db.collection("CompetitionNoteData")
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
                    let competitionNote = CompetitionNote()
                    
                    // 目標データを反映
                    let competitionNoteDataCollection = document.data()
                    competitionNote.setYear(competitionNoteDataCollection["year"] as! Int)
                    competitionNote.setMonth(competitionNoteDataCollection["month"] as! Int)
                    competitionNote.setDate(competitionNoteDataCollection["date"] as! Int)
                    competitionNote.setWeather(competitionNoteDataCollection["weather"] as! String)
                    competitionNote.setTemperature(competitionNoteDataCollection["temperature"] as! Int)
                    competitionNote.setPhysicalCondition(competitionNoteDataCollection["physicalCondition"] as! String)
                    competitionNote.setTarget(competitionNoteDataCollection["target"] as! String)
                    competitionNote.setConsciousness(competitionNoteDataCollection["consciousness"] as! String)
                    competitionNote.setResult(competitionNoteDataCollection["result"] as! String)
                    competitionNote.setReflection(competitionNoteDataCollection["reflection"] as! String)
                    competitionNote.setIsDeleted(competitionNoteDataCollection["isDeleted"] as! Bool)
                    competitionNote.setUserID(competitionNoteDataCollection["userID"] as! String)
                    competitionNote.setCreated_at(competitionNoteDataCollection["created_at"] as! String)
                    competitionNote.setUpdated_at(competitionNoteDataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.competitionNoteData.append(competitionNote)
                }
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
    
}
