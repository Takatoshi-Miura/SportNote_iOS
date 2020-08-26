//
//  UserData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

class UserData {
    
    //MARK:- 保持データ
    
    private var userID:String = ""          // ユーザーUID
    private var IPAddress:String = ""       // IPアドレス
    private var created_at:String = ""      // 作成日
    private var updated_at:String = ""      // 更新日
    
    
    
    //MARK:- イニシャライザ
    
    init() {
        
    }
    
    
    
    //MARK:- セッター
    
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

