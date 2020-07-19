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
    private var isDeleted:Bool = false  // 削除フラグ
    private var userID:String = ""      // ユーザーUID
    private var created_at:String = ""  // 作成日
    private var updated_at:String = ""  // 更新日
    
    // データ格納用
    var targetDataArray = [TargetData]()
    
    
    
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
    
    
    
    //MARK:- データベース関連
    
    // Firebaseにデータを保存するメソッド（新規目標追加時のみ使用）
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
            "isDeleted"  : self.isDeleted,
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
    
    // Firebaseからデータを取得するメソッド
    func loadTargetData() {
        // targetDataを初期化
        targetDataArray = []
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーの目標データを取得する
        db.collection("TargetData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標オブジェクトを作成
                    let target = TargetData()
                    
                    // 目標データを反映
                    let targetDataCollection = document.data()
                    target.setYear(targetDataCollection["year"] as! Int)
                    target.setMonth(targetDataCollection["month"] as! Int)
                    target.setDetail(targetDataCollection["detail"] as! String)
                    target.setIsDeleted(targetDataCollection["isDeleted"] as! Bool)
                    target.setUserID(targetDataCollection["userID"] as! String)
                    target.setCreated_at(targetDataCollection["created_at"] as! String)
                    target.setUpdated_at(targetDataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.targetDataArray.append(target)
                }
            }
        }
    }
    
    // Firebaseのデータを更新するメソッド
    func updateTargetData() {
        // 更新日時を現在時刻にする
        self.updated_at = getCurrentTime()
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let targetData = db.collection("TargetData").document("\(self.userID)_\(self.year)_\(self.month)")

        // 変更する可能性のあるデータのみ更新
        targetData.updateData([
            "detail"     : self.detail,
            "isDeleted"  : self.isDeleted,
            "updated_at" : self.updated_at
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
    
    
}
