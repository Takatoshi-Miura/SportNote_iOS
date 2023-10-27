//
//  FreeNoteViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/28.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FreeNoteViewModel {
    
    // MARK: - Variable
    
    let freeNote: BehaviorRelay<Note>
    let title: BehaviorRelay<String>
    let detail: BehaviorRelay<String>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(freeNote: Note) {
        self.freeNote = BehaviorRelay(value: freeNote)
        self.title = BehaviorRelay(value: freeNote.title)
        self.detail = BehaviorRelay(value: freeNote.detail)
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitle()
        bindDetail()
    }
    
    /// タイトルの変更をバインド
    private func bindTitle() {
        title
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                // Realm更新
                realmManager.updateNoteTitle(noteID: freeNote.value.noteID, title: newTitle)
            })
            .disposed(by: disposeBag)
    }
    
    /// 詳細の変更をバインド
    private func bindDetail() {
        detail
            .subscribe(onNext: { [weak self] newTitle in
                guard let self = self else { return }
                // Realm更新
                realmManager.updateNoteDetail(noteID: freeNote.value.noteID, detail: newTitle)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// フリーノート更新
    func updateFirebaseNote() {
        let firebaseManager = FirebaseManager()
        firebaseManager.updateNote(note: freeNote.value)
    }
    
}
