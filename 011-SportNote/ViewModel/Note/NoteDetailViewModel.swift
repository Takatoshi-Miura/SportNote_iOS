//
//  NoteDetailViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/12/29.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NoteDetailViewModel {
    
    // MARK: - Variable
    
    var note: Note
    var taskArray = [TaskForAddNote]()
    var memoArray = [Memo]()
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(note: Note) {
        self.note = note
        self.getLinkedTask(noteID: note.noteID)
    }
    
    // MARK: - Other Methods
    
    /// ノートに紐づく課題・メモデータを取得
    /// - Parameter noteID: ノートID
    private func getLinkedTask(noteID: String) {
        Task {
            taskArray = await realmManager.getTaskArrayForAddNoteView(noteID: noteID)
            memoArray = await realmManager.getMemo(noteID: noteID)
        }
    }
    
}
