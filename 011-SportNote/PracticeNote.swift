//
//  PracticeNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import Foundation
import Firebase

class PracticeNote {
    
    //MARK:- 保持データ
    private var year:Int  = 2020                // 年
    private var month:Int = 1                   // 月
    private var date:Int  = 1                   // 日
    private var weather:String = ""             // 天気
    private var temperature:Int = 0             // 気温
    private var physicalCondition:String = ""   // 体調
    private var purpose:String = ""             // 練習の目的
    private var detail:String = ""              // 練習の内容
    private var reflection:String = ""          // 反省
    
    private var isDeleted:Bool = false          // 削除フラグ
    private var userID:String = ""              // ユーザーUID
    private var created_at:String = ""          // 作成日
    private var updated_at:String = ""          // 更新日
    
    
    
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
    
    func setPurpose(_ purpose:String) {
        self.purpose = purpose
    }
    
    func setDetail(_ detail:String) {
        self.detail = detail
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
    
    func getPurpose() -> String {
        return self.purpose
    }
    
    func getDetail() -> String {
        return self.detail
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
    
    func savePracticeNoteData() {
        // 現在時刻をセット
        setCreated_at(getCurrentTime())
        setUpdated_at(created_at)
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("PracticeNoteData").document("\(self.userID)_\(self.year)_\(self.month)_\(self.date)").setData([
            "year"              : self.year,
            "month"             : self.month,
            "date"              : self.date,
            "weather"           : self.weather,
            "temperature"       : self.temperature,
            "physicalCondition" : self.physicalCondition,
            "purpose"           : self.purpose,
            "detail"            : self.detail,
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
