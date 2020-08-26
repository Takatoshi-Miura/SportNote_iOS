//
//  TargetData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/04.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TargetData {
    
    //MARK:- 保持データ
    private var year:Int = 2020         // 年
    private var month:Int = 1           // 月
    private var detail:String = ""      // 内容
    private var isDeleted:Bool = false  // 削除フラグ
    private var userID:String = ""      // ユーザーUID
    private var created_at:String = ""  // 作成日
    private var updated_at:String = ""  // 更新日
    
    
    
    //MARK:- イニシャライザ
    
    init() {
        
    }
    
    
    
    //MARK:- セッター
    func setYear(_ year:Int) {
        self.year = year
    }
    
    func setMonth(_ month:Int) {
        self.month = month
    }
    
    func setDetail(_ detail:String) {
        self.detail = detail
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
    
    func getDetail() -> String {
        return self.detail
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
    
    func getYearMonth() -> String {
        return "\(self.getYear())/\(self.getMonth())"
    }
    
}
