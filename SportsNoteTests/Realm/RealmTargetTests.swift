//
//  RealmTargetTests.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/09/09.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

@testable import _11_SportNote
import Testing
import Foundation
import RealmSwift

extension RealmManagerTests {
    
    @Test("Targetを全取得", .tags(.realm, .target))
    func testGetAllTarget() {
        let result = realmManager.getAllTarget()
        #expect(result.count == 4, "削除したTargetも含めて全取得すること")
    }
    
    @Test("Target(年間目標)を年指定で取得", .tags(.realm, .target))
    func testGetTargetByYear() {
        let result = realmManager.getTarget(year: 2024)
        #expect(result != nil, "年指定でTarget取得できていない")
        #expect(result?.title == "年間目標", "年指定でTarget取得できていない")
    }
    
    @Test("Targetを年月指定で取得", .tags(.realm, .target))
    func testGetTargetByYearMonth() {
        let result = realmManager.getTarget(year: 2024, month: 1, isYearlyTarget: false)
        #expect(result != nil, "年月指定でTarget取得できていない")
        #expect(result?.title == "月間目標", "年月指定でTarget取得できていない")
        
        let result2 = realmManager.getTarget(year: 2024, month: 1, isYearlyTarget: true)
        #expect(result2 != nil, "年月指定でTarget取得できていない")
        #expect(result2?.title == "年間目標", "年月指定でTarget取得できていない")
    }

    /// 更新テスト用Targetを追加
    /// - Parameter targetID: 目標ID
    private func addTestTargetForUpdate(targetID: String) {
        let target = Target()
        target.targetID = targetID
        target.title = "更新テスト用目標"
        target.year = 2024
        target.month = 1
        target.isYearlyTarget = false
        target.isDeleted = false
        
        try! realm.write {
            realm.add(target)
        }
    }
    
    /// 更新テスト用Targetを削除
    /// - Parameter target: Targetデータ
    private func deleteTestTargetForUpdate(target: Target?) {
        try! realm.write {
            if let target = target {
                realm.delete(target)
            }
        }
    }
    
    @Test("Targetを更新", .tags(.realm, .target))
    func testUpdateTarget() {
        // 更新テスト用Targetを追加
        let targetID = "更新目標ID"
        addTestTargetForUpdate(targetID: targetID)
        
        // 更新テスト用Targetを更新
        let target = Target()
        target.targetID = targetID
        target.title = "更新テスト用目標2"
        target.year = 2025
        target.month = 2
        target.isYearlyTarget = true
        target.isDeleted = true
        target.updated_at = Date()
        realmManager.updateTarget(target: target)
        
        // 更新できているかチェック
        let result = realm.objects(Target.self).filter("targetID == '\(targetID)'").first
        #expect(result != nil, "更新後にTargetを取得不可")
        #expect(result!.title == target.title, "Targetタイトルを更新できていない")
        #expect(result!.year == target.year, "Target年を更新できていない")
        #expect(result!.month == target.month, "Target月を更新できていない")
        #expect(result!.isYearlyTarget == target.isYearlyTarget, "Target年間目標フラグを更新できていない")
        #expect(result!.isDeleted == target.isDeleted, "Target削除フラグを更新できていない")
        #expect(result!.updated_at == target.updated_at, "Target更新日時を更新できていない")
        
        // 更新テスト用Targetを削除
        deleteTestTargetForUpdate(target: result)
    }
    
    @Test("Targetを更新", .tags(.realm, .target))
    func testUpdateTargetIsDeleted() {
        // 更新テスト用Targetを追加
        let targetID = "更新目標ID"
        addTestTargetForUpdate(targetID: targetID)
        
        // 更新テスト用Targetを更新
        realmManager.updateTargetIsDeleted(targetID: targetID)
        
        // 更新できているかチェック
        let result = realm.objects(Target.self).filter("targetID == '\(targetID)'").first
        #expect(result != nil, "更新後にTargetを取得不可")
        #expect(result!.title == "更新テスト用目標", "更新対象外のTargetタイトルが更新されている")
        #expect(result!.year == 2024, "更新対象外のTarget年が更新されている")
        #expect(result!.month == 1, "更新対象外のTarget月が更新されている")
        #expect(result!.isYearlyTarget == false, "更新対象外のTarget年間目標フラグが更新されている")
        #expect(result!.isDeleted == true, "Target削除フラグを更新できていない")
        
        // 更新テスト用Targetを削除
        deleteTestTargetForUpdate(target: result)
    }
    
    /// updateTargetUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllTargetはdeleteAllRealmDataのテストで確認する
    
}
