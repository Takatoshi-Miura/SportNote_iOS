//
//  Target.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

class Target: Object {
    
    @objc dynamic var targetID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var title: String = ""            // タイトル
    @objc dynamic var year: Int = 2020              // 年
    @objc dynamic var month: Int = 1                // 月
    @objc dynamic var isYearlyTarget: Bool = false  // 年間目標フラグ
    @objc dynamic var isDeleted: Bool = false       // 削除フラグ
    @objc dynamic var created_at: Date = Date()     // 作成日
    @objc dynamic var updated_at: Date = Date()     // 更新日
    
    // 主キー
    override static func primaryKey() -> String? {
        return "targetID"
    }
    
}
