//
//  AddGroupViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/12.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddGroupViewModel {
    
    // MARK: - Variable
    
    let colorIndex: BehaviorRelay<Int>
    let buttonTitle: BehaviorRelay<String>
    let buttonBackgroundColor: BehaviorRelay<UIColor>
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        self.colorIndex = BehaviorRelay(value: Color.allCases.first!.rawValue)
        self.buttonTitle = BehaviorRelay(value: Color.allCases.first!.title)
        self.buttonBackgroundColor = BehaviorRelay(value: Color.allCases.first!.color)
        initBind()
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
                let newColor = Color.allCases[newIndex]
                self.buttonTitle.accept(newColor.title)
                self.buttonBackgroundColor.accept(newColor.color)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// グループを新規作成
    /// - Parameter title: タイトル
    /// - Returns: 実行結果
    func insertGroup(title: String) -> Group? {
        let realmManager = RealmManager()
        let group = Group()
        group.title = title
        group.color = colorIndex.value
        Task {
            group.order = await realmManager.getGroupArrayForTaskView().count
        }
        let result = realmManager.createRealm(object: group)
        return result ? group : nil
    }
    
}
