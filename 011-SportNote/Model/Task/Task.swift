//
//  Task.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

class Task: Object {
    
    @objc dynamic var taskID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var groupID: String = ""      // 所属グループID
    @objc dynamic var title: String = ""        // タイトル
    @objc dynamic var cause: String = ""        // 原因
    @objc dynamic var order: Int = 0            // 並び順
    @objc dynamic var isComplete: Bool = false  // 完了フラグ
    @objc dynamic var isDeleted: Bool = false   // 削除フラグ
    @objc dynamic var created_at: Date = Date() // 作成日
    @objc dynamic var updated_at: Date = Date() // 更新日
    
    // 主キー
    override static func primaryKey() -> String? {
        return "taskID"
    }
    
}
