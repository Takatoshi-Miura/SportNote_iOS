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
        let group1 = Group(title: "赤グループ", color: Color.red, order: 1)
        let group2 = Group(title: "青グループ", color: Color.blue, order: 2)
        let deletedGroup = Group(title: "削除されたグループ", color: Color.gray, order: 3)
        deletedGroup.isDeleted = true
        let setIDGroup = Group(title: "IDテスト用グループ", color: Color.green, order: 4)
        setIDGroup.groupID = "グループID"
        
        try! realm.write {
            realm.add(group1)
            realm.add(group2)
            realm.add(deletedGroup)
            realm.add(setIDGroup)
        }
    }
    
    // MARK: - Group
    
    @Test("Groupを全取得", .tags(.realm))
    func testGetAllGroup() {
        let result = realmManager.getAllGroup()
        #expect(result.count == 4, "削除されたGroupも含めて全取得すること")
    }
    
    @Test("GroupをID指定で取得", .tags(.realm))
    func testGetGroupByID() {
        let result = realmManager.getGroup(groupID: "グループID")
        #expect(result.title == "IDテスト用グループ")
        #expect(result.color == Color.green.rawValue)
    }
    
    @Test("課題一覧のGroup配列を取得", .tags(.realm))
    func testGetGroupArrayForTaskView() {
        let result = realmManager.getGroupArrayForTaskView()
        #expect(result.count == 3, "削除されたGroupは取得されないこと")
        #expect(result[0].title == "赤グループ", "orderの昇順でソートされること")
        #expect(result[1].title == "青グループ", "orderの昇順でソートされること")
        #expect(result[2].title == "IDテスト用グループ", "orderの昇順でソートされること")
    }
    
    /// getGroupColor()はgetTask(noteID: noteID)のテストで担保
    
    @Test("課題一覧のGroup数を取得", .tags(.realm))
    func testGetNumberOfGroups() {
        let result = realmManager.getNumberOfGroups()
        #expect(result == 3, "削除されたGroupは取得されないこと")
    }
    
    
    
}
