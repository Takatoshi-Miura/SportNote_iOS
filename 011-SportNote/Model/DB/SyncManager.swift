//
//  SyncManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

class SyncManager {
    
    var oldNoteArray = [Note_old]()
    var newNoteArray = [Any]()
    
    func convertOldNoteToNote(_ completion: @escaping () -> ()) {
        let firebaseManager = FirebaseManager()
        let dbDataFormatter = DBDataFormatter()
        
        firebaseManager.getOldNote({
            self.oldNoteArray = firebaseManager.firebaseOldNoteArray
            for oldNote in self.oldNoteArray {
                self.newNoteArray.append(dbDataFormatter.convertToNote(oldNote: oldNote))
            }
            completion()
        })
    }
    
}


