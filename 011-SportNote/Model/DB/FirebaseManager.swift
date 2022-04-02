//
//  FirebaseManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Firebase

class FirebaseManager {
    
    var firebaseOldNoteArray: [Note] = []
    var firebasePracticeNoteArray: [PracticeNote] = []

    // MARK: - Create


    // MARK: - Select

    /// 旧ノートデータを取得
    /// - Parameters:
    ///   - completion: データ取得後に実行する処理
    func getOldNote(_ completion: @escaping () -> ()) {
        let db = Firestore.firestore()
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        db.collection("NoteData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.firebaseOldNoteArray = []
                for document in querySnapshot!.documents {
                    let dataCollection = document.data()
                    let note = Note()
                    note.setNoteID(dataCollection["noteID"] as! Int)
                    note.setNoteType(dataCollection["noteType"] as! String)
                    note.setYear(dataCollection["year"] as! Int)
                    note.setMonth(dataCollection["month"] as! Int)
                    note.setDate(dataCollection["date"] as! Int)
                    note.setDay(dataCollection["day"] as! String)
                    note.setWeather(dataCollection["weather"] as! String)
                    note.setTemperature(dataCollection["temperature"] as! Int)
                    note.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    note.setPurpose(dataCollection["purpose"] as! String)
                    note.setDetail(dataCollection["detail"] as! String)
                    note.setTarget(dataCollection["target"] as! String)
                    note.setConsciousness(dataCollection["consciousness"] as! String)
                    note.setResult(dataCollection["result"] as! String)
                    note.setReflection(dataCollection["reflection"] as! String)
                    note.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    note.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    note.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    note.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    note.setUserID(dataCollection["userID"] as! String)
                    note.setCreated_at(dataCollection["created_at"] as! String)
                    note.setUpdated_at(dataCollection["updated_at"] as! String)
                    self.firebaseOldNoteArray.append(note)
                }
                // 完了処理
                completion()
            }
        }
    }

}

