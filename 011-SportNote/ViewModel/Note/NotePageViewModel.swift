//
//  NoteDetailViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/12/24.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NotePageViewModel {
    
    // MARK: - Variable
    
    var noteArray: BehaviorRelay<[Note]>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        self.noteArray = BehaviorRelay(value: [])
        refreshData()
    }
    
    // MARK: - Other Methods
    
    /// ノート取得
    func refreshData() {
        Task {
            let newNoteArray = await self.realmManager.getPracticeTournamentNote()
            self.noteArray.accept(newNoteArray)
        }
    }
}
