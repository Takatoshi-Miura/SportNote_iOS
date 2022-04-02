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
        let dataConverter = DataConverter()
        
        firebaseManager.getOldNote({
            self.oldNoteArray = firebaseManager.oldNoteArray
            for oldNote in self.oldNoteArray {
                self.newNoteArray.append(dataConverter.convertToNote(oldNote: oldNote))
            }
            completion()
        })
    }
    
}


