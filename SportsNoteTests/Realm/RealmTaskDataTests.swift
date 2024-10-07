//
//  RealmTaskDataTests.swift
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
    
    @Test("TaskDataを全取得", .tags(.realm, .taskData))
    func testGetAllTask() {
        let result = realmManager.getAllTask()
        #expect(result.count == 5, "削除、完了したTaskDataも含めて全取得すること")
        deleteTestData()
    }
    
    @Test("TaskDataをID指定で取得", .tags(.realm, .taskData))
    func testGetTaskByID() {
        let result = realmManager.getTask(taskID: "課題ID")
        #expect(result.groupID == "グループID", "taskID指定でTaskData取得できていない")
        #expect(result.title == "IDテスト用課題", "taskID指定でTaskData取得できていない")
        #expect(result.cause == "課題原因5", "taskID指定でTaskData取得できていない")
        #expect(result.order == 5, "taskID指定でTaskData取得できていない")
        #expect(result.taskID == "課題ID", "taskID指定でTaskData取得できていない")
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
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
        deleteTestData()
    }
    
    /// updateTaskUserIDはprivateであること、ロジックは他のupdateメソッドと同じため、テストコードは書かない
    /// deleteAllTaskはdeleteAllRealmDataのテストで確認する
    
}
