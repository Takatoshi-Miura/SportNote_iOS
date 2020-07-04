//
//  TargetData.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/04.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import Foundation
import Firebase

class TargetData {
    
    //MARK:- 保持データ
    private var year:Int = 2020         // 年
    private var month:Int = 1           // 月
    private var detail:String = ""      // 内容
    private var userID:String = ""      // ユーザーUID
    private var created_at:String = ""  // 作成日
    private var updated_at:String = ""  // 更新日
    
    
    
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
    
    
    
    
    
    
    //MARK:- データベース関連
    
    // Firebaseにデータを保存するメソッド（AddTargetViewControllerにて、保存ボタンタップ時に実行）
    func saveTargetData() {
        // 現在時刻をセット
        setCreated_at(getCurrentTime())
        setUpdated_at(created_at)
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("TargetData").document("\(self.userID)_\(self.year)_\(self.month)").setData([
            "year"       : self.year,
            "month"      : self.month,
            "detail"     : self.detail,
            "userID"     : self.userID,
            "created_at" : self.created_at,
            "updated_at" : self.updated_at
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
