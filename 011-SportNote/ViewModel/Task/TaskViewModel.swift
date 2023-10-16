//
//  TaskViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/16.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import PKHUD
import RxSwift
import RxCocoa

class TaskViewModel {
    
    // MARK: - Variable
    
    let isComplete: Bool
    let groupID: String
    var groupArray: BehaviorRelay<[Group]>
    var taskArray: BehaviorRelay<[[Task]]>
    var completedTaskArray: BehaviorRelay<[Task]>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(isComplete: Bool, groupID: String) {
        self.isComplete = isComplete
        self.groupID = groupID
        syncDataWithConvert()
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindMeasuresArray()
    }
    
    /// 対策配列のバインド
    private func bindMeasuresArray() {
        groupArray
            .subscribe(onNext: { [weak self] newArray in
                guard let self = self else { return }
                // Realm更新
                realmManager.updateMeasuresOrder(measuresArray: newArray)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - TableView
    
    /// セルの移動（対策の並び替え）
    /// - Parameters:
    ///   - sourceIndex: 元のindex
    ///   - destinationIndex: 移動先のindex
    func moveMeasures(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else {
            return
        }
        var newGroupArray = groupArray.value
        let measuresToMove = newGroupArray.remove(at: sourceIndex)
        newGroupArray.insert(measuresToMove, at: destinationIndex)
        groupArray.accept(newGroupArray)
    }
    
    // MARK: - Other Methods
    
    /// データ変換＆同期処理
    /// ログアウト後は未分類グループなどを自動生成する必要がある
    func syncDataWithConvert() {
        if !isComplete && Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let dataConverter = DataConverter()
            dataConverter.convertOldToRealm(completion: {
                self.syncData()
            })
        } else {
            self.syncData()
        }
    }
    
    /// 同期処理
    func syncData() {
        if !isComplete && Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let syncManager = SyncManager()
            syncManager.syncDatabase(completion: {
                self.refreshData()
                HUD.hide()
            })
        } else {
            self.refreshData()
        }
    }
    
    /// データ再取得
    func refreshData() {
        if isComplete {
            completedTaskArray.accept(realmManager.getTasksInGroup(ID: groupID, isCompleted: isComplete))
        } else {
            groupArray.accept(realmManager.getGroupArrayForTaskView())
            taskArray.accept(realmManager.getTaskArrayForTaskView())
        }
    }
    
    /// グループを挿入
    /// - Parameter group: グループ
    func insertGroup(group: Group) {
        var newGroupArray = groupArray.value
        newGroupArray.append(group)
        groupArray.accept(newGroupArray)
        
        var newTaskArray = taskArray.value
        newTaskArray.append([])
        taskArray.accept(newTaskArray)
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
