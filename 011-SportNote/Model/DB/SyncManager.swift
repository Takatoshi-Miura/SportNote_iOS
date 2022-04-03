//
//  SyncManager.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import Foundation

class SyncManager {
    
    let firebaseManager = FirebaseManager()
    let dataConverter = DataConverter()
    
    var taskArray: [Task] = []
    var measuresArray: [Measures] = []
    var memoArray: [Memo] = []
    var targetArray: [Target] = []
    var freeNote = FreeNote()
    var noteArray: [Any] = []
    var practiceNoteArray: [PracticeNote] = []
    var tournamentNoteArray: [TournamentNote] = []
    
    /// 全ての旧データを変換
    func convertOldDataToNew(_ completion: @escaping () -> ()) {
        var completionNumber = 0
        
        print("OldTask変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldTask(completion: {
                print("OldTask変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldTarget変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldTarget(completion: {
                print("OldTarget変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldFreeNote変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldFreeNote(completion: {
                print("OldFreeNote変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("OldNote変換開始")
        DispatchQueue.global(qos: .default).sync {
            self.convertOldNote(completion: {
                print("OldNote変換終了")
                completionNumber += 1
                self.convertCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
    }
    
    /// 全ての旧課題データを変換
    func convertOldTask(completion: @escaping () -> ()) {
        firebaseManager.getOldTask({
            let oldTaskArray = self.firebaseManager.oldTaskArray
            for oldTask in oldTaskArray {
                let dic = self.dataConverter.convertToTaskMeasuresMemo(oldTask: oldTask)
                self.taskArray.append(contentsOf: dic["task"]!.first as! [Task])
                self.measuresArray.append(contentsOf: dic["measures"]!.first as! [Measures])
                self.memoArray.append(contentsOf: dic["memo"]!.first as! [Memo])
            }
            completion()
        })
    }
    
    /// 全ての旧目標データを変換
    func convertOldTarget(completion: @escaping () -> ()) {
        firebaseManager.getOldTarget({
            let oldTargetArray = self.firebaseManager.oldTargetArray
            for oldTarget in oldTargetArray {
                self.targetArray.append(self.dataConverter.convertToTarget(oldTarget: oldTarget))
            }
            completion()
        })
    }
    
    /// 全ての旧フリーノートデータを変換
    func convertOldFreeNote(completion: @escaping () -> ()) {
        firebaseManager.getOldFreeNote({
            let oldFreeNote = self.firebaseManager.oldFreeNote
            self.freeNote = self.dataConverter.convertToFreeNote(oldFreeNote: oldFreeNote)
            completion()
        })
    }
    
    /// 全ての旧ノートデータを変換
    func convertOldNote(completion: @escaping () -> ()) {
        firebaseManager.getOldNote({
            let oldNoteArray = self.firebaseManager.oldNoteArray
            for oldNote in oldNoteArray {
                let note = self.dataConverter.convertToNote(oldNote: oldNote)
                self.noteArray.append(note)
                if note is PracticeNote {
                    self.practiceNoteArray.append(note as! PracticeNote)
                } else {
                    self.tournamentNoteArray.append(note as! TournamentNote)
                }
            }
            completion()
        })
    }
    
    /**
     旧データ変換終了後の処理
     - Parameters:
        - completion: 完了処理
        - completionNumber: タスク完了数
     */
    func convertCompletion(completion: @escaping () -> (), completionNumber: Int) {
        // 課題、対策、ノート全ての変換が終了した場合のみ完了処理を実行
        if completionNumber == 4 {
            completion()
        }
    }
    
}


