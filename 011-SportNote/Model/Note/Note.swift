//
//  Note.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

class Note: Object {
    // 共通
    @objc dynamic var noteID: String = NSUUID().uuidString
    @objc dynamic var userID: String = UserDefaults.standard.object(forKey: "userID") as! String
    @objc dynamic var noteType: Int = NoteType.free.rawValue // ノート種別
    @objc dynamic var isDeleted: Bool = false   // 削除フラグ
    @objc dynamic var created_at: Date = Date() // 作成日
    @objc dynamic var updated_at: Date = Date() // 更新日
    // フリーノート
    @objc dynamic var title: String = ""        // タイトル
    // 練習大会共通
    @objc dynamic var date: Date = Date()       // 日付
    @objc dynamic var weather: Int = Weather.sunny.rawValue // 天気
    @objc dynamic var temperature: Int = 0      // 気温
    @objc dynamic var condition: String = ""    // 体調
    @objc dynamic var reflection: String = ""   // 反省
    // 練習ノート
    @objc dynamic var purpose: String = ""      // 練習目的
    @objc dynamic var detail: String = ""       // 練習内容
    // 大会ノート
    @objc dynamic var target: String = ""       // 目標
    @objc dynamic var consciousness: String = ""// 意識すること
    @objc dynamic var result: String = ""       // 結果
    
    // 主キー
    override static func primaryKey() -> String? {
        return "noteID"
    }
    
    /// フリーノートのイニシャライザ
    /// - Parameter title: タイトル
    convenience init(freeWithTitle title: String) {
        self.init()
        self.noteType = NoteType.free.rawValue
        self.title = title
    }
    
    /// 練習ノートのイニシャライザ
    /// - Parameters:
    ///   - purpose: 練習の目的
    ///   - detail: 練習内容
    convenience init(practiceWithPurpose purpose: String, detail: String) {
        self.init()
        self.noteType = NoteType.practice.rawValue
        self.purpose = purpose
        self.detail = detail
    }
    
    /// 大会ノートのイニシャライザ
    /// - Parameters:
    ///   - target: 目標
    ///   - consciousness: 意識すること
    ///   - result: 結果
    convenience init(tournamentWithTarget target: String, consciousness: String, result: String) {
        self.init()
        self.noteType = NoteType.tournament.rawValue
        self.target = target
        self.consciousness = consciousness
        self.result = result
    }
    
}
