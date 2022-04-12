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

// MARK: - FreeNote

extension RealmManager {
    
    /// Realmのフリーノートを取得
    /// - Returns: フリーノートデータ
    func getFreeNote() -> FreeNote {
        let realm = try! Realm()
        return realm.objects(FreeNote.self).first ?? FreeNote()
    }
    
    /// Realmのフリーノートを更新
    /// - Parameters:
    ///    - freeNote: Realmオブジェクト
    func updateFreeNote(freeNote: FreeNote) {
        let realm = try! Realm()
        let result = realm.objects(FreeNote.self)
            .filter("freeNoteID == '\(freeNote.freeNoteID)'").first
        try! realm.write {
            result?.title = freeNote.title
            result?.detail = freeNote.detail
            result?.isDeleted = freeNote.isDeleted
            result?.updated_at = freeNote.updated_at
        }
    }
    
    /// Realmのフリーノートを削除
    func deleteFreeNote() {
        let realm = try! Realm()
        let freeNotes = realm.objects(FreeNote.self)
        do{
          try realm.write{
            realm.delete(freeNotes)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - PracticeNote

extension RealmManager {
    
    /// Realmの練習ノートを全取得
    /// - Returns: 全練習ノートデータ
    func getAllPracticeNote() -> [PracticeNote] {
        var practiceNoteArray: [PracticeNote] = []
        let realm = try! Realm()
        let realmArray = realm.objects(PracticeNote.self)
        for practiceNote in realmArray {
            practiceNoteArray.append(practiceNote)
        }
        return practiceNoteArray
    }
    
    /// Realmの練習ノートを更新
    /// - Parameters:
    ///    - practiceNote: Realmオブジェクト
    func updatePracticeNote(practiceNote: PracticeNote) {
        let realm = try! Realm()
        let result = realm.objects(PracticeNote.self)
            .filter("practiceNoteID == '\(practiceNote.practiceNoteID)'").first
        try! realm.write {
            result?.date = practiceNote.date
            result?.weather = practiceNote.weather
            result?.temperature = practiceNote.temperature
            result?.condition = practiceNote.condition
            result?.purpose = practiceNote.purpose
            result?.detail = practiceNote.detail
            result?.reflection = practiceNote.reflection
            result?.isDeleted = practiceNote.isDeleted
            result?.updated_at = practiceNote.updated_at
        }
    }
    
    /// Realmの練習ノートを削除
    func deleteAllPracticeNote() {
        let realm = try! Realm()
        let practiceNotes = realm.objects(PracticeNote.self)
        do{
          try realm.write{
            realm.delete(practiceNotes)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}

// MARK: - TournamentNote

extension RealmManager {
    
    /// Realmの大会ノートを全取得
    /// - Returns: 全大会ノートデータ
    func getAllTournamentNote() -> [TournamentNote] {
        var tournamentNoteArray: [TournamentNote] = []
        let realm = try! Realm()
        let realmArray = realm.objects(TournamentNote.self)
        for tournamentNote in realmArray {
            tournamentNoteArray.append(tournamentNote)
        }
        return tournamentNoteArray
    }
    
    /// Realmの大会ノートを更新
    /// - Parameters:
    ///    - tournamentNote: Realmオブジェクト
    func updateTournamentNote(tournamentNote: TournamentNote) {
        let realm = try! Realm()
        let result = realm.objects(TournamentNote.self)
            .filter("tournamentNoteID == '\(tournamentNote.tournamentNoteID)'").first
        try! realm.write {
            result?.date = tournamentNote.date
            result?.weather = tournamentNote.weather
            result?.temperature = tournamentNote.temperature
            result?.condition = tournamentNote.condition
            result?.target = tournamentNote.target
            result?.consciousness = tournamentNote.consciousness
            result?.result = tournamentNote.result
            result?.reflection = tournamentNote.reflection
            result?.isDeleted = tournamentNote.isDeleted
            result?.updated_at = tournamentNote.updated_at
        }
    }
    
    /// Realmの大会ノートを削除
    func deleteAllTournamentNote() {
        let realm = try! Realm()
        let tournamentNotes = realm.objects(TournamentNote.self)
        do{
          try realm.write{
            realm.delete(tournamentNotes)
          }
        }catch {
          print("Error \(error)")
        }
    }
    
}
