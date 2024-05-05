//
//  NoteViewModel.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2023/10/28.
//  Copyright © 2023 Takatoshi Miura. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class NoteViewModel {
    
    // MARK: - Variable
    
    var noteArray: BehaviorRelay<[Note]>
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init() {
        self.noteArray = BehaviorRelay(value: [])
    }
    
    // MARK: - Other Methods
    
    /// データ変換＆同期処理
    /// ログアウト後は未分類グループなどを自動生成する必要がある
    func syncDataWithConvert() {
        if Network.isOnline() {
            Task {
                let dataConverter = DataConverter()
                await dataConverter.convertOldToRealm()
                syncData()
            }
        } else {
            syncData()
        }
    }
    
    /// 同期処理
    func syncData() {
        if Network.isOnline() {
            Task {
                let syncManager = SyncManager()
                await syncManager.syncDatabase()
                self.refreshData()
            }
        } else {
            self.refreshData()
        }
    }
    
    /// ノート再取得
    func refreshData() {
        DispatchQueue.main.async {
            var newNoteArray = self.realmManager.getPracticeTournamentNote()
            newNoteArray.insert(self.realmManager.getFreeNote(), at: 0)
            self.noteArray.accept(newNoteArray)
        }
    }
    
    /// ノート検索
    /// - Parameter searchText: 検索ワード
    func selectNote(searchText: String) {
        if (searchText == "") {
            refreshData()
            return
        }
        var newNoteArray = realmManager.getPracticeTournamentNote(searchWord: searchText)
        newNoteArray.insert(realmManager.getFreeNote(), at: 0)
        noteArray.accept(newNoteArray)
    }
    
    /// ノートを配列から削除
    /// - Parameter indexPath: IndexPath
    /// - Returns: 削除有無
    func deleteNoteFromArray(indexPath: IndexPath) -> Bool {
        var currentNoteArray = noteArray.value
        let note = currentNoteArray[indexPath.row]
        if note.isDeleted {
            currentNoteArray.remove(at: indexPath.row)
            noteArray.accept(currentNoteArray)
            return true
        }
        return false
    }
    
}
