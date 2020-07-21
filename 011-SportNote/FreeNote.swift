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
    
    //MARK:- 保持データ
    private var title:String  = "フリーノート"                        // タイトル
    private var detail:String = "常に最上位に表示されるノートです。"      // 内容
    private var userID:String = ""                                 // ユーザーUID
    private var created_at:String = ""                             // 作成日
    private var updated_at:String = ""                             // 更新日
    
    
    
    //MARK:- セッター
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
    
    
    
    //MARK:- ゲッター
    func getTitle() -> String {
        return self.title
    }
    
    func getDetail() -> String {
        return self.detail
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

    
    
    // Firebaseのデータを更新するメソッド
    func updateFreeNoteData() {
        // 更新日時を現在時刻にする
        self.updated_at = getCurrentTime()
        
        // 更新したいデータを取得
        let db = Firestore.firestore()
        let freeNoteData = db.collection("FreeNoteData").document("\(self.userID)")

        // 変更する可能性のあるデータのみ更新
        freeNoteData.updateData([
            "title"      : self.title,
            "detail"     : self.detail,
            "updated_at" : self.updated_at
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
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
