//
//  AddTargetViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/11/03.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class AddTargetViewModel {
    
    // MARK: - Variable
    
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        
    }
    
    // MARK: - Other Methods
    
    /// 目標データ作成
    /// - Parameters:
    ///   - title: タイトル
    ///   - year: 年
    ///   - month: 月
    ///   - isYearly: 年間目標フラグ
    /// - Returns: Target
    func createTarget(title: String, year: Int, month: Int, isYearly: Bool) -> Target {
        let target = Target()
        target.title = title
        target.year = year
        target.isYearlyTarget = isYearly
        if !isYearly { target.month = month }
        return target
    }
    
    /// 目標年月の重複チェック
    /// - Parameter target: 目標
    /// - Returns: 重複している目標のID
    func doubleCheck(target: Target) async -> String? {
        if target.isYearlyTarget {
            if let realmTarget = await realmManager.getTarget(year: target.year) {
                return realmTarget.targetID
            }
        } else {
            if let realmTarget = await realmManager.getTarget(year: target.year, month: target.month, isYearlyTarget: false) {
                return realmTarget.targetID
            }
        }
        return nil
    }
    
    /// 目標削除
    /// - Parameter targetID: 目標ID
    func deleteTarget(targetID: String) {
        Task {
            if let realmTarget = await self.realmManager.getTarget(targetID: targetID) {
                realmTarget.isDeleted = true
                await self.realmManager.updateTarget(target: realmTarget)
            }
        }
//        // TODO: updateTargetに更新
//        realmManager.updateTargetIsDeleted(targetID: targetID)
    }
    
    /// 目標を保存
    /// - Parameter target: 目標
    /// - Returns: 結果
    func insertTarget(target: Target) async -> Bool {
        return await realmManager.createRealm(object: target)
    }
    
    /// 目標をFirebaseに保存
    /// - Parameters:
    ///   - target: 目標
    ///   - completion: 完了処理
    func insertFirebase(target: Target, completion: @escaping () -> ()) {
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveTarget(target: target, completion: {
                completion()
            })
        } else {
            completion()
        }
    }
    
}
