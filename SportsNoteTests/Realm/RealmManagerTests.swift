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
        createTestData()
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
    
    /// テスト用データを作成
    private func createTestData() {
        createTestGroups()
        createTestTaskDatas()
        createTestMeasures()
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
    
}
