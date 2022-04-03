//
//  TournamentNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//
// ※Realmオブジェクトは継承不可能

import RealmSwift

class TournamentNote: Object {
    
    @objc dynamic var tournamentNoteID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var date: Date = Date()           // 日付
    @objc dynamic var weather: Int = Weather.sunny.rawValue // 天気
    @objc dynamic var temperature: Int = 0          // 気温
    @objc dynamic var condition: String = ""        // 体調
    @objc dynamic var target: String = ""           // 目標
    @objc dynamic var consciousness: String = ""    // 意識すること
    @objc dynamic var result: String = ""           // 結果
    @objc dynamic var reflection: String = ""       // 反省
    @objc dynamic var isDeleted: Bool = false       // 削除フラグ
    @objc dynamic var created_at: Date = Date()     // 作成日
    @objc dynamic var updated_at: Date = Date()     // 更新日
    
    // 主キー
    override static func primaryKey() -> String? {
        return "tournamentNoteID"
    }
    
}
