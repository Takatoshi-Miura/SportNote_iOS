//
//  FreeNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

class FreeNote: Object {
    
    @objc dynamic var freeNoteID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var created_at: Date = Date() // 作成日
    @objc dynamic var updated_at: Date = Date() // 更新日
    @objc dynamic var title: String = ""        // タイトル
    @objc dynamic var detail: String = ""       // 内容
    
    // 主キー
    override static func primaryKey() -> String? {
        return "freeNoteID"
    }
    
}
