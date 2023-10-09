//
//  GroupViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/09.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class GroupViewModel {
    
    // MARK: - Variable
    
    let group: BehaviorRelay<Group>
    let title: BehaviorRelay<String>
    let colorIndex: BehaviorRelay<Int>
    let buttonTitle: BehaviorRelay<String>
    let buttonBackgroundColor: BehaviorRelay<UIColor>
    let groupArray: BehaviorRelay<[Group]>
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(group: Group) {
        self.group = BehaviorRelay(value: group)
        self.title = BehaviorRelay(value: group.title)
        self.colorIndex = BehaviorRelay(value: group.color)
        self.buttonTitle = BehaviorRelay(value: Color.allCases[group.color].title)
        self.buttonBackgroundColor = BehaviorRelay(value: Color.allCases[group.color].color)
        self.groupArray = BehaviorRelay(value: [])
        selectGroupArray()
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitle()
        bindColor()
        bindGroupArray()
    }
    
    /// タイトルの変更をバインド
    private func bindTitle() {
        title
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                
                // Realm更新
                let realmManager = RealmManager()
                realmManager.updateGroupTitle(groupID: group.value.groupID, title: newTitle)
            })
            .disposed(by: disposeBag)
    }
    
    /// カラーの変更をバインド
    private func bindColor() {
        colorIndex
            .subscribe(onNext: { [weak self] newIndex in
                guard let self = self else { return }
                
                // ボタンへ反映
                let newColor = Color.allCases[newIndex]
                self.buttonTitle.accept(newColor.title)
                self.buttonBackgroundColor.accept(newColor.color)
                
                // Realm更新
                let realmManager = RealmManager()
                realmManager.updateGroupColor(groupID: group.value.groupID, color: newIndex)
            })
            .disposed(by: disposeBag)
    }
    
    /// グループ配列のバインド
    private func bindGroupArray() {
        groupArray
            .subscribe(onNext: { [weak self] newArray in
                guard let self = self else { return }
                // Realm更新
                let realmManager = RealmManager()
                realmManager.updateGroupOrder(groupArray: newArray)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - TableView
    
    /// セルの移動（グループの並び替え）
    /// - Parameters:
    ///   - sourceIndex: 元のindex
    ///   - destinationIndex: 移動先のindex
    func moveGroup(from sourceIndex: Int, to destinationIndex: Int) {
        guard sourceIndex != destinationIndex else {
            return
        }
        var newGroupArray = groupArray.value
        let groupToMove = newGroupArray.remove(at: sourceIndex)
        newGroupArray.insert(groupToMove, at: destinationIndex)
        groupArray.accept(newGroupArray)
    }
    
    /// グループ取得
    func selectGroupArray() {
        let realmManager = RealmManager()
        groupArray.accept(realmManager.getGroupArrayForTaskView())
    }
    
    /// グループ更新
    func updateFirebaseGroup() {
        let firebaseManager = FirebaseManager()
        firebaseManager.updateGroup(group: group.value)
    }
    
    /// グループ削除
    func deleteGroup() {
        let realmManager = RealmManager()
        realmManager.updateGroupIsDeleted(group: group.value)
    }
    
}
