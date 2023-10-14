//
//  MeasuresViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/14.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class MeasuresViewModel {
    
    // MARK: - Variable
    
    let title: BehaviorRelay<String>
    var memoArray: BehaviorRelay<[Memo]>
    private var measures: Measures
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(measures: Measures) {
        self.measures = measures
        self.title = BehaviorRelay(value: measures.title)
        self.memoArray = BehaviorRelay(value: realmManager.getMemo(measuresID: measures.measuresID))
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitle()
    }
    
    /// タイトルの変更をバインド
    private func bindTitle() {
        title
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                // Realm更新
                realmManager.updateMeasuresTitle(measuresID: measures.measuresID, title: newTitle)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// memoArrayから指定したメモを取得
    /// - Parameter index: インデックス
    /// - Returns: Memo（存在しない場合はnil）
    func getMemo(index: Int) -> Memo? {
        if index >= 0 && index < memoArray.value.count {
            return memoArray.value[index]
        } else {
            return nil
        }
    }
    
    /// Firebaseに対策とメモを更新
    func updateFirebaseMeasures() {
        let firebaseManager = FirebaseManager()
        firebaseManager.updateMeasures(measures: measures)
        for memo in memoArray.value {
            firebaseManager.updateMemo(memo: memo)
        }
    }
    
    /// 対策とそれに含まれるメモを削除
    func deleteMeasures() {
        realmManager.updateMeasuresIsDeleted(measures: measures)
        for memo in memoArray.value {
            realmManager.updateMemoIsDeleted(memoID: memo.memoID)
        }
    }
    
    /// memoArrayから指定したメモを削除
    /// - Parameter index: インデックス
    /// - Returns: 削除有無
    func removeMemo(index: Int) -> Bool {
        var currentMemos = memoArray.value
        let memo = currentMemos[index]
        if memo.isDeleted {
            currentMemos.remove(at: index)
            memoArray.accept(currentMemos)
            return true
        } else {
            return false
        }
    }
    
}
