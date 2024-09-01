//
//  RealmManagerTests.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/09/01.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

@testable import _11_SportNote
import Testing
import Foundation
import RealmSwift

final class RealmManagerTests {
    
    var realm: Realm!
    var originalDefaultConfiguration: Realm.Configuration!
    var realmManager: RealmManager!
    
    init() {
        // 既存のdefaultConfigurationを保存
        originalDefaultConfiguration = Realm.Configuration.defaultConfiguration
        
        // 他の環境に影響を与えないように、テスト用のインメモリRealmの設定をdefaultConfigurationに適用
        let config = Realm.Configuration(inMemoryIdentifier: "RealmManagerTests")
        Realm.Configuration.defaultConfiguration = config
        realm = try! Realm()
        realmManager = RealmManager()
        
        // テストデータを挿入
        createTestGroup()
    }
    
    deinit {
        // テスト終了後、デフォルトの設定を元に戻す
        Realm.Configuration.defaultConfiguration = originalDefaultConfiguration
        
        // テスト終了後にデータをクリーンアップ
        try! realm.write {
            realm.deleteAll()
        }
        realm = nil
        realmManager = nil
    }
    
    /// テスト用のGroupデータを作成
    private func createTestGroup() {
        let group1 = Group(title: "赤グループ", color: .red, order: 1)
        let group2 = Group(title: "青グループ", color: .blue, order: 2)
        
        try! realm.write {
            realm.add(group1)
            realm.add(group2)
        }
    }
    
    // MARK: - Group
    
    @Test("Groupを全取得")
    func testGetAllGroup() {
        let result = realmManager.getAllGroup()
        let expectedCount = 2
        #expect(result.count == expectedCount)
        #expect(result[0].title == "赤グループ")
        #expect(result[1].title == "青グループ")
    }
    
}
