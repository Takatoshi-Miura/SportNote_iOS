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
    
    // MARK: - 前処理, 後処理
    
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
    }
    
    // MARK: - Group
    
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
    
    @Test("Groupを全取得", .tags(.realm, .group))
    func testGetAllGroup() {
        let result = realmManager.getAllGroup()
        #expect(result.count == 4, "削除されたGroupも含めて全取得すること")
    }
    
    @Test("GroupをID指定で取得", .tags(.realm, .group))
    func testGetGroupByID() {
        let result = realmManager.getGroup(groupID: "グループID")
        #expect(result.title == "IDテスト用グループ")
        #expect(result.color == Color.green.rawValue)
    }
    
    @Test("Group配列(課題一覧用)を取得", .tags(.realm, .group))
    func testGetGroupArrayForTaskView() {
        let result = realmManager.getGroupArrayForTaskView()
        #expect(result.count == 3, "削除されたGroupは取得されないこと")
        #expect(result[0].title == "赤グループ", "orderの昇順でソートされていない")
        #expect(result[1].title == "青グループ", "orderの昇順でソートされていない")
        #expect(result[2].title == "IDテスト用グループ", "orderの昇順でソートされていない")
    }
    
    /// getGroupColor()はgetTask(noteID: noteID)のテストで担保
    
    @Test("Group数(課題一覧用)を取得", .tags(.realm, .group))
    func testGetNumberOfGroups() {
        let result = realmManager.getNumberOfGroups()
        #expect(result == 3, "削除されたGroupは取得されないこと")
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
    }
    
    /// updateGroupUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllGroupはdeleteAllRealmDataのテストで確認する
    
    // MARK: - TaskData
    
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
    
    @Test("TaskDataを全取得", .tags(.realm, .taskData))
    func testGetAllTask() {
        let result = realmManager.getAllTask()
        #expect(result.count == 5, "削除、完了したTaskDataも含めて全取得すること")
    }
    
    @Test("TaskDataをID指定で取得", .tags(.realm, .taskData))
    func testGetTaskByID() {
        let result = realmManager.getTask(taskID: "課題ID")
        #expect(result.groupID == "グループID", "taskID指定でTaskData取得できていない")
        #expect(result.title == "IDテスト用課題", "taskID指定でTaskData取得できていない")
        #expect(result.cause == "課題原因5", "taskID指定でTaskData取得できていない")
        #expect(result.order == 5, "taskID指定でTaskData取得できていない")
        #expect(result.taskID == "課題ID", "taskID指定でTaskData取得できていない")
    }
    
    /// getTask(noteID: String) -> [TaskData] は getMeasures(measuresID: String) で担保
    /// 以下のメソッドも他のテストで担保
    ///   getTaskArrayForAddNoteView(noteID: String) -> [TaskForAddNote]
    ///   getTaskArrayForTaskView() -> [[TaskData]]
    ///   getTaskArrayForAddNoteView() -> [TaskForAddNote]
    
    @Test("TaskDataをGroup,完了フラグ指定で取得", .tags(.realm, .taskData))
    func testGetTasksInGroup() {
        let result = realmManager.getTasksInGroup(ID: "グループID", isCompleted: false)
        #expect(result.count == 2, "削除、完了したTaskDataは除いて取得すること")
        #expect(result[0].title == "課題タイトル1", "order順にソートできていない")
        #expect(result[0].order == 1, "order順にソートできていない")
        #expect(result[1].title == "IDテスト用課題", "order順にソートできていない")
        #expect(result[1].order == 5, "order順にソートできていない")
    }
    
    @Test("TaskDataをGroup指定で取得", .tags(.realm, .taskData))
    func testGetTasksInGroupByID() {
        let result = realmManager.getTasksInGroup(ID: "グループID")
        #expect(result.count == 3, "削除したTaskDataは除いて取得すること")
        #expect(result[0].title == "課題タイトル1", "order順にソートできていない")
        #expect(result[0].order == 1, "order順にソートできていない")
        #expect(result[1].title == "完了した課題", "完了した課題を取得できていない")
        #expect(result[1].order == 4, "完了した課題を取得できていない")
        #expect(result[2].title == "IDテスト用課題", "order順にソートできていない")
        #expect(result[2].order == 5, "order順にソートできていない")
    }
    
    /// 更新テスト用TaskDataを追加
    /// - Parameter groupID: グループID
    private func addTestTaskDataForUpdate(taskID: String) {
        let taskData = TaskData()
        taskData.taskID = taskID
        taskData.groupID = "グループID"
        taskData.title = "更新テスト用課題"
        taskData.cause = "課題原因6"
        taskData.order = 6
        
        try! realm.write {
            realm.add(taskData)
        }
    }
    
    /// 更新テスト用TaskDataを削除
    /// - Parameter group: Groupデータ
    private func deleteTestTaskDataForUpdate(taskData: TaskData?) {
        try! realm.write {
            if let taskData = taskData {
                realm.delete(taskData)
            }
        }
    }
    
    @Test("TaskDataを更新", .tags(.realm, .taskData))
    func testUpdateTaskData() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        let taskData = TaskData()
        taskData.taskID = taskID
        taskData.groupID = "グループID2"
        taskData.title = "更新テスト用課題2"
        taskData.cause = "課題原因7"
        taskData.order = 7
        taskData.isComplete = true
        taskData.isDeleted = true
        taskData.updated_at = Date()
        realmManager.updateTask(task: taskData)
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == taskData.groupID, "TaskDataグループIDを更新できていない")
        #expect(result!.title == taskData.title, "TaskDataタイトルを更新できていない")
        #expect(result!.cause == taskData.cause, "TaskData原因を更新できていない")
        #expect(result!.order == taskData.order, "TaskData並び順を更新できていない")
        #expect(result!.isComplete == taskData.isComplete, "TaskData完了フラグを更新できていない")
        #expect(result!.isDeleted == taskData.isDeleted, "TaskData削除フラグを更新できていない")
        #expect(result!.updated_at == taskData.updated_at, "TaskData更新日時を更新できていない")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    @Test("TaskDataのタイトルを更新", .tags(.realm, .taskData))
    func testUpdateTaskDataTitle() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        realmManager.updateTaskTitle(taskID: taskID, title: "更新テスト用課題2")
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "グループID", "更新対象外のTaskDataグループIDが更新されている")
        #expect(result!.title == "更新テスト用課題2", "TaskDataタイトルを更新できていない")
        #expect(result!.cause == "課題原因6", "更新対象外のTaskData原因が更新されている")
        #expect(result!.order == 6, "更新対象外のTaskData並び順が更新されている")
        #expect(result!.isComplete == false, "更新対象外のTaskData完了フラグが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のTaskData削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    @Test("TaskDataの原因を更新", .tags(.realm, .taskData))
    func testUpdateTaskDataCause() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        realmManager.updateTaskCause(taskID: taskID, cause: "更新後の課題原因")
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "グループID", "更新対象外のTaskDataグループIDが更新されている")
        #expect(result!.title == "更新テスト用課題", "更新対象外のTaskDataタイトルが更新されている")
        #expect(result!.cause == "更新後の課題原因", "TaskData原因が更新されていない")
        #expect(result!.order == 6, "更新対象外のTaskData並び順が更新されている")
        #expect(result!.isComplete == false, "更新対象外のTaskData完了フラグが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のTaskData削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    @Test("TaskDataの並び順を更新", .tags(.realm, .taskData))
    func testUpdateTaskDataOrder() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        let taskData = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        realmManager.updateTaskOrder(task: taskData!, order: 7)
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "グループID", "更新対象外のTaskDataグループIDが更新されている")
        #expect(result!.title == "更新テスト用課題", "更新対象外のTaskDataタイトルが更新されている")
        #expect(result!.cause == "課題原因6", "更新対象外のTaskData原因が更新されている")
        #expect(result!.order == 7, "TaskData並び順が更新されていない")
        #expect(result!.isComplete == false, "更新対象外のTaskData完了フラグが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のTaskData削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    /// updateTaskOrder(taskArray: [[TaskData]])は保留
    
    @Test("TaskDataのGroupIDを更新", .tags(.realm, .taskData))
    func testUpdateTaskGroupId() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        let taskData = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        realmManager.updateTaskGroupId(task: taskData!, groupID: "更新後グループID")
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "更新後グループID", "TaskDataグループIDが更新されていない")
        #expect(result!.title == "更新テスト用課題", "更新対象外のTaskDataタイトルが更新されている")
        #expect(result!.cause == "課題原因6", "更新対象外のTaskData原因が更新されている")
        #expect(result!.order == 6, "更新対象外のTaskData並び順が更新されている")
        #expect(result!.isComplete == false, "更新対象外のTaskData完了フラグが更新されている")
        #expect(result!.isDeleted == false, "更新対象外のTaskData削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    @Test("TaskDataの完了フラグを更新", .tags(.realm, .taskData))
    func testUpdateTaskIsCompleted() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        let taskData = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        realmManager.updateTaskIsCompleted(task: taskData!, isCompleted: true)
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "グループID", "更新対象外のTaskDataグループIDが更新されている")
        #expect(result!.title == "更新テスト用課題", "更新対象外のTaskDataタイトルが更新されている")
        #expect(result!.cause == "課題原因6", "更新対象外のTaskData原因が更新されている")
        #expect(result!.order == 6, "更新対象外のTaskData並び順が更新されている")
        #expect(result!.isComplete == true, "TaskData完了フラグが更新されていない")
        #expect(result!.isDeleted == false, "更新対象外のTaskData削除フラグが更新されている")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    @Test("TaskDataの削除フラグを更新", .tags(.realm, .taskData))
    func testUpdateTaskIsDeleted() {
        // 更新テスト用TaskDataを追加
        let taskID = "更新課題ID"
        addTestTaskDataForUpdate(taskID: taskID)
        
        // 更新テスト用TaskDataを更新
        let taskData = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        realmManager.updateTaskIsDeleted(task: taskData!)
        
        // 更新できているかチェック
        let result = realm.objects(TaskData.self).filter("taskID == '\(taskID)'").first
        #expect(result != nil, "更新後にTaskDataを取得不可")
        #expect(result!.groupID == "グループID", "更新対象外のTaskDataグループIDが更新されている")
        #expect(result!.title == "更新テスト用課題", "更新対象外のTaskDataタイトルが更新されている")
        #expect(result!.cause == "課題原因6", "更新対象外のTaskData原因が更新されている")
        #expect(result!.order == 6, "更新対象外のTaskData並び順が更新されている")
        #expect(result!.isComplete == false, "更新対象外のTaskData完了フラグが更新されている")
        #expect(result!.isDeleted == true, "TaskData削除フラグが更新されていない")
        
        // 更新テスト用Groupを削除
        deleteTestTaskDataForUpdate(taskData: result)
    }
    
    /// updateTaskUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllTaskはdeleteAllRealmDataのテストで確認する
    
}
