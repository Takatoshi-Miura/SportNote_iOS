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
    private let realmManager = RealmManager()
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(note: Note) {
        self.note = note
    }
    
}
