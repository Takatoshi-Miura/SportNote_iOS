//
//  UserData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase

class UserData {
    
    //MARK:- 保持データ
    
    private var userID:String = ""          // ユーザーUID
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
    
    
    
    //MARK:- データベース関連
    
    // UserDataを作成するメソッド
    func createUserData() {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // ユーザーIDをセット
        self.setUserID(userID)
        
        // 現在時刻をセット
        self.setCreated_at(self.getCurrentTime())
        self.setUpdated_at(self.getCurrentTime())
        
        // Firebaseに保存
        let db = Firestore.firestore()
        db.collection("UserData").document("\(userID)").setData([
            "userID"     : self.getUserID(),
            "created_at" : self.getCreated_at(),
            "updated_at" : self.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("UserDataを作成しました")
            }
        }
    }
    
    // UserDataを更新するメソッド
    func updateUserData() {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新時間に現在時刻をセット
        self.setUpdated_at(self.getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("UserData").document("\(userID)")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "updated_at" : self.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("UserDataを更新しました")
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
}

