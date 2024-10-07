//
//  RealmGroupTests.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/09/02.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

@testable import _11_SportNote
import Testing
import Foundation
import RealmSwift

extension RealmManagerTests {
    
    @Test("Groupを全取得", .tags(.realm, .group))
    func testGetAllGroup() {
        let result = realmManager.getAllGroup()
        #expect(result.count == 4, "削除されたGroupも含めて全取得すること")
        deleteTestData()
    }
    
    @Test("GroupをID指定で取得", .tags(.realm, .group))
    func testGetGroupByID() {
        let result = realmManager.getGroup(groupID: "グループID")
        #expect(result.title == "IDテスト用グループ")
        #expect(result.color == Color.green.rawValue)
        deleteTestData()
    }
    
    @Test("Group配列(課題一覧用)を取得", .tags(.realm, .group))
    func testGetGroupArrayForTaskView() {
        let result = realmManager.getGroupArrayForTaskView()
        #expect(result.count == 3, "削除されたGroupは取得されないこと")
        #expect(result[0].title == "赤グループ", "orderの昇順でソートされていない")
        #expect(result[1].title == "青グループ", "orderの昇順でソートされていない")
        #expect(result[2].title == "IDテスト用グループ", "orderの昇順でソートされていない")
        deleteTestData()
    }
    
    /// getGroupColor()はgetTask(noteID: noteID)のテストで担保
    
    @Test("Group数(課題一覧用)を取得", .tags(.realm, .group))
    func testGetNumberOfGroups() {
        let result = realmManager.getNumberOfGroups()
        #expect(result == 3, "削除されたGroupは取得されないこと")
        deleteTestData()
    }
    
    /// 更新テスト用Groupを追加
    /// - Parameter groupID: グループID
    private func addTestGroupForUpdate(groupID: String) {
        let group = Group(title: "更新テスト用グループ", color: Color.red, order: 5)
        group.groupID = groupID
        try! realm.write {
            realm.add(group)
        }
    }
    
    /// 更新テスト用Groupを削除
    /// - Parameter group: Groupデータ
    private func deleteTestGroupForUpdate(group: Group?) {
        try! realm.write {
            if let group = group {
                realm.delete(group)
            }
        }
    }
    
    @Test("Groupを更新", .tags(.realm, .group))
    func testUpdateGroup() {
        // 更新テスト用Groupを追加
        let groupID = "更新グループID"
        addTestGroupForUpdate(groupID: groupID)
        
        // 更新テスト用Groupを更新
        let updatedGroup = Group(title: "更新テスト用グループ2", color: Color.blue, order: 6)
        updatedGroup.groupID = groupID
        updatedGroup.isDeleted = true
        updatedGroup.updated_at = Date()
        realmManager.updateGroup(group: updatedGroup)
        
        // 更新できているかチェック
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        #expect(result != nil, "更新後にGroupを取得不可")
        #expect(result!.title == updatedGroup.title, "Groupタイトルを更新できていない")
        #expect(result!.color == updatedGroup.color, "Groupカラーを更新できていない")
        #expect(result!.order == updatedGroup.order, "Group並び順を更新できていない")
        #expect(result!.isDeleted == updatedGroup.isDeleted, "Group削除フラグを更新できていない")
        
        // 更新テスト用Groupを削除
        deleteTestGroupForUpdate(group: result)
        deleteTestData()
    }
    
    @Test("Groupタイトルを更新", .tags(.realm, .group))
    func testUpdateGroupTitle() {
        // 更新テスト用Groupを追加
        let groupID = "更新グループID"
        addTestGroupForUpdate(groupID: groupID)
        
        // 更新テスト用Groupを更新
        realmManager.updateGroupTitle(groupID: groupID, title: "更新テスト用グループ2")
        
        // 更新できているかチェック
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        #expect(result != nil, "更新後にGroupを取得不可")
        #expect(result!.title == "更新テスト用グループ2", "Groupタイトルを更新できていない")
        #expect(result!.color == Color.red.rawValue, "更新対象外のGroupカラーが更新されている")
        #expect(result!.order == 5, "更新対象外のGroup並び順が更新されている")
        #expect(result!.isDeleted == false, "更新対象外のGroup削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestGroupForUpdate(group: result)
        deleteTestData()
    }
    
    @Test("Groupカラーを更新", .tags(.realm, .group))
    func testUpdateGroupColor() {
        // 更新テスト用Groupを追加
        let groupID = "更新グループID"
        addTestGroupForUpdate(groupID: groupID)
        
        // 更新テスト用Groupを更新
        realmManager.updateGroupColor(groupID: groupID, color: Color.blue.rawValue)
        
        // 更新できているかチェック
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        #expect(result != nil, "更新後にGroupを取得不可")
        #expect(result!.title == "更新テスト用グループ", "更新対象外のGroupタイトルが更新されている")
        #expect(result!.color == Color.blue.rawValue, "Groupカラーが更新されていない")
        #expect(result!.order == 5, "更新対象外のGroup並び順が更新されている")
        #expect(result!.isDeleted == false, "更新対象外のGroup削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestGroupForUpdate(group: result)
        deleteTestData()
    }
    
    @Test("Group並び順を更新", .tags(.realm, .group))
    func testUpdateGroupOrder() {
        // 更新テスト用Groupを追加
        let groupID = "更新グループID"
        addTestGroupForUpdate(groupID: groupID)
        let groupArray = realmManager.getAllGroup()
        
        // 更新テスト用Groupを更新
        realmManager.updateGroupOrder(groupArray: groupArray)
        
        // 更新できているかチェック
        let result = realm.objects(Group.self)
        #expect(result != nil, "更新後にGroupを取得不可")
        #expect(result[0].title == "赤グループ", "Group並び順が更新されていない")
        #expect(result[1].title == "青グループ", "Group並び順が更新されていない")
        #expect(result[2].title == "削除されたグループ", "Group並び順が更新されていない")
        #expect(result[3].title == "IDテスト用グループ", "Group並び順が更新されていない")
        #expect(result[4].title == "更新テスト用グループ", "Group並び順が更新されていない")
        #expect(result[0].order == 0, "Group並び順が更新されていない")
        #expect(result[1].order == 1, "Group並び順が更新されていない")
        #expect(result[2].order == 2, "Group並び順が更新されていない")
        #expect(result[3].order == 3, "Group並び順が更新されていない")
        #expect(result[4].order == 4, "Group並び順が更新されていない")
        
        // 更新テスト用Groupを削除
        let updatedGroup = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        deleteTestGroupForUpdate(group: updatedGroup)
        deleteTestData()
    }
    
    @Test("Group削除フラグを更新", .tags(.realm, .group))
    func testUpdateGroupIsDeleted() {
        // 更新テスト用Groupを追加
        let groupID = "更新グループID"
        addTestGroupForUpdate(groupID: groupID)
        
        // 更新テスト用Groupを更新
        let updatedGroup = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        realmManager.updateGroupIsDeleted(group: updatedGroup!)
        
        // 更新できているかチェック
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        #expect(result != nil, "更新後にGroupを取得不可")
        #expect(result!.title == updatedGroup!.title, "更新対象外のGroupタイトルが更新されている")
        #expect(result!.color == updatedGroup!.color, "更新対象外のGroupカラーが更新されている")
        #expect(result!.order == updatedGroup!.order, "更新対象外のGroup並び順が更新されている")
        #expect(result!.isDeleted == true, "Group削除フラグが更新されていない")
        
        // 更新テスト用Groupを削除
        deleteTestGroupForUpdate(group: result)
        deleteTestData()
    }
    
    /// updateGroupUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllGroupはdeleteAllRealmDataのテストで確認する

}
