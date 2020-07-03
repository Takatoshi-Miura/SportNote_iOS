//
//  FreeNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import Foundation
import Firebase

class FreeNote {
    
    // 保持するデータ
    private var title:String  = "フリーノート"                        // タイトル
    private var detail:String = "常に最上位に表示されるノートです。"      // 内容
    private var userID:String = ""                                 // ユーザーUID
    private var created_at:String = ""                             // 作成日
    private var updated_at:String = ""                             // 更新日
    
    
    // セッター
    func setTitle(_ title:String) {
        self.title = title
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
    
    
    // ゲッター
    func getTitle() -> String {
        return self.title
    }
    
    func getDetail() -> String {
        return self.detail
    }
    
    
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    
    // Firebaseにデータを保存するメソッド(アカウント作成時のみ実行される)
    func saveFreeNoteData() {
        // 現在時刻をセット
        setCreated_at(getCurrentTime())
        setUpdated_at(created_at)
        
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("FreeNoteData").document("\(self.userID)").setData([
            "title"      : self.title,
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
    
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        // ユーザーUIDをセット
        setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        db.collection("FreeNoteData")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let freeNoteDataCollection = document.data()
                    
                    // フリーノートデータを反映
                    self.setTitle(freeNoteDataCollection["title"] as! String)
                    self.setDetail(freeNoteDataCollection["detail"] as! String)
                    self.setUserID(freeNoteDataCollection["userID"] as! String)
                    self.setCreated_at(freeNoteDataCollection["created_at"] as! String)
                    self.setUpdated_at(freeNoteDataCollection["updated_at"] as! String)
                }
            }
        }
    }
    
    
    
    
}
