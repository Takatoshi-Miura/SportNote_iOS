//
//  RealmManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/03.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import RealmSwift

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
    func updateGroupUserID(userID: String) {
        let realm = try! Realm()
        let result = realm.objects(Group.self)
        for group in result {
            try! realm.write {
                group.userID = userID
            }
        }
    }
    
    /// Realmのグループを全削除
    func deleteAllGroup() {
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

// MARK: - Task

extension RealmManager {
    
    /// Realmの課題を全取得
    /// - Returns: 全課題データ
    func getAllTask() -> [Task] {
        var taskArray: [Task] = []
        let realm = try! Realm()
        let realmArray = realm.objects(Task.self)
        for task in realmArray {
            taskArray.append(task)
        }
        return taskArray
    }
    
    /// TaskViewController用task配列を返却
    /// - Returns: Task配列[[task][task, task]…]の形
    func getTaskArrayForTaskView() -> [[Task]] {
        var taskArray: [[Task]] = [[Task]]()
        let groupArray: [Group] = getGroupArrayForTaskView()
        for group in groupArray {
            let tasks = getTasksInGroup(ID: group.groupID, isCompleted: false)
            taskArray.append(tasks)
        }
        return taskArray
    }
    
    /// グループに含まれる課題を取得
    /// - Parameters:
    ///   - groupID: グループID
    ///   - isCompleted: 完了or未完了
    /// - Returns: グループに含まれる課題
    func getTasksInGroup(ID groupID: String, isCompleted: Bool) -> [Task] {
        var taskArray: [Task] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "order", ascending: true),
        ]
        let results = realm.objects(Task.self)
                            .filter("(groupID == '\(groupID)') && (isDeleted == false) && (isComplete == \(String(isCompleted)))")
                            .sorted(by: sortProperties)
        for task in results {
            taskArray.append(task)
        }
        return taskArray
    }
    
    /// Realmの課題を更新
    /// - Parameters:
    ///    - task: Realmオブジェクト
    func updateTask(task: Task) {
        let realm = try! Realm()
        let result = realm.objects(Task.self)
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
        let result = realm.objects(Task.self)
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
        let result = realm.objects(Task.self)
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
    func updateTaskOrder(task: Task, order: Int) {
        let realm = try! Realm()
        let result = realm.objects(Task.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.order = order
            result?.updated_at = Date()
        }
    }
    
    /// 課題の完了フラグを更新
    /// - Parameters:
    ///   - task: 課題
    ///   - isCompleted: 完了or未完了
    func updateTaskIsCompleted(task: Task, isCompleted: Bool) {
        let realm = try! Realm()
        let result = realm.objects(Task.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.isComplete = isCompleted
            result?.updated_at = Date()
        }
    }
    
    /// 課題の削除フラグを更新
    /// - Parameters:
    ///   - task: 課題
    func updateTaskIsDeleted(task: Task) {
        let realm = try! Realm()
        let result = realm.objects(Task.self)
                           .filter("taskID == '\(task.taskID)'").first
        try! realm.write {
            result?.isDeleted = true
            result?.updated_at = Date()
        }
    }
    
    /// Realmの課題を全削除
    func deleteAllTask() {
        let realm = try! Realm()
        let tasks = realm.objects(Task.self)
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
    
    /// Realmの対策を全削除
    func deleteAllMeasures() {
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
        var memoArray: [Memo] = []
        let realm = try! Realm()
        let sortProperties = [
            SortDescriptor(keyPath: "created_at", ascending: false),
        ]
        let results = realm.objects(Memo.self)
                            .filter("(measuresID == '\(measuresID)') && (isDeleted == false)")
                            .sorted(by: sortProperties)
        for memo in results {
            memoArray.append(memo)
        }
        return memoArray
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
    
    /// Realmのメモを全削除
    func deleteAllMemo() {
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
    
    /// Realmの目標を全削除
    func deleteAllTarget() {
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
            .sorted(by: sortProperties)
        for note in result {
            noteArray.append(note)
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
    
    /// Realmのノートを全削除
    func deleteAllNote() {
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
