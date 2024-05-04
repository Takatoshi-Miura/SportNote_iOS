//
//  AddTaskViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/22.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddTaskViewModel {
    
    // MARK: - Variable
    
    let colorIndex: BehaviorRelay<Int>
    let buttonTitle: BehaviorRelay<String>
    let buttonBackgroundColor: BehaviorRelay<UIColor>
    var groupArray: BehaviorRelay<[Group]>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        self.groupArray = BehaviorRelay(value: [])
        self.groupArray.accept(realmManager.getGroupArrayForTaskView())
        self.colorIndex = BehaviorRelay(value: Color.allCases.first!.rawValue)
        self.buttonTitle = BehaviorRelay(value: Color.allCases.first!.title)
        self.buttonBackgroundColor = BehaviorRelay(value: Color.allCases.first!.color)
        initBind()
        colorIndex.accept(0)
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindColor()
    }
    
    /// カラーの変更をバインド
    private func bindColor() {
        colorIndex
            .subscribe(onNext: { [weak self] newIndex in
                guard let self = self else { return }
                // ボタンへ反映
                let group = groupArray.value[newIndex]
                self.buttonTitle.accept(group.title)
                self.buttonBackgroundColor.accept(Color.allCases[group.color].color)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 課題を新規登録
    /// - Parameters:
    ///   - title: タイトル
    ///   - cause: 原因
    /// - Returns: Task
    func insertTask(title: String, cause: String) -> TaskData? {
        let task = TaskData()
        task.groupID = groupArray.value[colorIndex.value].groupID
        task.title = title
        task.cause = cause
        task.order = realmManager.getTasksInGroup(ID: task.groupID, isCompleted: false).count
        return realmManager.createRealm(object: task) ? task : nil
    }
    
    /// 対策を新規登録
    /// - Parameters:
    ///   - title: タイトル
    ///   - taskID: 課題ID
    /// - Returns: Measures
    func insertMeasures(title: String, taskID: String) -> Measures? {
        let measures = Measures()
        measures.taskID = taskID
        measures.title = title
        return realmManager.createRealm(object: measures) ? measures : nil
    }
    
    /// 課題をFIrebaseに新規登録
    /// - Parameter task: 課題
    func insertFirebase(task: TaskData) {
        let firebaseManager = FirebaseManager()
        firebaseManager.saveTask(task: task, completion: {})
    }
    
    /// 対策をFirebaseに新規登録
    /// - Parameter measures: 対策
    func insertFirebase(measures: Measures) {
        let firebaseManager = FirebaseManager()
        firebaseManager.saveMeasures(measures: measures, completion: {})
    }
    
}
