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
    let realmManager = RealmManager()
    
    // MARK: - Realm-Firebase同期用
    
    /**
     RaalmとFirebaseのデータを同期
     - Parameters:
        - completion: 完了処理
     */
    func syncDatabase(completion: @escaping () -> ()) {
        // Realmはスレッドを超えてはいけないため同期的に処理を行う
        // 各データ毎に専用のスレッドを作成して処理を行う
        var completionNumber = 0
            
        print("グループ同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncGroup(completion: {
                print("グループ同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("課題同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncTask(completion: {
                print("課題同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("対策同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncMeasures(completion: {
                print("対策同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("メモ同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncMemo(completion: {
                print("メモ同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("目標同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncTarget(completion: {
                print("目標同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("フリーノート同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncFreeNote(completion: {
                print("フリーノート同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("練習ノート同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncPracticeNote(completion: {
                print("練習ノート同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
        
        print("大会ノート同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncTournamentNote(completion: {
                print("大会ノート同期終了")
                completionNumber += 1
                self.syncDatabaseCompletion(completion: completion, completionNumber: completionNumber)
            })
        }
    }

    /**
     RaalmとFirebaseのデータ同期終了後の処理
     - Parameters:
        - completion: 完了処理
        - completionNumber: タスク完了数
     */
    private func syncDatabaseCompletion(completion: @escaping () -> (), completionNumber: Int) {
        // グループ、課題、対策、メモ、目標、フリー、練習、大会全ての同期が終了した場合のみ完了処理を実行
        if completionNumber == 8 {
            completion()
        }
    }
    
    // MARK: - Group同期用
    
    /// グループを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncGroup(completion: @escaping () -> ()) {
        // Realmのグループを全取得
        let realmGroupArray: [Group] = realmManager.getAllGroup()
        
        // Firebaseのグループを全取得
        firebaseManager.getAllGroup(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseGroupIDArray = self.getGroupIDArray(array: self.firebaseManager.groupArray)
            let realmGroupIDArray = self.getGroupIDArray(array: realmGroupArray)
            let onlyRealmID = realmGroupIDArray.subtracting(firebaseGroupIDArray)
            let onlyFirebaseID = firebaseGroupIDArray.subtracting(realmGroupIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for groupID in onlyRealmID {
                let group = self.getGroupWithID(array: realmGroupArray, ID: groupID)
                self.firebaseManager.saveGroup(group: group, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for groupID in onlyFirebaseID {
                let group = self.getGroupWithID(array: self.firebaseManager.groupArray, ID: groupID)
                if self.realmManager.createRealm(object: group) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmGroupIDArray.subtracting(onlyRealmID)
            for groupID in commonID {
                let realmGroup = self.getGroupWithID(array: realmGroupArray, ID: groupID)
                let firebaseGroup = self.getGroupWithID(array: self.firebaseManager.groupArray, ID: groupID)
                
                if realmGroup.updated_at > firebaseGroup.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateGroup(group: realmGroup)
                } else if firebaseGroup.updated_at > realmGroup.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateGroup(group: firebaseGroup)
                }
            }
            completion()
        })
    }

    /**
     Group配列からgroupID配列を作成
     - Parameters:
        - array: Group配列
     - Returns: groupID配列
     */
    private func getGroupIDArray(array: [Group]) -> [String] {
        var groupIDArray: [String] = []
        for group in array {
            groupIDArray.append(group.groupID)
        }
        return groupIDArray
    }

    /**
     Group配列からGroupを取得(groupID指定)
     - Parameters:
        - array: 検索対象のGroup配列
        - groupID: 取得したいGroupのID
     - Returns: Groupデータ
    */
    private func getGroupWithID(array :[Group], ID: String) -> Group {
        return array.filter{ $0.groupID.contains(ID) }.first!
    }
    
    // MARK: - Task同期用
    
    /// 課題を同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncTask(completion: @escaping () -> ()) {
        // Realmの課題を全取得
        let realmTaskArray: [Task] = realmManager.getAllTask()
        
        // Firebaseの課題を全取得
        firebaseManager.getAllTask(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseTaskIDArray = self.getTaskIDArray(array: self.firebaseManager.taskArray)
            let realmTaskIDArray = self.getTaskIDArray(array: realmTaskArray)
            let onlyRealmID = realmTaskIDArray.subtracting(firebaseTaskIDArray)
            let onlyFirebaseID = firebaseTaskIDArray.subtracting(realmTaskIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for taskID in onlyRealmID {
                let task = self.getTaskWithID(array: realmTaskArray, ID: taskID)
                self.firebaseManager.saveTask(task: task, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for taskID in onlyFirebaseID {
                let task = self.getTaskWithID(array: self.firebaseManager.taskArray, ID: taskID)
                if self.realmManager.createRealm(object: task) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmTaskIDArray.subtracting(onlyRealmID)
            for taskID in commonID {
                let realmTask = self.getTaskWithID(array: realmTaskArray, ID: taskID)
                let firebaseTask = self.getTaskWithID(array: self.firebaseManager.taskArray, ID: taskID)
                
                if realmTask.updated_at > firebaseTask.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateTask(task: realmTask)
                } else if firebaseTask.updated_at > realmTask.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateTask(task: firebaseTask)
                }
            }
            completion()
        })
    }

    /**
     Task配列からtaskID配列を作成
     - Parameters:
        - array: Task配列
     - Returns: taskID配列
     */
    private func getTaskIDArray(array: [Task]) -> [String] {
        var taskIDArray: [String] = []
        for task in array {
            taskIDArray.append(task.taskID)
        }
        return taskIDArray
    }

    /**
     Task配列からTaskを取得(taskID指定)
     - Parameters:
        - array: 検索対象のTask配列
        - taskID: 取得したいTaskのID
     - Returns: Taskデータ
    */
    private func getTaskWithID(array :[Task], ID: String) -> Task {
        return array.filter{ $0.taskID.contains(ID) }.first!
    }
    
    // MARK: - Measures同期用
    
    /// 対策を同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncMeasures(completion: @escaping () -> ()) {
        // Realmの対策を全取得
        let realmMeasuresArray: [Measures] = realmManager.getAllMeasures()
        
        // Firebaseの対策を全取得
        firebaseManager.getAllMeasures(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseMeasuresIDArray = self.getMeasuresIDArray(array: self.firebaseManager.measuresArray)
            let realmMeasuresIDArray = self.getMeasuresIDArray(array: realmMeasuresArray)
            let onlyRealmID = realmMeasuresIDArray.subtracting(firebaseMeasuresIDArray)
            let onlyFirebaseID = firebaseMeasuresIDArray.subtracting(realmMeasuresIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for measuresID in onlyRealmID {
                let measures = self.getMeasuresWithID(array: realmMeasuresArray, ID: measuresID)
                self.firebaseManager.saveMeasures(measures: measures, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for measuresID in onlyFirebaseID {
                let measures = self.getMeasuresWithID(array: self.firebaseManager.measuresArray, ID: measuresID)
                if self.realmManager.createRealm(object: measures) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmMeasuresIDArray.subtracting(onlyRealmID)
            for measuresID in commonID {
                let realmMeasures = self.getMeasuresWithID(array: realmMeasuresArray, ID: measuresID)
                let firebaseMeasures = self.getMeasuresWithID(array: self.firebaseManager.measuresArray, ID: measuresID)
                
                if realmMeasures.updated_at > firebaseMeasures.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateMeasures(measures: realmMeasures)
                } else if firebaseMeasures.updated_at > realmMeasures.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateMeasures(measures: firebaseMeasures)
                }
            }
            completion()
        })
    }

    /**
     Measures配列からmeasuresID配列を作成
     - Parameters:
        - array: Task配列
     - Returns: measuresID配列
     */
    private func getMeasuresIDArray(array: [Measures]) -> [String] {
        var measuresIDArray: [String] = []
        for measures in array {
            measuresIDArray.append(measures.measuresID)
        }
        return measuresIDArray
    }

    /**
     Measures配列からMeasuresを取得(measuresID指定)
     - Parameters:
        - array: 検索対象のMeasures配列
        - measuresID: 取得したいMeasuresのID
     - Returns: Measuresデータ
    */
    private func getMeasuresWithID(array :[Measures], ID: String) -> Measures {
        return array.filter{ $0.measuresID.contains(ID) }.first!
    }
    
    // MARK: - Memo同期用
    
    /// メモを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncMemo(completion: @escaping () -> ()) {
        // Realmのメモを全取得
        let realmMemoArray: [Memo] = realmManager.getAllMemo()
        
        // Firebaseのノートを全取得
        firebaseManager.getAllMemo(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseMemoIDArray = self.getMemoIDArray(array: self.firebaseManager.memoArray)
            let realmMemoIDArray = self.getMemoIDArray(array: realmMemoArray)
            let onlyRealmID = realmMemoIDArray.subtracting(firebaseMemoIDArray)
            let onlyFirebaseID = firebaseMemoIDArray.subtracting(realmMemoIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for memoID in onlyRealmID {
                let memo = self.getMemoWithID(array: realmMemoArray, ID: memoID)
                self.firebaseManager.saveMemo(memo: memo, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for memoID in onlyFirebaseID {
                let memo = self.getMemoWithID(array: self.firebaseManager.memoArray, ID: memoID)
                if self.realmManager.createRealm(object: memo) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmMemoIDArray.subtracting(onlyRealmID)
            for memoID in commonID {
                let realmMemo = self.getMemoWithID(array: realmMemoArray, ID: memoID)
                let firebaseMemo = self.getMemoWithID(array: self.firebaseManager.memoArray, ID: memoID)
                
                if realmMemo.updated_at > firebaseMemo.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateMemo(memo: realmMemo)
                } else if firebaseMemo.updated_at > realmMemo.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateMemo(memo: firebaseMemo)
                }
            }
            completion()
        })
    }

    /**
     Memo配列からmemoID配列を作成
     - Parameters:
        - array: Memo配列
     - Returns: memoID配列
     */
    private func getMemoIDArray(array: [Memo]) -> [String] {
        var memoIDArray: [String] = []
        for memo in array {
            memoIDArray.append(memo.memoID)
        }
        return memoIDArray
    }

    /**
     Memo配列からMemoを取得(memoID指定)
     - Parameters:
        - array: 検索対象のMemo配列
        - memoID: 取得したいMemoのID
     - Returns: Noteデータ
    */
    private func getMemoWithID(array :[Memo], ID: String) -> Memo {
        return array.filter{ $0.memoID.contains(ID) }.first!
    }
    
    // MARK: - Target同期用
    
    /// 目標を同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncTarget(completion: @escaping () -> ()) {
        // Realmの目標を全取得
        let realmTargetArray: [Target] = realmManager.getAllTarget()
        
        // Firebaseの目標を全取得
        firebaseManager.getAllTarget(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseTargetIDArray = self.getTargetIDArray(array: self.firebaseManager.targetArray)
            let realmTargetIDArray = self.getTargetIDArray(array: realmTargetArray)
            let onlyRealmID = realmTargetIDArray.subtracting(firebaseTargetIDArray)
            let onlyFirebaseID = firebaseTargetIDArray.subtracting(realmTargetIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for targetID in onlyRealmID {
                let target = self.getTargetWithID(array: realmTargetArray, ID: targetID)
                self.firebaseManager.saveTarget(target: target, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for targetID in onlyFirebaseID {
                let target = self.getTargetWithID(array: self.firebaseManager.targetArray, ID: targetID)
                if self.realmManager.createRealm(object: target) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmTargetIDArray.subtracting(onlyRealmID)
            for targetID in commonID {
                let realmTarget = self.getTargetWithID(array: realmTargetArray, ID: targetID)
                let firebaseTarget = self.getTargetWithID(array: self.firebaseManager.targetArray, ID: targetID)
                
                if realmTarget.updated_at > firebaseTarget.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateTarget(target: realmTarget)
                } else if firebaseTarget.updated_at > realmTarget.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateTarget(target: firebaseTarget)
                }
            }
            completion()
        })
    }

    /**
     Target配列からtargetID配列を作成
     - Parameters:
        - array: Target配列
     - Returns: targetID配列
     */
    private func getTargetIDArray(array: [Target]) -> [String] {
        var targetIDArray: [String] = []
        for target in array {
            targetIDArray.append(target.targetID)
        }
        return targetIDArray
    }

    /**
     Target配列からTargetを取得(targetID指定)
     - Parameters:
        - array: 検索対象のTarget配列
        - ID: 取得したいtargetID
     - Returns: Targetデータ
    */
    private func getTargetWithID(array :[Target], ID: String) -> Target {
        return array.filter{ $0.targetID.contains(ID) }.first!
    }
    
    // MARK: - FreeNote同期用
    
    /// フリーノートを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncFreeNote(completion: @escaping () -> ()) {
        // Realmのフリーノートを全取得
        let realmFreeNoteArray: [FreeNote] = [realmManager.getFreeNote()]
        
        // Firebaseのフリーノートを全取得
        firebaseManager.getAllFreeNote(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseFreeNoteIDArray = self.getFreeNoteIDArray(array: [self.firebaseManager.freeNote])
            let realmFreeNoteIDArray = self.getFreeNoteIDArray(array: realmFreeNoteArray)
            let onlyRealmID = realmFreeNoteIDArray.subtracting(firebaseFreeNoteIDArray)
            let onlyFirebaseID = firebaseFreeNoteIDArray.subtracting(realmFreeNoteIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for freeNoteID in onlyRealmID {
                let freeNote = self.getFreeNoteWithID(array: realmFreeNoteArray, ID: freeNoteID)
                self.firebaseManager.saveFreeNote(freeNote: freeNote, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for freeNoteID in onlyFirebaseID {
                let freeNote = self.getFreeNoteWithID(array: [self.firebaseManager.freeNote], ID: freeNoteID)
                if self.realmManager.createRealm(object: freeNote) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmFreeNoteIDArray.subtracting(onlyRealmID)
            for freeNoteID in commonID {
                let realmFreeNote = self.getFreeNoteWithID(array: realmFreeNoteArray, ID: freeNoteID)
                let firebaseFreeNote = self.getFreeNoteWithID(array: [self.firebaseManager.freeNote], ID: freeNoteID)
                
                if realmFreeNote.updated_at > firebaseFreeNote.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateFreeNote(freeNote: realmFreeNote)
                } else if firebaseFreeNote.updated_at > realmFreeNote.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateFreeNote(freeNote: firebaseFreeNote)
                }
            }
            completion()
        })
    }

    /**
     FreeNote配列からfreeNoteID配列を作成
     - Parameters:
        - array: FreeNote配列
     - Returns: freeNoteID配列
     */
    private func getFreeNoteIDArray(array: [FreeNote]) -> [String] {
        var freeNoteIDArray: [String] = []
        for freeNote in array {
            freeNoteIDArray.append(freeNote.freeNoteID)
        }
        return freeNoteIDArray
    }

    /**
     FreeNote配列からFreeNoteを取得(freeNoteID指定)
     - Parameters:
        - array: 検索対象のFreeNote配列
        - ID: 取得したいfreeNoteID
     - Returns: FreeNoteデータ
    */
    private func getFreeNoteWithID(array :[FreeNote], ID: String) -> FreeNote {
        return array.filter{ $0.freeNoteID.contains(ID) }.first!
    }
    
    // MARK: - PracticeNote同期用
    
    /// 練習ノートを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncPracticeNote(completion: @escaping () -> ()) {
        // Realmの練習ノートを全取得
        let realmPracticeNoteArray: [PracticeNote] = realmManager.getAllPracticeNote()
        
        // Firebaseの練習ノートを全取得
        firebaseManager.getAllPracticeNote(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebasePracticeNoteIDArray = self.getPracticeNoteIDArray(array: self.firebaseManager.practiceNoteArray)
            let realmPracticeNoteIDArray = self.getPracticeNoteIDArray(array: realmPracticeNoteArray)
            let onlyRealmID = realmPracticeNoteIDArray.subtracting(firebasePracticeNoteIDArray)
            let onlyFirebaseID = firebasePracticeNoteIDArray.subtracting(realmPracticeNoteIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for practiceNoteID in onlyRealmID {
                let practiceNote = self.getPracticeNoteWithID(array: realmPracticeNoteArray, ID: practiceNoteID)
                self.firebaseManager.savePracticeNote(practiceNote: practiceNote, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for practiceNoteID in onlyFirebaseID {
                let practiceNote = self.getPracticeNoteWithID(array: self.firebaseManager.practiceNoteArray, ID: practiceNoteID)
                if self.realmManager.createRealm(object: practiceNote) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmPracticeNoteIDArray.subtracting(onlyRealmID)
            for practiceNoteID in commonID {
                let realmPracticeNote = self.getPracticeNoteWithID(array: realmPracticeNoteArray, ID: practiceNoteID)
                let firebasePracticeNote = self.getPracticeNoteWithID(array: self.firebaseManager.practiceNoteArray, ID: practiceNoteID)
                
                if realmPracticeNote.updated_at > firebasePracticeNote.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updatePracticeNote(practiceNote: realmPracticeNote)
                } else if firebasePracticeNote.updated_at > realmPracticeNote.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updatePracticeNote(practiceNote: firebasePracticeNote)
                }
            }
            completion()
        })
    }

    /**
     PracticeNote配列からpracticeNoteID配列を作成
     - Parameters:
        - array: PracticeNote配列
     - Returns: practiceNoteID配列
     */
    private func getPracticeNoteIDArray(array: [PracticeNote]) -> [String] {
        var practiceNoteIDArray: [String] = []
        for practiceNote in array {
            practiceNoteIDArray.append(practiceNote.practiceNoteID)
        }
        return practiceNoteIDArray
    }

    /**
     PracticeNote配列からPracticeNoteを取得(practiceNoteID指定)
     - Parameters:
        - array: 検索対象のPracticeNote配列
        - ID: 取得したいpracticeNoteID
     - Returns: PracticeNoteデータ
    */
    private func getPracticeNoteWithID(array :[PracticeNote], ID: String) -> PracticeNote {
        return array.filter{ $0.practiceNoteID.contains(ID) }.first!
    }
    
    // MARK: - TournamentNote同期用
    
    /// 大会ノートを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncTournamentNote(completion: @escaping () -> ()) {
        // Realmの大会ノートを全取得
        let realmTournamentNoteArray: [TournamentNote] = realmManager.getAllTournamentNote()
        
        // Firebaseの大会ノートを全取得
        firebaseManager.getAllTournamentNote(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseTournamentNoteIDArray = self.getTournamentNoteIDArray(array: self.firebaseManager.tournamentNoteArray)
            let realmTournamentNoteIDArray = self.getTournamentNoteIDArray(array: realmTournamentNoteArray)
            let onlyRealmID = realmTournamentNoteIDArray.subtracting(firebaseTournamentNoteIDArray)
            let onlyFirebaseID = firebaseTournamentNoteIDArray.subtracting(realmTournamentNoteIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for tournamentNoteID in onlyRealmID {
                let tournamentNote = self.getTournamentNoteWithID(array: realmTournamentNoteArray, ID: tournamentNoteID)
                self.firebaseManager.saveTournamentNote(tournamentNote: tournamentNote, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for tournamentNoteID in onlyFirebaseID {
                let tournamentNote = self.getTournamentNoteWithID(array: self.firebaseManager.tournamentNoteArray, ID: tournamentNoteID)
                if self.realmManager.createRealm(object: tournamentNote) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmTournamentNoteIDArray.subtracting(onlyRealmID)
            for tournamentNoteID in commonID {
                let realmTournamentNote = self.getTournamentNoteWithID(array: realmTournamentNoteArray, ID: tournamentNoteID)
                let firebaseTournamentNote = self.getTournamentNoteWithID(array: self.firebaseManager.tournamentNoteArray, ID: tournamentNoteID)
                
                if realmTournamentNote.updated_at > firebaseTournamentNote.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateTournamentNote(tournamentNote: realmTournamentNote)
                } else if firebaseTournamentNote.updated_at > realmTournamentNote.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateTournamentNote(tournamentNote: firebaseTournamentNote)
                }
            }
            completion()
        })
    }

    /**
     TournamentNote配列からtournamentNoteID配列を作成
     - Parameters:
        - array: TournamentNote配列
     - Returns: tournamentNoteID配列
     */
    private func getTournamentNoteIDArray(array: [TournamentNote]) -> [String] {
        var tournamentNoteIDArray: [String] = []
        for tournamentNote in array {
            tournamentNoteIDArray.append(tournamentNote.tournamentNoteID)
        }
        return tournamentNoteIDArray
    }

    /**
     TournamentNote配列からTournamentNoteを取得(tournamentNoteID指定)
     - Parameters:
        - array: 検索対象のTournamentNote配列
        - ID: 取得したいtournamentNoteID
     - Returns: TournamentNoteデータ
    */
    private func getTournamentNoteWithID(array :[TournamentNote], ID: String) -> TournamentNote {
        return array.filter{ $0.tournamentNoteID.contains(ID) }.first!
    }
    
}
