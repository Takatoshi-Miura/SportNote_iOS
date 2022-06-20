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

/// NoteFilterVC用の構造体
struct FilteredTask {
    
    let taskID: String
    let userID: String
    let groupID: String
    let title: String
    let cause: String
    let order: Int
    let isComplete: Bool
    let isDeleted: Bool
    let created_at: Date
    let updated_at: Date
    var isFilter: Bool
    
    init(task: Task) {
        self.taskID = task.taskID
        self.userID = task.userID
        self.groupID = task.groupID
        self.title = task.title
        self.cause = task.cause
        self.order = task.order
        self.isComplete = task.isComplete
        self.isDeleted = task.isDeleted
        self.created_at = task.created_at
        self.updated_at = task.updated_at
        self.isFilter = true
    }
}
