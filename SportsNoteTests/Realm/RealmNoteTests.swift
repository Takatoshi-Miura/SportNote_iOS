//
//  RealmNoteTests.swift
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
    
    @Test("Noteを全取得", .tags(.realm, .note))
    func testGetAllNote() {
        let result = realmManager.getAllNote()
        #expect(result.count == 7, "削除したNoteも含めて全取得すること")
    }
    
    @Test("NoteをID指定で取得", .tags(.realm, .note))
    func testGetNoteByID() {
        let result = realmManager.getNote(ID: "練習ノートID")
        #expect(result != nil, "ID指定でNote取得できていない")
        #expect(result.detail == "IDテスト用練習ノート", "ID指定でNote取得できていない")
    }
    
    @Test("NoteをNoteType指定で取得", .tags(.realm, .note))
    func testGetNoteByNoteType() {
        let result = realmManager.getNote(noteType: NoteType.practice.rawValue)
        #expect(result != nil, "NoteType指定でNote取得できていない")
        #expect(result.count == 2, "削除されたノートは除いて取得")
    }
    
    /// getNote(memoArray: [Memo])はgetNote(ID: String)に依存するためテストしない
    
    @Test("Noteをフリーノート指定で取得", .tags(.realm, .note))
    func testGetFreeNote() {
        let result = realmManager.getFreeNote()
        #expect(result != nil, "フリーノート取得できていない")
        #expect(result.title == "フリーノート", "フリーノート取得できていない")
    }
    
    @Test("Noteを練習・大会ノート指定で取得", .tags(.realm, .note))
    func testGetPracticeTournamentNote() {
        let result = realmManager.getPracticeTournamentNote()
        #expect(result != nil, "練習・大会ノート取得できていない")
        #expect(result.count == 4, "削除されたノートは除いて取得")
    }
    
    /// getPracticeTournamentNote(searchWord: String)はgetNote(memoArray: [Memo])に依存するためテストしない
    /// getPracticeTournamentNote(taskIDs: [String])は複数のメソッドに依存するためテストしない
    
    @Test("Noteを日付指定で取得", .tags(.realm, .note))
    func testGetNoteByDate() {
        let result = realmManager.getNote(date: Date())
        #expect(result != nil, "日付指定でノート取得できていない")
        #expect(result.count == 4, "日付指定でノート取得できていない")
    }
    
    /// 更新テスト用Noteを追加
    /// - Parameter noteID: ノートID
    private func addTestNoteForUpdate(noteID: String) {
        let note = Note()
        note.noteID = noteID
        note.noteType = NoteType.practice.rawValue
        note.isDeleted = false
        note.title = "フリーノート用タイトル"
        note.date = Date()
        note.weather = Weather.sunny.rawValue
        note.temperature = 20
        note.condition = "体調"
        note.reflection = "反省"
        note.purpose = "練習目的"
        note.detail = "練習内容"
        note.target = "目標"
        note.consciousness = "意識すること"
        note.result = "結果"
        
        try! realm.write {
            realm.add(note)
        }
    }
    
    /// 更新テスト用Noteを削除
    /// - Parameter note: Noteデータ
    private func deleteTestNoteForUpdate(note: Note?) {
        try! realm.write {
            if let note = note {
                realm.delete(note)
            }
        }
    }
    
    @Test("Noteを更新", .tags(.realm, .note))
    func testUpdateNote() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        let note = Note()
        note.noteID = noteID
        note.noteType = NoteType.tournament.rawValue
        note.isDeleted = true
        note.title = "フリーノート用タイトル2"
        note.date = Date()
        note.weather = Weather.rainy.rawValue
        note.temperature = 30
        note.condition = "体調2"
        note.reflection = "反省2"
        note.purpose = "練習目的2"
        note.detail = "練習内容2"
        note.target = "目標2"
        note.consciousness = "意識すること2"
        note.result = "結果2"
        realmManager.updateNote(note: note)
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == note.isDeleted, "Note削除フラグを更新できていない")
        #expect(result!.title == note.title, "Noteタイトルを更新できていない")
        #expect(result!.date == note.date, "Note日付を更新できていない")
        #expect(result!.weather == note.weather, "Note天気を更新できていない")
        #expect(result!.temperature == note.temperature, "Note気温を更新できていない")
        #expect(result!.condition == note.condition, "Note体調を更新できていない")
        #expect(result!.reflection == note.reflection, "Note反省を更新できていない")
        #expect(result!.purpose == note.purpose, "Note目的を更新できていない")
        #expect(result!.detail == note.detail, "Note内容を更新できていない")
        #expect(result!.target == note.target, "Note目標を更新できていない")
        #expect(result!.consciousness == note.consciousness, "Note意識することを更新できていない")
        #expect(result!.result == note.result, "Note結果を更新できていない")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Noteタイトルを更新", .tags(.realm, .note))
    func testUpdateNoteTitle() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteTitle(noteID: noteID, title: "フリーノート用タイトル2")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル2", "Noteタイトルを更新できていない")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note内容を更新", .tags(.realm, .note))
    func testUpdateNoteDetail() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteDetail(noteID: noteID, detail: "練習内容2")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容2", "Note内容が更新されていない")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note日付を更新", .tags(.realm, .note))
    func testUpdateNoteDate() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        let date = Date()
        realmManager.updateNoteDate(noteID: noteID, date: date)
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        #expect(result!.date == date, "Note日付が更新されていない")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note天気を更新", .tags(.realm, .note))
    func testUpdateNoteWeather() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteWeather(noteID: noteID, weather: Weather.cloudy.rawValue)
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.cloudy.rawValue, "Note天気が更新されていない")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note気温を更新", .tags(.realm, .note))
    func testUpdateNoteTemperature() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteTemperature(noteID: noteID, temperature: 30)
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 30, "Note気温が更新されていない")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note体調を更新", .tags(.realm, .note))
    func testUpdateNoteCondition() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteCondition(noteID: noteID, condition: "体調２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調２", "Note体調が更新されていない")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note練習目的を更新", .tags(.realm, .note))
    func testUpdateNotePurpose() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNotePurpose(noteID: noteID, purpose: "練習目的２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的２", "Note目的が更新されていない")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note目標を更新", .tags(.realm, .note))
    func testUpdateNoteTarget() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteTarget(noteID: noteID, target: "目標２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標２", "Note目標が更新されていない")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note意識することを更新", .tags(.realm, .note))
    func testUpdateNoteConsciousness() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteConsciousness(noteID: noteID, consciousness: "意識すること２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること２", "Note意識することが更新されていない")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note結果を更新", .tags(.realm, .note))
    func testUpdateNoteResult() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteResult(noteID: noteID, result: "結果２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果２", "Note結果が更新されていない")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note反省を更新", .tags(.realm, .note))
    func testUpdateNoteReflection() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteReflection(noteID: noteID, reflection: "反省２")
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のNote削除フラグが更新されている")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省２", "Note反省が更新されていない")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    @Test("Note削除フラグを更新", .tags(.realm, .note))
    func testUpdateNoteIsDeleted() {
        // 更新テスト用Noteを追加
        let noteID = "更新ノートID"
        addTestNoteForUpdate(noteID: noteID)
        
        // 更新テスト用Noteを更新
        realmManager.updateNoteIsDeleted(noteID: noteID)
        
        // 更新できているかチェック
        let result = realm.objects(Note.self).filter("noteID == '\(noteID)'").first
        #expect(result != nil, "更新後にNoteを取得不可")
        #expect(result!.noteType == NoteType.practice.rawValue, "更新対象外のNoteTypeが更新されている")
        #expect(result!.isDeleted == true, "Note削除フラグが更新されていない")
        #expect(result!.title == "フリーノート用タイトル", "更新対象外のNoteタイトルが更新されている")
        #expect(result!.weather == Weather.sunny.rawValue, "更新対象外のNote天気が更新されている")
        #expect(result!.temperature == 20, "更新対象外のNote気温が更新されている")
        #expect(result!.condition == "体調", "更新対象外のNote体調が更新されている")
        #expect(result!.reflection == "反省", "更新対象外のNote反省が更新されている")
        #expect(result!.purpose == "練習目的", "更新対象外のNote目的が更新されている")
        #expect(result!.detail == "練習内容", "更新対象外のNote内容が更新されている")
        #expect(result!.target == "目標", "更新対象外のNote目標が更新されている")
        #expect(result!.consciousness == "意識すること", "更新対象外のNote意識することが更新されている")
        #expect(result!.result == "結果", "更新対象外のNote結果が更新されている")
        
        // 更新テスト用Noteを削除
        deleteTestNoteForUpdate(note: result)
    }
    
    /// updateNoteUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllNoteはdeleteAllRealmDataのテストで確認する
    
}
