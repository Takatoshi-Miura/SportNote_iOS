//
//  RealmActor.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/06/27.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

import RealmSwift

actor RealmActor {
    
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    /// データの追加
    /// - Parameter object: RealmObject
    func add<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch {
            print("Error adding object to Realm: \(error.localizedDescription)")
        }
    }
    
    /// データの取得
    /// - Parameter type: データ型
    /// - Returns: 取得データ
    func fetch<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    /// データの削除
    /// - Parameter object: RealmObject
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object from Realm: \(error.localizedDescription)")
        }
    }

}














