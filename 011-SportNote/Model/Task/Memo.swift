//
//  Memo.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

class Memo: Object {
    
    @objc dynamic var memoID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var measuresID: String = ""   // 所属対策ID
    @objc dynamic var noteID: String = ""       // 所属ノートID
    @objc dynamic var detail: String = ""       // 内容
    @objc dynamic var isDeleted: Bool = false   // 削除フラグ
    @objc dynamic var created_at: Date = Date() // 作成日
    @objc dynamic var updated_at: Date = Date() // 更新日
    
    // 主キー
    override static func primaryKey() -> String? {
        return "memoID"
    }
    
}

