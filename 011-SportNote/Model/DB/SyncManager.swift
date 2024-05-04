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
    
    /// RaalmとFirebaseのデータを同期（Swift Concurrency）
    /// データの種類ごとに並列に取得し、すべての処理の完了を待つ
    func syncDatabase() async {
        print("開始:Realm-Firebase同期----------")
        async let group: Void = syncGroup()
        async let task: Void = syncTask()
        async let measures: Void = syncMeasures()
        async let memo: Void = syncMemo()
        async let target: Void = syncTarget()
        async let note: Void = syncNote()
        
        let _: [Void] = await [group, task, measures, memo, target, note]
        print("終了:Realm-Firebase同期----------")
    }
    
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
        
        print("ノート同期開始")
        DispatchQueue.global(qos: .default).sync {
            syncNote(completion: {
                print("ノート同期終了")
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
        // グループ、課題、対策、メモ、目標、ノート全ての同期が終了した場合のみ完了処理を実行
        if completionNumber == 6 {
            completion()
        }
    }
    
    /// Groupを同期
    private func syncGroup() async {
        print("Group同期開始")
        
        // Realmのグループを全取得
        let realmGroupArray: [Group] = realmManager.getAllGroup()
        
        // Firebaseのグループを全取得(取得完了を待つ)
        let firebaseGroupArray: [Group] = await firebaseManager.getAllGroup()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseGroupIDArray = firebaseGroupArray.map { $0.groupID }
        let realmGroupIDArray = realmGroupArray.map { $0.groupID }
        let onlyFirebaseID = firebaseGroupIDArray.subtracting(realmGroupIDArray)
        let onlyRealmID = realmGroupIDArray.subtracting(firebaseGroupIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for groupID in onlyRealmID {
                taskGroup.addTask {
                    if let group = realmGroupArray.first(where: { $0.groupID == groupID }) {
                        await self.firebaseManager.saveGroup(group: group)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { groupID in
            guard let group = firebaseGroupArray.first(where: { $0.groupID == groupID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: group)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for groupID in realmGroupIDArray {
            guard let realmGroup = realmGroupArray.first(where: { $0.groupID == groupID }),
                  let firebaseGroup = firebaseGroupArray.first(where: { $0.groupID == groupID }) else 
            {
                continue
            }
            
            if realmGroup.updated_at > firebaseGroup.updated_at {
                self.firebaseManager.updateGroup(group: realmGroup)
            } else if firebaseGroup.updated_at > realmGroup.updated_at {
                self.realmManager.updateGroup(group: firebaseGroup)
            }
        }
        print("Group同期終了")
    }
    
    /// Taskを同期
    private func syncTask() async {
        print("Task同期開始")
        
        // RealmのTaskを全取得
        let realmTaskArray: [TaskData] = realmManager.getAllTask()
        
        // FirebaseのTaskを全取得(取得完了を待つ)
        let firebaseTaskArray: [TaskData] = await firebaseManager.getAllTask()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseTaskIDArray = firebaseTaskArray.map { $0.taskID }
        let realmTaskIDArray = realmTaskArray.map { $0.taskID }
        let onlyFirebaseID = firebaseTaskIDArray.subtracting(realmTaskIDArray)
        let onlyRealmID = realmTaskIDArray.subtracting(firebaseTaskIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for taskID in onlyRealmID {
                taskGroup.addTask {
                    if let task = realmTaskArray.first(where: { $0.taskID == taskID }) {
                        await self.firebaseManager.saveTask(task: task)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { taskID in
            guard let task = firebaseTaskArray.first(where: { $0.taskID == taskID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: task)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for taskID in realmTaskIDArray {
            guard let realmTask = realmTaskArray.first(where: { $0.taskID == taskID }),
                  let firebaseTask = firebaseTaskArray.first(where: { $0.taskID == taskID }) else
            {
                continue
            }
            
            if realmTask.updated_at > firebaseTask.updated_at {
                self.firebaseManager.updateTask(task: realmTask)
            } else if firebaseTask.updated_at > realmTask.updated_at {
                self.realmManager.updateTask(task: firebaseTask)
            }
        }
        print("Task同期終了")
    }
    
    /// Measuresを同期
    private func syncMeasures() async {
        print("Measures同期開始")
        
        // RealmのMeasuresを全取得
        let realmMeasuresArray: [Measures] = realmManager.getAllMeasures()
        
        // FirebaseのMeasuresを全取得(取得完了を待つ)
        let firebaseMeasuresArray: [Measures] = await firebaseManager.getAllMeasures()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseMeasuresIDArray = firebaseMeasuresArray.map { $0.measuresID }
        let realmMeasuresIDArray = realmMeasuresArray.map { $0.measuresID }
        let onlyFirebaseID = firebaseMeasuresIDArray.subtracting(realmMeasuresIDArray)
        let onlyRealmID = realmMeasuresIDArray.subtracting(firebaseMeasuresIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for measuresID in onlyRealmID {
                taskGroup.addTask {
                    if let measures = realmMeasuresArray.first(where: { $0.measuresID == measuresID }) {
                        await self.firebaseManager.saveMeasures(measures: measures)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { measuresID in
            guard let measures = firebaseMeasuresArray.first(where: { $0.measuresID == measuresID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: measures)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for measuresID in realmMeasuresIDArray {
            guard let realmMeasures = realmMeasuresArray.first(where: { $0.measuresID == measuresID }),
                  let firebaseMeasures = firebaseMeasuresArray.first(where: { $0.measuresID == measuresID }) else
            {
                continue
            }
            
            if realmMeasures.updated_at > firebaseMeasures.updated_at {
                self.firebaseManager.updateMeasures(measures: realmMeasures)
            } else if firebaseMeasures.updated_at > realmMeasures.updated_at {
                self.realmManager.updateMeasures(measures: firebaseMeasures)
            }
        }
        print("Measures同期終了")
    }
    
    /// Memoを同期
    private func syncMemo() async {
        print("Memo同期開始")
        
        // RealmのMemoを全取得
        let realmMemoArray: [Memo] = realmManager.getAllMemo()
        
        // FirebaseのMemoを全取得(取得完了を待つ)
        let firebaseMemoArray: [Memo] = await firebaseManager.getAllMemo()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseMemoIDArray = firebaseMemoArray.map { $0.memoID }
        let realmMemoIDArray = realmMemoArray.map { $0.memoID }
        let onlyFirebaseID = firebaseMemoIDArray.subtracting(realmMemoIDArray)
        let onlyRealmID = realmMemoIDArray.subtracting(firebaseMemoIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for memoID in onlyRealmID {
                taskGroup.addTask {
                    if let memo = realmMemoArray.first(where: { $0.memoID == memoID }) {
                        await self.firebaseManager.saveMemo(memo: memo)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { memoID in
            guard let memo = firebaseMemoArray.first(where: { $0.memoID == memoID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: memo)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for memoID in realmMemoIDArray {
            guard let realmMemo = realmMemoArray.first(where: { $0.memoID == memoID }),
                  let firebaseMemo = firebaseMemoArray.first(where: { $0.memoID == memoID }) else
            {
                continue
            }
            
            if realmMemo.updated_at > firebaseMemo.updated_at {
                self.firebaseManager.updateMemo(memo: realmMemo)
            } else if firebaseMemo.updated_at > realmMemo.updated_at {
                self.realmManager.updateMemo(memo: firebaseMemo)
            }
        }
        print("Memo同期終了")
    }
    
    /// Targetを同期
    private func syncTarget() async {
        print("Target同期開始")
        
        // RealmのTargetを全取得
        let realmTargetArray: [Target] = realmManager.getAllTarget()
        
        // FirebaseのTargetを全取得(取得完了を待つ)
        let firebaseTargetArray: [Target] = await firebaseManager.getAllTarget()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseTargetIDArray = firebaseTargetArray.map { $0.targetID }
        let realmTargetIDArray = realmTargetArray.map { $0.targetID }
        let onlyFirebaseID = firebaseTargetIDArray.subtracting(realmTargetIDArray)
        let onlyRealmID = realmTargetIDArray.subtracting(firebaseTargetIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for targetID in onlyRealmID {
                taskGroup.addTask {
                    if let target = realmTargetArray.first(where: { $0.targetID == targetID }) {
                        await self.firebaseManager.saveTarget(target: target)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { targetID in
            guard let target = firebaseTargetArray.first(where: { $0.targetID == targetID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: target)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for targetID in realmTargetIDArray {
            guard let realmTarget = realmTargetArray.first(where: { $0.targetID == targetID }),
                  let firebaseTarget = firebaseTargetArray.first(where: { $0.targetID == targetID }) else
            {
                continue
            }
            
            if realmTarget.updated_at > firebaseTarget.updated_at {
                self.firebaseManager.updateTarget(target: realmTarget)
            } else if firebaseTarget.updated_at > realmTarget.updated_at {
                self.realmManager.updateTarget(target: firebaseTarget)
            }
        }
        print("Target同期終了")
    }
    
    /// Noteを同期
    private func syncNote() async {
        print("Note同期開始")
        
        // RealmのNoteを全取得
        let realmNoteArray: [Note] = realmManager.getAllNote()
        
        // FirebaseのNoteを全取得(取得完了を待つ)
        let firebaseNoteArray: [Note] = await firebaseManager.getAllNote()
        
        // FirebaseもしくはRealmにしか存在しないデータを抽出
        let firebaseNoteIDArray = firebaseNoteArray.map { $0.noteID }
        let realmNoteIDArray = realmNoteArray.map { $0.noteID }
        let onlyFirebaseID = firebaseNoteIDArray.subtracting(realmNoteIDArray)
        let onlyRealmID = realmNoteIDArray.subtracting(firebaseNoteIDArray)
        
        // Realmにしか存在しないデータをFirebaseに保存(並列処理)
        await withTaskGroup(of: Void.self) { taskGroup in
            for noteID in onlyRealmID {
                taskGroup.addTask {
                    if let note = realmNoteArray.first(where: { $0.noteID == noteID }) {
                        await self.firebaseManager.saveNote(note: note)
                    }
                }
            }
        }
        
        // Firebaseにしか存在しないデータをRealmに保存
        onlyFirebaseID.forEach { noteID in
            guard let note = firebaseNoteArray.first(where: { $0.noteID == noteID }) else {
                return
            }
            _ = self.realmManager.createRealm(object: note)
        }
        
        // どちらにも存在するデータの更新日時を比較し新しい方に更新する
        for noteID in realmNoteIDArray {
            guard let realmNote = realmNoteArray.first(where: { $0.noteID == noteID }),
                  let firebaseNote = firebaseNoteArray.first(where: { $0.noteID == noteID }) else
            {
                continue
            }
            
            if realmNote.updated_at > firebaseNote.updated_at {
                self.firebaseManager.updateNote(note: realmNote)
            } else if firebaseNote.updated_at > realmNote.updated_at {
                self.realmManager.updateNote(note: firebaseNote)
            }
        }
        print("Note同期終了")
    }
    
    // MARK: - Group同期用
    
    /// Groupを同期
    /// - Parameter completion: 完了処理
    private func syncGroup(completion: @escaping () -> ()) {
        // Realmのグループを全取得
        let realmGroupArray: [Group] = realmManager.getAllGroup()
        
        // Firebaseのグループを全取得
        firebaseManager.getAllGroup(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseGroupIDArray = self.firebaseManager.groupArray.map { $0.groupID }
            let realmGroupIDArray = realmGroupArray.map { $0.groupID }
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
                if !self.realmManager.createRealm(object: group) {
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
        let realmTaskArray: [TaskData] = realmManager.getAllTask()
        
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
                if !self.realmManager.createRealm(object: task) {
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
    private func getTaskIDArray(array: [TaskData]) -> [String] {
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
    private func getTaskWithID(array :[TaskData], ID: String) -> TaskData {
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
                if !self.realmManager.createRealm(object: measures) {
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
                if !self.realmManager.createRealm(object: memo) {
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
                if !self.realmManager.createRealm(object: target) {
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
    
    // MARK: - Note同期用
    
    /// ノートを同期
    /// - Parameters:
    ///   - completion: 完了処理
    private func syncNote(completion: @escaping () -> ()) {
        // Realmのノートを全取得
        let realmNoteArray = realmManager.getAllNote()
        
        // Firebaseのノートを全取得
        firebaseManager.getAllNote(completion: {
            // FirebaseもしくはRealmにしか存在しないデータを抽出
            let firebaseNoteIDArray = self.getNoteIDArray(array: self.firebaseManager.noteArray)
            let realmNoteIDArray = self.getNoteIDArray(array: realmNoteArray)
            let onlyRealmID = realmNoteIDArray.subtracting(firebaseNoteIDArray)
            let onlyFirebaseID = firebaseNoteIDArray.subtracting(realmNoteIDArray)
            
            // Realmにしか存在しないデータをFirebaseに保存
            for noteID in onlyRealmID {
                let note = self.getNoteWithID(array: realmNoteArray, ID: noteID)
                self.firebaseManager.saveNote(note: note, completion: {})
            }
            
            // Firebaseにしか存在しないデータをRealmに保存
            for noteID in onlyFirebaseID {
                let note = self.getNoteWithID(array: self.firebaseManager.noteArray, ID: noteID)
                if !self.realmManager.createRealm(object: note) {
                    return
                }
            }
            
            // どちらにも存在するデータの更新日時を比較し新しい方に更新する
            let commonID = realmNoteIDArray.subtracting(onlyRealmID)
            for noteID in commonID {
                let realmNote = self.getNoteWithID(array: realmNoteArray, ID: noteID)
                let firebaseNote = self.getNoteWithID(array: self.firebaseManager.noteArray, ID: noteID)
                
                if realmNote.updated_at > firebaseNote.updated_at {
                    // Realmデータの方が新しい
                    self.firebaseManager.updateNote(note: realmNote)
                } else if firebaseNote.updated_at > realmNote.updated_at  {
                    // Firebaseデータの方が新しい
                    self.realmManager.updateNote(note: firebaseNote)
                }
            }
            completion()
        })
    }

    /**
     Note配列からnoteID配列を作成
     - Parameters:
        - array: Note配列
     - Returns: NoteID配列
     */
    private func getNoteIDArray(array: [Note]) -> [String] {
        var noteIDArray: [String] = []
        for note in array {
            noteIDArray.append(note.noteID)
        }
        return noteIDArray
    }

    /**
     Note配列からNoteを取得(NoteID指定)
     - Parameters:
        - array: 検索対象のNote配列
        - ID: 取得したいNoteID
     - Returns: Noteデータ
    */
    private func getNoteWithID(array :[Note], ID: String) -> Note {
        return array.filter{ $0.noteID.contains(ID) }.first!
    }
    
}
