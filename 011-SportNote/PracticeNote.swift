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
    
    
}
