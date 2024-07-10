//
//  RealmActor.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/06/27.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

import RealmSwift

actor RealmActor {
    
    /// スレッドごとにRealmインスタンスを作成
    /// RealmSwiftはスレッドセーフではないため
    /// - Returns: Realm
    private func createRealm() -> Realm {
        return try! Realm()
    }
    
    // MARK: - INSERT
    
    /// データの追加
    /// - Parameter object: RealmObject
    /// - Returns: 成功失敗
    func insert<T: Object>(_ object: T) -> Bool {
        let realm = createRealm()
        do {
            try realm.write {
                realm.add(object)
            }
            return true
        } catch {
            print("Error adding object to Realm: \(error.localizedDescription)")
            return false
        }
    }
    
    /// データリストの追加
    /// - Parameter objects: RealmObjects
    /// - Returns: 成功失敗
    func insertList<T: Object>(_ objects: [T]) -> Bool {
        let realm = createRealm()
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
            return true
        } catch {
            print("Error adding object to Realm: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - SELECT
    
    /// データリストの取得
    /// - Parameter type: データ型
    /// - Returns: 取得データリスト
    func find<T: Object>(_ type: T.Type) -> Results<T> {
        let realm = createRealm()
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
        let realm = createRealm()
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
        let realm = createRealm()
        return realm.objects(type).filter(filter).first
    }
    
    // MARK: - DELETE
    
    /// データの削除
    /// - Parameter object: RealmObject
    func delete<T: Object>(_ object: T) {
        let realm = createRealm()
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting object from Realm: \(error.localizedDescription)")
        }
    }
    
    /// データを全削除
    /// - Parameter type: データ型
    func deleteAll<T: Object>(ofType type: T.Type) {
        let realm = createRealm()
        let objects = find(type)
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            print("Error deleting all objects of type \(type): \(error.localizedDescription)")
        }
    }

}
