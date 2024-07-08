//
//  TaskViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/16.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TaskViewModel {
    
    // MARK: - Variable
    
    let isComplete: Bool
    let groupID: String
    var groupArray: BehaviorRelay<[Group]>
    var taskArray: BehaviorRelay<[[TaskData]]>
    var completedTaskArray: BehaviorRelay<[TaskData]>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(isComplete: Bool, groupID: String) {
        self.isComplete = isComplete
        self.groupID = groupID
        self.groupArray = BehaviorRelay(value: [])
        self.taskArray = BehaviorRelay(value: [])
        self.completedTaskArray = BehaviorRelay(value: [])
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTaskArray()
        bindGroupArray()
    }
    
    /// 課題配列のバインド
    private func bindTaskArray() {
        taskArray
            .subscribe(onNext: { [weak self] newArray in
                guard let self = self else { return }
                // Realm更新
                realmManager.updateTaskOrder(taskArray: newArray)
            })
            .disposed(by: disposeBag)
    }
    
    /// グループ配列のバインド
    private func bindGroupArray() {
        groupArray
            .subscribe(onNext: { [weak self] newArray in
                guard let self = self else { return }
                Task {
                    // Realm更新
                    await self.realmManager.updateGroupOrder(groupArray: newArray)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - TableView
    
    /// セクション数を返却
    /// - Returns: セクション数
    func getNumberOfSections() -> Int {
        if isComplete {
            return 1
        } else {
            return groupArray.value.count
        }
    }
    
    /// セクションに含まれるセル数を返却
    /// - Parameter section: セクション番号
    /// - Returns: セル数
    func getNumberOfRowsInSection(section: Int) -> Int {
        if isComplete {
            return completedTaskArray.value.count
        } else {
            return taskArray.value[section].count + 1
        }
    }
    
    /// セルの編集可否を返却
    /// - Parameter indexPath: IndexPath
    /// - Returns: 編集可否
    func getCanEditRowAt(indexPath: IndexPath) -> Bool {
        if isComplete {
            return false
        }
        if indexPath.row >= taskArray.value[indexPath.section].count {
            return false // 解決済みの課題セルは編集不可
        } else {
            return true
        }
    }
    
    /// セルの並び替え可否を返却
    /// - Parameter indexPath: IndexPath
    /// - Returns: 並び替え可否
    func getCanMoveRowAt(indexPath: IndexPath) -> Bool {
        if isComplete {
            return false
        }
        if indexPath.row >= taskArray.value[indexPath.section].count {
            return false // 解決済みの課題セルは並び替え不可
        } else {
            return true
        }
    }
    
    /// セルの並び替え
    /// - Parameters:
    ///   - sourceIndexPath: 元のindex
    ///   - destinationIndexPath: 移動先のindex
    func moveTask(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard sourceIndexPath != destinationIndexPath else {
            return
        }
        
        // 完了課題セルの下に入れようとした場合は課題の最下端に並び替え
        var destinationIndex = destinationIndexPath
        let count = taskArray.value[destinationIndex.section].count
        if destinationIndex.row >= count {
            destinationIndex.row = count == 0 ? 0 : count - 1
        }
        
        // 並び替え
        var newTaskArray = taskArray.value
        let task = newTaskArray[sourceIndexPath.section][sourceIndexPath.row]
        newTaskArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        newTaskArray[destinationIndex.section].insert(task, at: destinationIndex.row)
        taskArray.accept(newTaskArray)
        
        // グループが変わる場合はグループも更新
        if sourceIndexPath.section != destinationIndex.section {
            let groupId = groupArray.value[destinationIndex.section].groupID
            realmManager.updateTaskGroupId(task: task, groupID: groupId)
        }
    }
    
    // MARK: - Other Methods
    
    /// データ変換＆同期処理
    /// ログアウト後は未分類グループなどを自動生成する必要がある
    func syncDataWithConvert() async {
        if !isComplete && Network.isOnline() {
            let dataConverter = DataConverter()
            await dataConverter.convertOldToRealm()
            await syncData()
        } else {
            await syncData()
        }
    }
    
    /// 同期処理
    func syncData() async {
        if !isComplete && Network.isOnline() {
            let syncManager = SyncManager()
            await syncManager.syncDatabase()
            refreshData()
        } else {
            refreshData()
        }
    }
    
    /// データ再取得
    func refreshData() {
        DispatchQueue.main.async {
            if self.isComplete {
                self.completedTaskArray.accept(self.realmManager.getTasksInGroup(ID: self.groupID, isCompleted: self.isComplete))
            } else {
                self.groupArray.accept(self.realmManager.getGroupArrayForTaskView())
                self.taskArray.accept(self.realmManager.getTaskArrayForTaskView())
            }
        }
    }
    
    /// グループを挿入
    /// - Parameter group: グループ
    /// - Returns: 挿入するIndexPath
    func insertGroup(group: Group) -> IndexPath {
        var newGroupArray = groupArray.value
        newGroupArray.append(group)
        groupArray.accept(newGroupArray)
        
        var newTaskArray = taskArray.value
        newTaskArray.append([])
        taskArray.accept(newTaskArray)
        let index: IndexPath = [group.order, 0]
        return index
    }
    
    /// 課題を挿入
    /// - Parameter task: 課題
    /// - Returns: 挿入するIndexPath
    func insertTask(task: TaskData) -> IndexPath {
        var index: IndexPath = [0, 0]
        for group in groupArray.value {
            if task.groupID == group.groupID {
                // グループに含まれる課題数を並び順にセットする
                let tasks = realmManager.getTasksInGroup(ID: group.groupID, isCompleted: false)
                realmManager.updateTaskOrder(task: task, order: tasks.count - 1)
                // tableViewに課題を追加
                index = [index.section, tasks.count - 1]
                var newTaskArray = taskArray.value
                newTaskArray[index.section].append(task)
                taskArray.accept(newTaskArray)
                return index
            }
            index = [index.section + 1, task.order]
        }
        return index
    }
    
    /// taskArrayから指定Taskを削除
    /// - Parameter indexPath: IndexPath
    /// - Returns: 削除有無
    func deleteTaskFromArray(indexPath: IndexPath) -> Bool {
        if isComplete {
            var taskArray = completedTaskArray.value
            let task = taskArray[indexPath.row]
            if !task.isComplete || task.isDeleted {
                taskArray.remove(at: indexPath.row)
                completedTaskArray.accept(taskArray)
                return true
            }
        } else {
            if indexPath.row < taskArray.value[indexPath.section].count {
                var taskArray = taskArray.value
                let task = taskArray[indexPath.section][indexPath.row]
                if task.isComplete || task.isDeleted {
                    taskArray[indexPath.section].remove(at: indexPath.row)
                    self.taskArray.accept(taskArray)
                    return true
                }
            }
        }
        return false
    }
    
}
