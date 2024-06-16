//
//  RealmManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/03.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift
import Foundation

class RealmManager {
    
    /// Realmにデータを作成
    /// - Parameters:
    ///    - object: Realmオブジェクト
    /// - Returns: 成功失敗
    func createRealm(object: Object) -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(object)
            }
        } catch {
            return false
        }
        return true
    }
    
    /// Realmにデータを作成(既に存在するオブジェクトはUpdate)
    /// - Parameters:
    ///    - object: Realmオブジェクト
    /// - Returns: 成功失敗
    func createRealmWithUpdate(objects: [Object]) -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(objects, update: .modified)
            }
        } catch {
            return false
        }
        return true
    }
    
    /// RealmのデータのUserIDを一括変更
    /// - Parameters:
    ///    - userID: ユーザーID
    func updateAllRealmUserID(userID: String) {
        updateGroupUserID(userID: userID)
        updateTaskUserID(userID: userID)
        updateMeasuresUserID(userID: userID)
        updateMemoUserID(userID: userID)
        updateTargetUserID(userID: userID)
        updateNoteUserID(userID: userID)
    }
    
    /// Realmのデータを全削除
    func deleteAllRealmData() {
        deleteAllGroup()
        deleteAllTask()
        deleteAllMeasures()
        deleteAllMemo()
        deleteAllTarget()
        deleteAllNote()
    }
    
}

// MARK: - Group

extension RealmManager {
    
    /// Realmのグループを全取得
    /// - Returns: 全グループデータ
    func getAllGroup() -> [Group] {
        var groupArray: [Group] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Group.self)
        for group in realmArray {
            groupArray.append(group)
        }
        return groupArray
    }
    
    /// Realmのグループを取得
    /// - Parameters:
    ///   - groupID: 課題ID
    /// - Returns: グループデータ
    func getGroup(groupID: String) -> Group {
        let realm = try! Realm()
        let result = realm.objects(Group.self)
            .filter("groupID == '\(groupID)'")
            .filter("(isDeleted == false)")
            .first
        return result ?? Group()
    }
    
    /// TaskViewController用Group配列を取得
    /// - Returns: Group配列
    func getGroupArrayForTaskView() -> [Group] {
        var groupArray: [Group] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(Group.self)
                            .filter("(isDeleted == false)")
                            .sorted(by: sortProperties)
        for group in results {
            groupArray.append(group)
        }
        return groupArray
    }
    
    /// Noteに含まれるGroupカラーを取得
    /// - Returns: Groupカラー
    func getGroupColor(noteID: String) -> UIColor {
        let taskArray = getTask(noteID: noteID)
        if !taskArray.isEmpty {
            let task = taskArray.first!
            let group = getGroup(groupID: task.groupID)
            return Color.allCases[group.color].color
        } else {
            return UIColor.white
        }
    }
    
    /// TaskViewControllerに表示するGroupの個数を取得
    /// - Returns: Group数
    func getNumberOfGroups() -> Int {
        let groupArray = getGroupArrayForTaskView()
        return groupArray.count
    }
    
    /// Realmのグループを更新
    /// - Parameters:
    ///    - group: Realmオブジェクト
    func updateGroup(group: Group) {
        let realm = try! Realm()
        let result = realm.objects(Group.self)
            .filter("groupID == '\(group.groupID)'").first
        try! realm.write {
            result?.title = group.title
            result?.color = group.color
            result?.order = group.order
            result?.isDeleted = group.isDeleted
            result?.updated_at = group.updated_at
        }
    }
    
    /// グループのタイトルを更新
    /// - Parameters:
    ///   - groupID: 更新したいグループのID
    ///   - title: 新しいタイトル文字列
    func updateGroupTitle(groupID: String, title: String) {
        let realm = try! Realm()
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        try! realm.write {
            result?.title = title
            result?.updated_at = Date()
        }
    }

    /// グループの色を更新
    /// - Parameters:
    ///   - groupID: 更新したいグループのID
    ///   - color: 新しい色番号
    func updateGroupColor(groupID: String, color: Int) {
        let realm = try! Realm()
        let result = realm.objects(Group.self).filter("groupID == '\(groupID)'").first
        try! realm.write {
            result?.color = color
            result?.updated_at = Date()
        }
    }

    /// グループの並び順を更新
    /// - Parameters:
    ///   - groupArray: グループ配列
    func updateGroupOrder(groupArray: [Group]) {
        let realm = try! Realm()
        var index = 0
        for group in groupArray {
            let result = realm.objects(Group.self).filter("groupID == '\(group.groupID)'").first
            try! realm.write {
                result?.order = index
                result?.updated_at = Date()
            }
            index += 1
        }
    }

    /// グループの削除フラグを更新
    /// - Parameters:
    ///   - group: グループ
    func updateGroupIsDeleted(group: Group) {
        let realm = try! Realm()
        let result = realm.objects(Group.self).filter("groupID == '\(group.groupID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }

    /// ユーザーIDを更新
    /// - Parameters:
    ///   - userID: ユーザーID
    private func updateGroupUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Group.self)
        for group in result {
            try! realm.write {
                group.userID = userID
            }
        }
    }
    
    /// Realmのグループを全削除
    private func deleteAllGroup() {
        let realm = try! Realm()
        let groups = realm.objects(Group.self)
        do{
          try realm.write{
            realm.delete(groups)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - TaskData

extension RealmManager {
    
    /// Realmの課題を全取得
    /// - Returns: 全課題データ
    func getAllTask() -> [TaskData] {
        var taskArray: [TaskData] = []
        let realm = try! Realm()
        let realmArray = realm.objects(TaskData.self)
        for task in realmArray {
            taskArray.append(task)
        }
        return taskArray
    }
    
    /// Realmの課題を取得
    /// - Parameters:
    ///   - taskID: 課題ID
    /// - Returns: 課題データ
    func getTask(taskID: String) -> TaskData {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
            .filter("taskID == '\(taskID)'")
            .filter("(isDeleted == false)")
            .first
        return result ?? TaskData()
    }
    
    /// Realmの課題を取得
    /// - Parameters:
    ///   - noteID: ノートID
    /// - Returns: 課題データ
    func getTask(noteID: String) -> [TaskData] {
        var taskArray = [TaskData]()
        
        let memoArray = getMemo(noteID: noteID)
        var measuresArray = [Measures]()
        for memo in memoArray {
            let measures = getMeasures(measuresID: memo.measuresID)
            measuresArray.append(measures)
        }
        for measures in measuresArray {
            let task = getTask(taskID: measures.taskID)
            taskArray.append(task)
        }
        
        return taskArray
    }
    
    /// Realmの課題を取得(ノートViewer用)
    /// - Parameters:
    ///   - noteID: ノートID
    /// - Returns: 課題データ
    func getTaskArrayForAddNoteView(noteID: String) -> [TaskForAddNote] {
        var taskForAddNoteArray = [TaskForAddNote]()
        
        let taskArray = getTask(noteID: noteID)
        for task in taskArray {
            let taskForAddNote = TaskForAddNote(task: task)
            taskForAddNoteArray.append(taskForAddNote)
        }
        
        return taskForAddNoteArray
    }
    
    /// TaskViewController用task配列を返却
    /// - Returns: Task配列[[task][task, task]…]の形
    func getTaskArrayForTaskView() -> [[TaskData]] {
        var taskArray: [[TaskData]] = [[TaskData]]()
        let groupArray: [Group] = getGroupArrayForTaskView()
        for group in groupArray {
            let tasks = getTasksInGroup(ID: group.groupID, isCompleted: false)
            taskArray.append(tasks)
        }
        return taskArray
    }
    
    /// AddPracticeNoteViewController用task配列を返却(未解決の課題をグループ関係なく取得)
    /// - Returns: Task配列[task, task…]の形
    func getTaskArrayForAddNoteView() -> [TaskForAddNote] {
        var taskArray = [TaskForAddNote]()
        let groupArray: [Group] = getGroupArrayForTaskView()
        for group in groupArray {
            let tasks = getTasksInGroup(ID: group.groupID, isCompleted: false)
            for task in tasks {
                let taskForAddNote = TaskForAddNote(task: task)
                // 対策未設定の課題は表示しない
                if getPriorityMeasuresInTask(taskID: task.taskID) != nil {
                    taskArray.append(taskForAddNote)
                }
            }
        }
        return taskArray
    }
    
    /// NoteFilterViewController用FilteredTask配列を返却
    /// - Parameters:
    ///   - isFilter: チェックの保存状態を反映するか否か
    /// - Returns: Task配列[[FilteredTask][FilteredTask, FilteredTask]…]の形
    func getTaskArrayForNoteFilterView(isFilter: Bool) -> [[FilteredTask]] {
        var filteredTaskArray: [[FilteredTask]] = [[FilteredTask]]()
        let userDefaults = UserDefaults.standard
        var filterTaskIDArray = [String]()
        if let idArray = userDefaults.array(forKey: "filterTaskID") {
            filterTaskIDArray = idArray as! [String]
        }
        let groupArray: [Group] = getGroupArrayForTaskView()
        
        for group in groupArray {
            var array = [FilteredTask]()
            let tasks = getTasksInGroup(ID: group.groupID)
            for task in tasks {
                var filteredTask = FilteredTask(task: task)
                // チェックの保存状態を反映
                if isFilter && !filterTaskIDArray.contains(filteredTask.taskID) {
                    filteredTask.isFilter = false
                }
                array.append(filteredTask)
            }
            filteredTaskArray.append(array)
        }
        
        return filteredTaskArray
    }
    
    /// グループに含まれる課題を取得
    /// - Parameters:
    ///   - groupID: グループID
    ///   - isCompleted: 完了or未完了
    /// - Returns: グループに含まれる課題
    func getTasksInGroup(ID groupID: String, isCompleted: Bool) -> [TaskData] {
        var taskArray: [TaskData] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(TaskData.self)
                            .filter("(groupID == '\(groupID)') && (isDeleted == false) && (isComplete == \(String(isCompleted)))")
                            .sorted(by: sortProperties)
        for task in results {
            taskArray.append(task)
        }
        return taskArray
    }
    
    /// グループに含まれる課題を取得
    /// - Parameters:
    ///   - groupID: グループID
    /// - Returns: グループに含まれる課題
    func getTasksInGroup(ID groupID: String) -> [TaskData] {
        var taskArray: [TaskData] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(TaskData.self)
                            .filter("(groupID == '\(groupID)') && (isDeleted == false)")
                            .sorted(by: sortProperties)
        for task in results {
            taskArray.append(task)
        }
        return taskArray
    }
    
    /// Realmの課題を更新
    /// - Parameters:
    ///    - task: Realmオブジェクト
    func updateTask(task: TaskData) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
            .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.groupID = task.groupID
            result?.title = task.title
            result?.cause = task.cause
            result?.order = task.order
            result?.isComplete = task.isComplete
            result?.isDeleted = task.isDeleted
            result?.updated_at = task.updated_at
        }
    }
    
    /// 課題のタイトルを更新
    /// - Parameters:
    ///    - taskID: 更新したい課題のID
    ///    - title: 新しいタイトル文字列
    func updateTaskTitle(taskID: String, title: String) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                           .filter("taskID == '\(taskID)'").first
        try! realm.write {
            result?.title = title
            result?.updated_at = Date()
        }
    }
    
    /// 課題の原因を更新
    /// - Parameters:
    ///    - taskID: 更新したい課題のID
    ///    - cause: 新しい原因の文字列
    func updateTaskCause(taskID: String, cause: String) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                           .filter("taskID == '\(taskID)'").first
        try! realm.write {
            result?.cause = cause
            result?.updated_at = Date()
        }
    }
    
    /// 課題の並び順を更新
    /// - Parameters:
    ///   - task: 課題
    ///   - order: 並び順
    func updateTaskOrder(task: TaskData, order: Int) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.order = order
            result?.updated_at = Date()
        }
    }
    
    /// 課題の並び順を更新
    /// - Parameters:
    ///   - taskArray: 課題配列
    func updateTaskOrder(taskArray: [[TaskData]]) {
        let realm = try! Realm()
        
        var index = 0
        for tasks in taskArray {
            for task in tasks {
                let result = realm.objects(TaskData.self)
                                    .filter("taskID == '\(task.taskID)'").first
                try! realm.write {
                    result?.order = index
                    result?.updated_at = Date()
                }
                index += 1
                if index > tasks.count - 1 {
                    index = 0
                    continue
                }
            }
        }
    }
    
    /// 課題の属するグループを更新
    /// - Parameters:
    ///    - task: 課題
    ///    - groupId: 更新後のgroupId
    func updateTaskGroupId(task: TaskData, groupID: String) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                            .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.groupID = groupID
            result?.updated_at = Date()
        }
    }
    
    /// 課題の完了フラグを更新
    /// - Parameters:
    ///   - task: 課題
    ///   - isCompleted: 完了or未完了
    func updateTaskIsCompleted(task: TaskData, isCompleted: Bool) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.isComplete = isCompleted
            result?.updated_at = Date()
        }
    }
    
    /// 課題の削除フラグを更新
    /// - Parameters:
    ///   - task: 課題
    func updateTaskIsDeleted(task: TaskData) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// ユーザーIDを更新
    /// - Parameters:
    ///   - userID: ユーザーID
    private func updateTaskUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(TaskData.self)
        for task in result {
            try! realm.write {
                task.userID = userID
            }
        }
    }
    
    /// Realmの課題を全削除
    private func deleteAllTask() {
        let realm = try! Realm()
        let tasks = realm.objects(TaskData.self)
        do{
          try realm.write{
            realm.delete(tasks)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - Measures

extension RealmManager {
    
    /// Realmの対策を全取得
    /// - Returns: 全対策データ
    func getAllMeasures() -> [Measures] {
        var measuresArray: [Measures] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Measures.self)
        for measures in realmArray {
            measuresArray.append(measures)
        }
        return measuresArray
    }
    
    /// Realmの対策を取得
    /// - Parameters:
    ///   - measuresID: 対策ID
    /// - Returns: 対策データ
    func getMeasures(measuresID: String) -> Measures {
        let realm = try! Realm()
        let result = realm.objects(Measures.self)
            .filter("measuresID == '\(measuresID)'")
            .filter("(isDeleted == false)")
            .first
        return result ?? Measures()
    }
    
    /// 課題に含まれる最優先の対策名を取得
    /// - Parameters:
    ///   - taskID: 課題ID
    /// - Returns: 対策名
    func getMeasuresTitleInTask(taskID: String) -> String {
        var measuresArray: [Measures] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(Measures.self)
                            .filter("taskID == '\(taskID)' && (isDeleted == false)")
                            .sorted(by: sortProperties)
        for measures in results {
            measuresArray.append(measures)
        }
        return measuresArray.first?.title ?? ""
    }
    
    /// 課題に含まれる最優先の対策を取得
    /// - Parameters:
    ///   - taskID: 課題ID
    /// - Returns: 対策
    func getPriorityMeasuresInTask(taskID: String) -> Measures? {
        var measuresArray: [Measures] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(Measures.self)
                            .filter("taskID == '\(taskID)'")
                            .filter("(isDeleted == false)")
                            .sorted(by: sortProperties)
        for measures in results {
            measuresArray.append(measures)
        }
        return measuresArray.first
    }
    
    /// 課題に含まれる対策を取得
    /// - Parameters:
    ///   - taskID: 課題ID
    /// - Returns: 課題に含まれる対策
    func getMeasuresInTask(ID taskID: String) -> [Measures] {
        var measuresArray: [Measures] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(Measures.self)
                            .filter("taskID == '\(taskID)' && (isDeleted == false)")
                            .sorted(by: sortProperties)
        for measures in results {
            measuresArray.append(measures)
        }
        return measuresArray
    }
    
    /// Realmの対策を更新
    /// - Parameters:
    ///    - measures: Realmオブジェクト
    func updateMeasures(measures: Measures) {
        let realm = try! Realm()
        let result = realm.objects(Measures.self)
                           .filter("measuresID == '\(measures.measuresID)'").first
        try! realm.write {
            result?.title = measures.title
            result?.order = measures.order
            result?.isDeleted = measures.isDeleted
            result?.updated_at = measures.updated_at
        }
    }
    
    /// 対策のタイトルを更新
    /// - Parameters:
    ///   - ID: 更新したい対策のID
    ///   - title: 新しいタイトル文字列
    func updateMeasuresTitle(measuresID: String, title: String) {
        let realm = try! Realm()
        let result = realm.objects(Measures.self)
                           .filter("measuresID == '\(measuresID)'").first
        try! realm.write {
            result?.title = title
            result?.updated_at = Date()
        }
    }
    
    /// 対策の並び順を更新
    /// - Parameters:
    ///    - measuresArray: 対策配列
    func updateMeasuresOrder(measuresArray: [Measures]) {
        let realm = try! Realm()
        var index = 0
        for measures in measuresArray {
            let result = realm.objects(Measures.self)
                               .filter("measuresID == '\(measures.measuresID)'").first
            try! realm.write {
                result?.order = index
                result?.updated_at = Date()
            }
            index += 1
        }
    }
    
    /// 対策の削除フラグを更新
    /// - Parameters:
    ///   - measures: 対策
    func updateMeasuresIsDeleted(measures: Measures) {
        let realm = try! Realm()
        let result = realm.objects(Measures.self)
                           .filter("measuresID == '\(measures.measuresID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// ユーザーIDを更新
    /// - Parameters:
    ///    - userID: ユーザーID
    private func updateMeasuresUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Measures.self)
        for measures in result {
            try! realm.write {
                measures.userID = userID
            }
        }
    }
    
    /// Realmの対策を全削除
    private func deleteAllMeasures() {
        let realm = try! Realm()
        let measures = realm.objects(Measures.self)
        do{
          try realm.write{
            realm.delete(measures)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - Memo

extension RealmManager {
    
    /// Realmのメモを全取得
    /// - Returns: 全メモデータ
    func getAllMemo() -> [Memo] {
        var memoArray: [Memo] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Memo.self)
        for memo in realmArray {
            memoArray.append(memo)
        }
        return memoArray
    }
    
    /// 対策に含まれるメモを取得
    /// - Parameters:
    ///   - measuresID: 対策ID
    /// - Returns: 対策に含まれるメモ
    func getMemo(measuresID: String) -> [Memo] {
        // 対策に含まれるメモを取得
        var memoArray: [Memo] = []
        let realm = try! Realm()
        let results = realm.objects(Memo.self)
                            .filter("(measuresID == '\(measuresID)') && (isDeleted == false)")
        for memo in results {
            memoArray.append(memo)
        }
        
        // ノートの日付順に並び替える
        var noteArray = getNote(memoArray: memoArray)
        noteArray.sort(by: {$0.date > $1.date})
        var resultArray = [Memo]()
        for note in noteArray {
            if let memo = getMemo(noteID: note.noteID, measuresID: measuresID) {
                memo.noteDate = note.date
                resultArray.append(memo)
            }
        }
        
        return resultArray
    }
    
    /// 対策に含まれるメモを取得
    /// - Parameters:
    ///   - measuresID: 対策ID
    /// - Returns: 対策に含まれるメモ
    func getMemo(searchWord: String) -> [Memo] {
        var memoArray: [Memo] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "created_at", ascending: false),
        ]
        let results = realm.objects(Memo.self)
                            .filter("(detail CONTAINS %@)", searchWord)
                            .filter("(isDeleted == false)")
                            .sorted(by: sortProperties)
        for memo in results {
            memoArray.append(memo)
        }
        return memoArray
    }
    
    /// ノートに含まれるメモを取得
    /// - Parameters:
    ///   - noteID: ノートID
    /// - Returns: ノートに含まれるメモ
    func getMemo(noteID: String) -> [Memo] {
        var memoArray: [Memo] = []
        let realm = try! Realm()
        let results = realm.objects(Memo.self)
                            .filter("(noteID == '\(noteID)')")
                            .filter("(isDeleted == false)")
        for memo in results {
            memoArray.append(memo)
        }
        return memoArray
    }
    
    /// ノートに含まれるメモを取得
    /// - Parameters:
    ///   - noteID: ノートID
    ///   - measuresID: 対策ID
    /// - Returns: ノートに含まれるメモ
    func getMemo(noteID: String, measuresID: String) -> Memo? {
        let realm = try! Realm()
        let result = realm.objects(Memo.self)
            .filter("(noteID == '\(noteID)')")
            .filter("(measuresID == '\(measuresID)')")
            .filter("(isDeleted == false)")
            .first
        return result
    }
    
    /// Realmのメモを更新
    /// - Parameters:
    ///    - memo: Realmオブジェクト
    func updateMemo(memo: Memo) {
        let realm = try! Realm()
        let result = realm.objects(Memo.self)
            .filter("memoID == '\(memo.memoID)'").first
        try! realm.write {
            result?.detail = memo.detail
            result?.isDeleted = memo.isDeleted
            result?.updated_at = memo.updated_at
        }
    }
    
    /// メモの内容を更新
    /// - Parameters:
    ///   - memo: メモ
    func updateMemoDetail(memoID: String, detail: String) {
        let realm = try! Realm()
        let result = realm.objects(Memo.self)
                           .filter("memoID == '\(memoID)'").first
        try! realm.write {
            result?.detail = detail
            result?.updated_at = Date()
        }
    }

    /// メモの削除フラグを更新
    /// - Parameters:
    ///   - memo: メモ
    func updateMemoIsDeleted(memoID: String) {
        let realm = try! Realm()
        let result = realm.objects(Memo.self)
                           .filter("memoID == '\(memoID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// メモの削除フラグを更新
    /// - Parameters:
    ///   - noteID: メモ
    func updateMemoIsDeleted(noteID: String) {
        let memoArray = getMemo(noteID: noteID)
        for memo in memoArray {
            updateMemoIsDeleted(memoID: memo.memoID)
        }
    }
    
    /// ユーザーIDを更新
    /// - Parameters:
    ///    - userID: ユーザーID
    private func updateMemoUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Memo.self)
        for memo in result {
            try! realm.write {
                memo.userID = userID
            }
        }
    }
    
    /// Realmのメモを全削除
    private func deleteAllMemo() {
        let realm = try! Realm()
        let memos = realm.objects(Memo.self)
        do{
          try realm.write{
            realm.delete(memos)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - Target

extension RealmManager {
    
    /// Realmの目標を全取得
    /// - Returns: 全目標データ
    func getAllTarget() -> [Target] {
        var targetArray: [Target] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Target.self)
        for target in realmArray {
            targetArray.append(target)
        }
        return targetArray
    }
    
    /// 目標を取得(年指定)
    /// - Parameters:
    ///    - year: 年
    /// - Returns: 目標データ
    func getTarget(year: Int) -> Target? {
        let realm = try! Realm()
        let result = realm.objects(Target.self)
            .filter("(year == \(year))")
            .filter("(isYearlyTarget == true)")
            .filter("(isDeleted == false)")
            .first
        return result
    }
    
    /// 目標を取得(年月指定)
    /// - Parameters:
    ///    - year: 年
    ///    - month: 月
    ///    - isYearlyTarget: 年間目標フラグ
    /// - Returns: 目標データ
    func getTarget(year: Int, month: Int, isYearlyTarget: Bool) -> Target? {
        let realm = try! Realm()
        let result = realm.objects(Target.self)
            .filter("(year == \(year)) && (month == \(month)) && (isYearlyTarget == \(isYearlyTarget)) && (isDeleted == false)").first
        return result
    }
    
    /// Realmの目標を更新
    /// - Parameters:
    ///    - target: Realmオブジェクト
    func updateTarget(target: Target) {
        let realm = try! Realm()
        let result = realm.objects(Target.self)
            .filter("targetID == '\(target.targetID)'").first
        try! realm.write {
            result?.title = target.title
            result?.year = target.year
            result?.month = target.month
            result?.isYearlyTarget = target.isYearlyTarget
            result?.isDeleted = target.isDeleted
            result?.updated_at = target.updated_at
        }
    }
    
    /// 目標の削除フラグを更新
    /// - Parameters:
    ///    - target: Realmオブジェクト
    func updateTargetIsDeleted(targetID: String) {
        let realm = try! Realm()
        let result = realm.objects(Target.self)
                           .filter("targetID == '\(targetID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// ユーザーIDを更新
    /// - Parameters:
    ///    - userID: ユーザーID
    private func updateTargetUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Target.self)
        for target in result {
            try! realm.write {
                target.userID = userID
            }
        }
    }
    
    /// Realmの目標を全削除
    private func deleteAllTarget() {
        let realm = try! Realm()
        let targets = realm.objects(Target.self)
        do{
          try realm.write{
            realm.delete(targets)
          }
        }catch {
          print("Error \(error)")
        }
    }
}

// MARK: - Note

extension RealmManager {
    
    /// Realmのノートを取得
    /// - Returns: ノートデータ
    func getAllNote() -> [Note] {
        var noteArray: [Note] = []
        let realm = try! Realm()
        let result = realm.objects(Note.self)
        for note in result {
            noteArray.append(note)
        }
        return noteArray
    }
    
    /// Realmのノートを取得
    /// - Returns: ノートデータ
    func getNote(ID: String) -> Note {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
            .filter("noteID == '\(ID)'")
            .filter("(isDeleted == false)")
            .first
        return result ?? Note()
    }
    
    /// Realmのノートを取得
    /// - Parameters:
    ///    - noteType: メモ配列
    /// - Returns: ノートデータ
    func getNote(noteType: Int) -> [Note] {
        var noteArray = [Note]()
        let realm = try! Realm()
        let result = realm.objects(Note.self)
            .filter("noteType == \(noteType)")
            .filter("(isDeleted == false)")
        for note in result {
            noteArray.append(note)
        }
        return noteArray
    }
    
    /// Realmのノートを取得
    /// - Parameters:
    ///    - memoArray: メモ配列
    /// - Returns: メモが含まれるノート
    func getNote(memoArray: [Memo]) -> [Note] {
        var noteArray = [Note]()
        for memo in memoArray {
            noteArray.append(getNote(ID: memo.noteID))
        }
        return noteArray
    }
    
    /// Realmのフリーノートを取得
    /// - Returns: フリーノートデータ
    func getFreeNote() -> Note {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
            .filter("noteType == \(NoteType.free.rawValue)").first
        return result ?? Note()
    }
    
    /// Realmのノート(練習、大会)を取得
    /// - Returns: ノートデータ
    func getPracticeTournamentNote() -> [Note] {
        var noteArray: [Note] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "date", ascending: false),
        ]
        let result = realm.objects(Note.self)
            .filter("(noteType == \(NoteType.practice.rawValue)) || (noteType == \(NoteType.tournament.rawValue))")
            .filter("(isDeleted == false)")
            .sorted(by: sortProperties)
        for note in result {
            noteArray.append(note)
        }
        return noteArray
    }
    
    /// Realmのノート(練習、大会)を取得
    /// - Parameters:
    ///    - searchWord: 検索ワード
    /// - Returns: ノートデータ
    func getPracticeTournamentNote(searchWord: String) -> [Note] {
        // メモ以外を検索
        let realm = try! Realm()
        var noteArray: [Note] = []
        let sortProperties = [
            SortDescriptor(keyPath: "date", ascending: false),
        ]
        let result = realm.objects(Note.self)
            .filter("(noteType == \(NoteType.practice.rawValue)) || (noteType == \(NoteType.tournament.rawValue))")
            .filter("(condition CONTAINS %@) || (reflection CONTAINS %@) || (purpose CONTAINS %@) || (detail CONTAINS %@) || (target CONTAINS %@) || (consciousness CONTAINS %@) || (result CONTAINS %@)", searchWord, searchWord, searchWord, searchWord, searchWord, searchWord, searchWord)
            .filter("(isDeleted == false)")
            .sorted(by: sortProperties)
        for note in result {
            noteArray.append(note)
        }
        
        // メモを検索
        let memoArray = getMemo(searchWord: searchWord)
        let memoNoteArray = getNote(memoArray: memoArray)
        noteArray.append(contentsOf: memoNoteArray)
        
        // 重複を削除&新しい順にソート
        var resultArray = Array(Set(noteArray))
        resultArray.sort(by: {$0.date > $1.date})
        
        return resultArray
    }
    
    /// Realmのノート(練習、大会)を取得
    /// - Parameters:
    ///    - taskIDs: ノートに含まれる課題
    /// - Returns: ノートデータ
    func getPracticeTournamentNote(taskIDs: [String]) -> [Note] {
        var noteArray = [Note]()
        
        // 課題に含まれる対策IDを取得
        var measuresIDArray = [String]()
        for taskID in taskIDs {
            let measuresArray = getMeasuresInTask(ID: taskID)
            for measures in measuresArray {
                measuresIDArray.append(measures.measuresID)
            }
        }
        
        // 対策を含むメモを取得
        var memoArray = [Memo]()
        for measuresID in measuresIDArray {
            memoArray.append(contentsOf: getMemo(measuresID: measuresID))
        }
        
        // メモを含むノートIDを取得(重複削除)
        var noteIDArray = [String]()
        for memo in memoArray {
            noteIDArray.append(memo.noteID)
        }
        noteIDArray = Array(Set(noteIDArray))
        
        // ノートを取得
        for noteID in noteIDArray {
            noteArray.append(getNote(ID: noteID))
        }
        
        // 日付の新しい順に並び替え
        noteArray.sort(by: {$0.date > $1.date})
        
        return noteArray
    }
    
    /// Realmのノートを取得(日付指定)
    /// - Parameters:
    ///    - date: 取得したいノートの日付
    /// - Returns: ノートデータ
    func getNote(date: Date) -> [Note] {
        var noteArray = [Note]()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d (E)"
        let da = formatter.string(from: date)
        
        let notes = getPracticeTournamentNote()
        for note in notes {
            if da == formatDate(date: note.date, format: "yyyy/M/d (E)") {
                noteArray.append(note)
            }
        }
        
        return noteArray
    }
    
    /// Realmのノートを更新(同期用)
    /// - Parameters:
    ///    - note: Realmオブジェクト
    func updateNote(note: Note) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
            .filter("noteID == '\(note.noteID)'").first
        try! realm.write {
            result?.isDeleted = note.isDeleted
            result?.updated_at = note.updated_at
            result?.title = note.title
            result?.date = note.date
            result?.weather = note.weather
            result?.temperature = note.temperature
            result?.condition = note.condition
            result?.reflection = note.reflection
            result?.purpose = note.purpose
            result?.detail = note.detail
            result?.target = note.target
            result?.consciousness = note.consciousness
            result?.result = note.result
        }
    }
    
    /// フリーノートのタイトルを更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - title: 新しいタイトル文字列
    func updateNoteTitle(noteID: String, title: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.title = title
            result?.updated_at = Date()
        }
    }
    
    /// フリーノートの内容を更新
    /// - Parameters:
    ///   - noteID: 更新したいフリーノートのID
    ///   - detail: 新しい内容の文字列
    func updateNoteDetail(noteID: String, detail: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.detail = detail
            result?.updated_at = Date()
        }
    }
    
    /// ノートの日付を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - date: 日付
    func updateNoteDate(noteID: String, date: Date) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.date = date
            result?.updated_at = Date()
        }
    }
    
    /// ノートの天気を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - weather: 天気
    func updateNoteWeather(noteID: String, weather: Int) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.weather = weather
            result?.updated_at = Date()
        }
    }
    
    /// ノートの気温を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - temperature: 気温
    func updateNoteTemperature(noteID: String, temperature: Int) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.temperature = temperature
            result?.updated_at = Date()
        }
    }
    
    /// ノートの体調を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - condition: 体調
    func updateNoteCondition(noteID: String, condition: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.condition = condition
            result?.updated_at = Date()
        }
    }
    
    /// ノートの練習目的を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - purpose: 練習目的
    func updateNotePurpose(noteID: String, purpose: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.purpose = purpose
            result?.updated_at = Date()
        }
    }
    
    /// ノートの目標を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - target: 目標
    func updateNoteTarget(noteID: String, target: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.target = target
            result?.updated_at = Date()
        }
    }
    
    /// ノートの意識することを更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - consciousness: 意識すること
    func updateNoteConsciousness(noteID: String, consciousness: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.consciousness = consciousness
            result?.updated_at = Date()
        }
    }
    
    /// ノートの結果を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - result: 結果
    func updateNoteResult(noteID: String, result: String) {
        let realm = try! Realm()
        let result1 = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result1?.result = result
            result1?.updated_at = Date()
        }
    }
    
    /// ノートの反省を更新
    /// - Parameters:
    ///   - noteID: 更新したいノートのID
    ///   - purpose: 反省
    func updateNoteReflection(noteID: String, reflection: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                           .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.reflection = reflection
            result?.updated_at = Date()
        }
    }
    
    /// ユーザーIDを更新
    /// - Parameters:
    ///    - userID: ユーザーID
    private func updateNoteUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
        for note in result {
            try! realm.write {
                note.userID = userID
            }
        }
    }
    
    /// ノートを削除
    /// - Parameters:
    ///    - noteID: ノートID
    func updateNoteIsDeleted(noteID: String) {
        let realm = try! Realm()
        let result = realm.objects(Note.self)
                          .filter("noteID == '\(noteID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// Realmのノートを全削除
    private func deleteAllNote() {
        let realm = try! Realm()
        let Notes = realm.objects(Note.self)
        do{
          try realm.write{
            realm.delete(Notes)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}
