//
//  RealmMemoTests.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/09/05.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

@testable import _11_SportNote
import Testing
import Foundation
import RealmSwift

extension RealmManagerTests {
    
    @Test("Memoを全取得", .tags(.realm, .memo))
    func testGetAllMemo() {
        let result = realmManager.getAllMemo()
        #expect(result.count == 4, "削除したMemoも含めて全取得すること")
    }
    
    /// getMemo(measuresID: String)はgetNote(memoArray: [Memo])に依存するためテストしない
    
    @Test("Memoを検索して取得", .tags(.realm, .memo))
    func testGetMemoBySearchWord() {
        let result = realmManager.getMemo(searchWord: "メモ")
        #expect(result.count == 3, "削除したMemoは除いて取得すること")
        #expect(result[0].detail == "IDテスト用メモ", "検索ワードでメモを取得できていない")
    }
    
    @Test("MemoをNoteID指定で取得", .tags(.realm, .memo))
    func testGetMemoByNoteID() {
        let result = realmManager.getMemo(noteID: "ノートID2")
        #expect(result.count == 1, "NoteID指定でメモを取得できていない")
        #expect(result[0].detail == "IDテスト用メモ", "NoteID指定でメモを取得できていない")
    }
    
    @Test("MemoをNoteID,MeasuresID指定で取得", .tags(.realm, .memo))
    func testGetMemoByNoteIDAndMeasuresID() {
        let result = realmManager.getMemo(noteID: "ノートID", measuresID: "対策ID")
        #expect(result != nil, "NoteID,MeasuresID指定でメモを取得できていない")
        #expect(result!.detail == "メモ1", "NoteID,MeasuresID指定でメモを取得できていない")
    }
    
    /// 更新テスト用Memoを追加
    /// - Parameter memoID: メモID
    private func addTestMemoForUpdate(memoID: String) {
        let memo = Memo()
        memo.memoID = memoID
        memo.detail = "更新テスト用メモ"
        memo.noteID = "更新ノートID"
        
        try! realm.write {
            realm.add(memo)
        }
    }
    
    /// 更新テスト用Memoを削除
    /// - Parameter memo: Memoデータ
    private func deleteTestMemoForUpdate(memo: Memo?) {
        try! realm.write {
            if let memo = memo {
                realm.delete(memo)
            }
        }
    }
    
    @Test("Memoを更新", .tags(.realm, .memo))
    func testUpdateMemo() {
        // 更新テスト用Memoを追加
        let memoID = "更新メモID"
        addTestMemoForUpdate(memoID: memoID)
        
        // 更新テスト用Memoを更新
        let memo = Memo()
        memo.memoID = memoID
        memo.detail = "更新テスト用メモ２"
        memo.isDeleted = true
        memo.updated_at = Date()
        realmManager.updateMemo(memo: memo)
        
        // 更新できているかチェック
        let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
        #expect(result != nil, "更新後にMemoを取得不可")
        #expect(result!.detail == memo.detail, "Memo内容を更新できていない")
        #expect(result!.isDeleted == memo.isDeleted, "Memo削除フラグを更新できていない")
        #expect(result!.updated_at == memo.updated_at, "Memo更新日時を更新できていない")
        
        // 更新テスト用Memoを削除
        deleteTestMemoForUpdate(memo: result)
    }
    
    @Test("Memo内容を更新", .tags(.realm, .memo))
    func testUpdateMemoDetail() {
        // 更新テスト用Memoを追加
        let memoID = "更新メモID"
        addTestMemoForUpdate(memoID: memoID)
        
        // 更新テスト用Memoを更新
        realmManager.updateMemoDetail(memoID: memoID, detail: "更新テスト用メモ２")
        
        // 更新できているかチェック
        let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
        #expect(result != nil, "更新後にMemoを取得不可")
        #expect(result!.detail == "更新テスト用メモ２", "Memo内容を更新できていない")
        #expect(result!.isDeleted == false, "更新対象外のMemo削除フラグが更新されている")
        
        // 更新テスト用Memoを削除
        deleteTestMemoForUpdate(memo: result)
    }
    
    @Test("Memo削除フラグをMemoID指定で更新", .tags(.realm, .memo))
    func testUpdateMemoIsDeletedByMemoID() {
        // 更新テスト用Memoを追加
        let memoID = "更新メモID"
        addTestMemoForUpdate(memoID: memoID)
        
        // 更新テスト用Memoを更新
        realmManager.updateMemoIsDeleted(memoID: memoID)
        
        // 更新できているかチェック
        let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
        #expect(result != nil, "更新後にMemoを取得不可")
        #expect(result!.detail == "更新テスト用メモ", "更新対象外のMemo内容が更新されている")
        #expect(result!.isDeleted == true, "Memo削除フラグが更新されていない")
        
        // 更新テスト用Memoを削除
        deleteTestMemoForUpdate(memo: result)
    }
    
    @Test("Memo削除フラグをNoteID指定で更新", .tags(.realm, .memo))
    func testUpdateMemoIsDeletedByNoteID() {
        // 更新テスト用Memoを追加
        let memoID = "更新メモID"
        addTestMemoForUpdate(memoID: memoID)
        
        // 更新テスト用Memoを更新
        realmManager.updateMemoIsDeleted(noteID: "更新ノートID")
        
        // 更新できているかチェック
        let result = realm.objects(Memo.self).filter("memoID == '\(memoID)'").first
        #expect(result != nil, "更新後にMemoを取得不可")
        #expect(result!.detail == "更新テスト用メモ", "更新対象外のMemo内容が更新されている")
        #expect(result!.isDeleted == true, "Memo削除フラグが更新されていない")
        
        // 更新テスト用Memoを削除
        deleteTestMemoForUpdate(memo: result)
    }
    
    /// updateMemoUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllMemoはdeleteAllRealmDataのテストで確認する
    
}
