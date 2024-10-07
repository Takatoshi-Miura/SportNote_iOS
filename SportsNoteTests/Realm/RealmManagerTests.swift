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

@Suite(.serialized)
struct RealmManagerTests {
    
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
        createTestData()
    }
    
    /// テスト用データを削除
    func deleteTestData() {
        // テスト終了後、デフォルトの設定を元に戻す
        Realm.Configuration.defaultConfiguration = originalDefaultConfiguration
        
        // テスト終了後にデータをクリーンアップ
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    /// テスト用データを作成
    func createTestData() {
        createTestGroups()
        createTestTaskDatas()
        createTestMeasures()
        createTestMemo()
        createTestTarget()
        createTestNote()
    }
    
    /// テスト用のGroupデータを作成
    private func createTestGroups() {
        let groups = [
            Group(title: "赤グループ", color: .red, order: 1),
            Group(title: "青グループ", color: .blue, order: 2),
            {
                let group = Group(title: "削除されたグループ", color: .gray, order: 3);
                group.isDeleted = true;
                return group
            }(),
            {
                let group = Group(title: "IDテスト用グループ", color: .green, order: 4);
                group.groupID = "グループID";
                return group
            }()
        ]
        
        try! realm.write {
            realm.add(groups)
        }
    }
    
    /// テスト用のTaskDataを作成
    private func createTestTaskDatas() {
        let tasks = [
            {
                let taskData = TaskData();
                taskData.groupID = "グループID";
                taskData.title = "課題タイトル1";
                taskData.cause = "課題原因1";
                taskData.order = 1;
                return taskData
            }(),
            {
                let taskData = TaskData();
                taskData.groupID = "グループID2";
                taskData.title = "課題タイトル2";
                taskData.cause = "課題原因2";
                taskData.order = 2;
                return taskData
            }(),
            {
                let taskData = TaskData();
                taskData.groupID = "グループID";
                taskData.title = "削除された課題";
                taskData.cause = "課題原因3";
                taskData.order = 3;
                taskData.isDeleted = true;
                return taskData
            }(),
            {
                let taskData = TaskData();
                taskData.groupID = "グループID";
                taskData.title = "完了した課題";
                taskData.cause = "課題原因4";
                taskData.order = 4;
                taskData.isComplete = true;
                return taskData
            }(),
            {
                let taskData = TaskData();
                taskData.groupID = "グループID";
                taskData.title = "IDテスト用課題";
                taskData.cause = "課題原因5";
                taskData.order = 5;
                taskData.taskID = "課題ID";
                return taskData
            }()
        ] as [TaskData]
        
        try! realm.write {
            realm.add(tasks)
        }
    }
    
    /// テスト用のMeasuresを作成
    private func createTestMeasures() {
        let measures = [
            {
                let measures = Measures();
                measures.taskID = "課題ID";
                measures.title = "対策タイトル1";
                measures.order = 1;
                return measures
            }(),
            {
                let measures = Measures();
                measures.taskID = "課題ID2";
                measures.title = "対策タイトル2";
                measures.order = 2;
                return measures
            }(),
            {
                let measures = Measures();
                measures.taskID = "課題ID";
                measures.title = "削除された対策";
                measures.order = 3;
                measures.isDeleted = true;
                return measures
            }(),
            {
                let measures = Measures();
                measures.measuresID = "対策ID"
                measures.taskID = "課題ID";
                measures.title = "IDテスト用対策";
                measures.order = 4;
                return measures
            }()
        ] as [Measures]
        
        try! realm.write {
            realm.add(measures)
        }
    }
    
    /// テスト用のMemoを作成
    private func createTestMemo() {
        let memos = [
            {
                let memo = Memo();
                memo.measuresID = "対策ID";
                memo.noteID = "ノートID";
                memo.detail = "メモ1";
                return memo
            }(),
            {
                let memo = Memo();
                memo.measuresID = "対策ID2";
                memo.noteID = "ノートID";
                memo.detail = "メモ2";
                return memo
            }(),
            {
                let memo = Memo();
                memo.measuresID = "対策ID";
                memo.noteID = "ノートID";
                memo.detail = "削除されたメモ";
                memo.isDeleted = true;
                return memo
            }(),
            {
                let memo = Memo();
                memo.memoID = "メモID";
                memo.measuresID = "対策ID";
                memo.noteID = "ノートID2";
                memo.detail = "IDテスト用メモ";
                return memo
            }()
        ] as [Memo]
        
        try! realm.write {
            realm.add(memos)
        }
    }
    
    /// テスト用のTargetを作成
    private func createTestTarget() {
        let targets = [
            {
                let target = Target();
                target.title = "月間目標";
                target.year = 2024;
                target.month = 1;
                target.isYearlyTarget = false;
                return target
            }(),
            {
                let target = Target();
                target.title = "年間目標";
                target.year = 2024;
                target.month = 1;
                target.isYearlyTarget = true;
                return target
            }(),
            {
                let target = Target();
                target.title = "削除された年間目標";
                target.year = 2024;
                target.month = 1;
                target.isYearlyTarget = true;
                target.isDeleted = true;
                return target
            }(),
            {
                let target = Target();
                target.targetID = "目標ID";
                target.title = "IDテスト用目標";
                target.year = 2024;
                target.month = 2;
                target.isYearlyTarget = false;
                return target
            }()
        ] as [Target]
        
        try! realm.write {
            realm.add(targets)
        }
    }
    
    /// テスト用のNoteを作成
    private func createTestNote() {
        let notes = [
            {
                let note = Note(freeWithTitle: "フリーノート");
                return note
            }(),
            {
                let note = Note(practiceWithPurpose: "目的", detail: "練習ノート");
                return note
            }(),
            {
                let note = Note(practiceWithPurpose: "目的", detail: "削除された練習ノート");
                note.isDeleted = true;
                return note
            }(),
            {
                let note = Note(practiceWithPurpose: "目的", detail: "IDテスト用練習ノート");
                note.noteID = "練習ノートID";
                return note
            }(),
            {
                let note = Note(tournamentWithTarget: "目的", consciousness: "意識すること", result: "結果");
                return note
            }(),
            {
                let note = Note(tournamentWithTarget: "目的2", consciousness: "意識すること2", result: "結果2");
                note.isDeleted = true;
                return note
            }(),
            {
                let note = Note(tournamentWithTarget: "目的", consciousness: "意識すること", result: "結果");
                note.noteID = "大会ノートID";
                return note
            }()
        ] as [Note]
        
        try! realm.write {
            realm.add(notes)
        }
    }
    
}
