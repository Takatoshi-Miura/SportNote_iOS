//
//  RealmMeasuresTests.swift
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
    
    @Test("Measuresを全取得", .tags(.realm, .measures))
    func testGetAllMeasures() {
        let result = realmManager.getAllMeasures()
        #expect(result.count == 4, "削除したMeasuresも含めて全取得すること")
    }
    
    @Test("MeasuresをmeasuresID指定で取得", .tags(.realm, .measures))
    func testGetMeasuresByID() {
        let result = realmManager.getMeasures(measuresID: "対策ID")
        #expect(result.measuresID == "対策ID", "measuresID指定でMeasures取得できていない")
        #expect(result.taskID == "課題ID", "measuresID指定でMeasures取得できていない")
        #expect(result.title == "IDテスト用対策", "measuresID指定でMeasures取得できていない")
        #expect(result.order == 4, "measuresID指定でMeasures取得できていない")
    }
    
    @Test("MeasuresをtaskID指定で取得", .tags(.realm, .measures))
    func testGetMeasuresTitleInTask() {
        let result = realmManager.getMeasuresTitleInTask(taskID: "課題ID")
        #expect(result == "対策タイトル1", "taskID指定でMeasures取得できていない")
    }
    
    @Test("Measures(最優先)をtaskID指定で取得", .tags(.realm, .measures))
    func testGetPriorityMeasuresInTask() {
        let result = realmManager.getPriorityMeasuresInTask(taskID: "課題ID")
        #expect(result != nil, "taskID指定でMeasures取得できていない")
        #expect(result!.taskID == "課題ID", "measuresID指定でMeasures取得できていない")
        #expect(result!.title == "対策タイトル1", "measuresID指定でMeasures取得できていない")
        #expect(result!.order == 1, "measuresID指定でMeasures取得できていない")
    }
    
    @Test("Measures(最優先)配列をtaskID指定で取得", .tags(.realm, .measures))
    func testGetMeasuresInTask() {
        let result = realmManager.getMeasuresInTask(ID: "課題ID")
        #expect(result.isEmpty == false, "taskID指定でMeasures取得できていない")
        #expect(result.count == 2, "削除されたMeasuresを除いて取得すること")
        #expect(result[0].title == "対策タイトル1", "measuresID指定でMeasures取得できていない")
        #expect(result[0].order == 1, "orderの昇順でMeasures取得できていない")
        #expect(result[1].title == "IDテスト用対策", "measuresID指定でMeasures取得できていない")
        #expect(result[1].order == 4, "orderの昇順でMeasures取得できていない")
    }
    
    /// 更新テスト用Measuresを追加
    /// - Parameter measuresID: グループID
    private func addTestMeasuresForUpdate(measuresID: String) {
        let measures = Measures()
        measures.measuresID = measuresID
        measures.taskID = "課題ID"
        measures.title = "更新テスト用対策"
        measures.order = 5
        
        try! realm.write {
            realm.add(measures)
        }
    }
    
    /// 更新テスト用Measuresを削除
    /// - Parameter measures: Measuresデータ
    private func deleteTestMeasuresForUpdate(measures: Measures?) {
        try! realm.write {
            if let measures = measures {
                realm.delete(measures)
            }
        }
    }
    
    @Test("Measuresを更新", .tags(.realm, .measures))
    func testUpdateMeasures() {
        // 更新テスト用Measuresを追加
        let measuresID = "更新対策ID"
        addTestMeasuresForUpdate(measuresID: measuresID)
        
        // 更新テスト用Measuresを更新
        let measures = Measures()
        measures.measuresID = measuresID
        measures.title = "更新テスト用対策2"
        measures.order = 6
        measures.isDeleted = true
        measures.updated_at = Date()
        realmManager.updateMeasures(measures: measures)
        
        // 更新できているかチェック
        let result = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
        #expect(result != nil, "更新後にMeasuresを取得不可")
        #expect(result!.title == measures.title, "Measuresタイトルを更新できていない")
        #expect(result!.order == measures.order, "Measures並び順を更新できていない")
        #expect(result!.isDeleted == measures.isDeleted, "Measures削除フラグを更新できていない")
        #expect(result!.updated_at == measures.updated_at, "Measures更新日時を更新できていない")
        
        // 更新テスト用Measuresを削除
        deleteTestMeasuresForUpdate(measures: result)
    }
    
    @Test("Measuresタイトルを更新", .tags(.realm, .measures))
    func testUpdateMeasuresTitle() {
        // 更新テスト用Measuresを追加
        let measuresID = "更新対策ID"
        addTestMeasuresForUpdate(measuresID: measuresID)
        
        // 更新テスト用Measuresを更新
        realmManager.updateMeasuresTitle(measuresID: measuresID, title: "更新テスト用対策2")
        
        // 更新できているかチェック
        let result = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
        #expect(result != nil, "更新後にMeasuresを取得不可")
        #expect(result!.title == "更新テスト用対策2", "Measuresタイトルを更新できていない")
        #expect(result!.order == 5, "更新対象外のMeasures並び順が更新されている")
        #expect(result!.isDeleted == false, "更新対象外のMeasures削除フラグが更新されている")
        
        // 更新テスト用Measuresを削除
        deleteTestMeasuresForUpdate(measures: result)
    }
    
    @Test("Measures並び順を更新", .tags(.realm, .measures))
    func testUpdateMeasuresOrder() {
        // 更新テスト用Measuresを追加
        let measuresID = "更新対策ID"
        addTestMeasuresForUpdate(measuresID: measuresID)
        
        // 更新テスト用Measuresを更新
        var measuresArray: [Measures] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Measures.self)
        for measures in realmArray {
            measuresArray.append(measures)
        }
        realmManager.updateMeasuresOrder(measuresArray: measuresArray)
        
        // 更新できているかチェック
        let result = realm.objects(Measures.self)
        #expect(result != nil, "更新後にMeasuresを取得不可")
        #expect(result.count == 5, "更新後にMeasuresを取得不可")
        #expect(result[0].title == "対策タイトル1", "Measures並び順を更新できていない")
        #expect(result[0].order == 0, "Measures並び順を更新できていない")
        #expect(result[4].title == "更新テスト用対策", "Measures並び順を更新できていない")
        #expect(result[4].order == 4, "Measures並び順を更新できていない")
        
        // 更新テスト用Measuresを削除
        let measures = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
        deleteTestMeasuresForUpdate(measures: measures)
    }
    
    @Test("Measures削除フラグを更新", .tags(.realm, .measures))
    func testUpdateMeasuresIsDeleted() {
        // 更新テスト用Measuresを追加
        let measuresID = "更新対策ID"
        addTestMeasuresForUpdate(measuresID: measuresID)
        
        // 更新テスト用Measuresを更新
        let result = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
        realmManager.updateMeasuresIsDeleted(measures: result!)
        
        // 更新できているかチェック
        let result2 = realm.objects(Measures.self).filter("measuresID == '\(measuresID)'").first
        #expect(result2 != nil, "更新後にMeasuresを取得不可")
        #expect(result2!.title == "更新テスト用対策", "更新対象外のMeasuresタイトルが更新されている")
        #expect(result2!.order == 5, "更新対象外のMeasures並び順が更新されている")
        #expect(result2!.isDeleted == true, "Measures削除フラグが更新されていない")
        
        // 更新テスト用Measuresを削除
        deleteTestMeasuresForUpdate(measures: result2)
    }
    
    /// updateMeasuresUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllMeasuresはdeleteAllRealmDataのテストで確認する
    
}
