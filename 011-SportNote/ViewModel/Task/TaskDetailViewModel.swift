//
//  TaskDetailViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/15.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TaskDetailViewModel {
    
    // MARK: - Variable
    
    let title: BehaviorRelay<String>
    let cause: BehaviorRelay<String>
    var measuresArray: BehaviorRelay<[Measures]>
    var task: TaskData
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(task: TaskData) {
        self.task = task
        self.title = BehaviorRelay(value: task.title)
        self.cause = BehaviorRelay(value: task.cause)
        self.measuresArray = BehaviorRelay<[Measures]>(value: [])
        Task {
            self.measuresArray = BehaviorRelay(value: await self.realmManager.getMeasuresInTask(ID: task.taskID))
        }
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitle()
        bindCause()
        bindMeasuresArray()
    }
    
    /// タイトルの変更をバインド
    private func bindTitle() {
        title
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                Task {
                    // TODO: updateTaskに修正
                    // Realm更新
//                    realmManager.updateTaskTitle(taskID: task.taskID, title: newTitle)
                    // Realm更新
                    if let realmTask = await self.realmManager.getTask(taskID: self.task.taskID) {
                        realmTask.title = newTitle
                        await self.realmManager.updateTask(task: realmTask)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 原因の変更をバインド
    private func bindCause() {
        cause
            .subscribe(onNext: { [weak self] newText in
                guard let self = self else { return }
                // TODO: updateTaskに修正
                // Realm更新
//                realmManager.updateTaskCause(taskID: task.taskID, cause: newText)
                Task {
                    // Realm更新
                    if let realmTask = await self.realmManager.getTask(taskID: self.task.taskID) {
                        realmTask.cause = newText
                        await self.realmManager.updateTask(task: realmTask)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 対策配列のバインド
    private func bindMeasuresArray() {
        measuresArray
            .subscribe(onNext: { [weak self] newArray in
                guard let self = self else { return }
                Task {
                    // Realm更新
                    await self.realmManager.updateMeasuresOrder(measuresArray: newArray)
                }
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
        var newMeasuresArray = measuresArray.value
        let measuresToMove = newMeasuresArray.remove(at: sourceIndex)
        newMeasuresArray.insert(measuresToMove, at: destinationIndex)
        measuresArray.accept(newMeasuresArray)
    }
    
    // MARK: - Other Methods
    
    /// 対策を新規作成
    /// - Parameter title: タイトル
    /// - Returns: 処理結果
    func insertMeasures(title: String) async -> Bool {
        let measures = createMeasures(title: title)
        if await !realmManager.createRealm(object: measures) {
            return false
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            insertFirebaseMeasures(measures: measures)
        }
        
        var currentMeasures = measuresArray.value
        currentMeasures.insert(measures, at: measures.order)
        measuresArray.accept(currentMeasures)
        return true
    }
    
    /// 対策を作成
    /// - Parameter title: タイトル
    /// - Returns: Measures
    private func createMeasures(title: String) -> Measures {
        let measures = Measures()
        measures.taskID = task.taskID
        measures.title = title
        Task {
            measures.order = await realmManager.getMeasuresInTask(ID: task.taskID).count
        }
        return measures
    }
    
    /// Firebaseに対策を新規作成
    /// - Parameter measures: 対策
    private func insertFirebaseMeasures(measures: Measures) {
        let firebaseManager = FirebaseManager()
        firebaseManager.saveMeasures(measures: measures, completion: {})
    }
    
    /// Firebaseに課題と対策を更新
    func updateFirebaseMeasures() {
        let firebaseManager = FirebaseManager()
        firebaseManager.updateTask(task: task)
        for measures in measuresArray.value {
            firebaseManager.updateMeasures(measures: measures)
        }
    }
    
    /// 課題の完了状態を更新
    /// - Parameter isCompleted: 完了状態
    func completeTask(isCompleted: Bool) {
        Task {
            // Realm更新
            if let realmTask = await self.realmManager.getTask(taskID: self.task.taskID) {
                realmTask.isComplete = isCompleted
                await self.realmManager.updateTask(task: realmTask)
            }
        }
//        // TODO: updateTaskに修正
//        realmManager.updateTaskIsCompleted(task: task, isCompleted: isCompleted)
    }
    
    /// 課題とそれに含まれる対策を削除
    func deleteTask() {
        Task {
            // Realm更新
            if let realmTask = await self.realmManager.getTask(taskID: self.task.taskID) {
                realmTask.isDeleted = true
                await self.realmManager.updateTask(task: realmTask)
            }
            for measures in self.measuresArray.value {
                if let realmMeasures = await self.realmManager.getMeasures(measuresID: measures.measuresID) {
                    realmMeasures.isDeleted = true
                    await self.realmManager.updateMeasures(measures: realmMeasures)
                }
            }
        }
//        // TODO: updateTaskに修正
//        realmManager.updateTaskIsDeleted(task: task)
//        for measures in measuresArray.value {
//            // TODO: updateMeasuresに修正
//            realmManager.updateMeasuresIsDeleted(measures: measures)
//        }
    }
    
    /// measuresArrayから指定した対策を削除
    /// - Parameter index: インデックス
    /// - Returns: 削除有無
    func removeMeasures(index: Int) -> Bool {
        var currentMeasures = measuresArray.value
        let measures = currentMeasures[index]
        if measures.isDeleted {
            currentMeasures.remove(at: index)
            measuresArray.accept(currentMeasures)
            return true
        } else {
            return false
        }
    }
    
}
