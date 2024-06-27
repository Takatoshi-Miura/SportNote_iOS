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
    
    // MARK: - INSERT
    
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
    
    // MARK: - SELECT
    
    /// データリストの取得
    /// - Parameter type: データ型
    /// - Returns: 取得データリスト
    func find<T: Object>(_ type: T.Type) -> Results<T> {
        return realm.objects(type)
    }
    
    /// データリストの取得
    /// - Parameters:
    ///  - type: データ型
    ///  - filter: 検索条件
    ///  - sortKey: ソート条件
    ///  - ascending: 昇順 or 降順
    /// - Returns: 取得データリスト
    func find<T: Object>(_ type: T.Type, filter: String, sortKey: String?, ascending: Bool) -> Results<T> {
        var results = realm.objects(type).filter(filter)
        if let sortKey = sortKey {
            results = results.sorted(byKeyPath: sortKey, ascending: ascending)
        }
        return results
    }
    
    /// 単一データの取得
    /// - Parameter type: データ型
    /// - Returns: 取得データ
    func findOne<T: Object>(_ type: T.Type, filter: String) -> T? {
        return realm.objects(type).filter(filter).first
    }
    
    // MARK: - DELETE
    
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
