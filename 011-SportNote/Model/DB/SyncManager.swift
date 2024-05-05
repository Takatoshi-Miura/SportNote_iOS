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
    
    // MARK: - 同期メソッド
    
    /// Groupを同期
    private func syncGroup() async {
        print("Group同期開始")
        
        // Firebaseのグループを全取得(取得完了を待つ)
        let firebaseGroupArray: [Group] = await firebaseManager.getAllGroup()
        
        // Realmのグループを全取得
        let realmGroupArray: [Group] = realmManager.getAllGroup()
        
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
        
        // FirebaseのTaskを全取得(取得完了を待つ)
        let firebaseTaskArray: [TaskData] = await firebaseManager.getAllTask()
        
        // RealmのTaskを全取得
        let realmTaskArray: [TaskData] = realmManager.getAllTask()
        
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
        
        // FirebaseのMeasuresを全取得(取得完了を待つ)
        let firebaseMeasuresArray: [Measures] = await firebaseManager.getAllMeasures()
        
        // RealmのMeasuresを全取得
        let realmMeasuresArray: [Measures] = realmManager.getAllMeasures()
        
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
        
        // FirebaseのMemoを全取得(取得完了を待つ)
        let firebaseMemoArray: [Memo] = await firebaseManager.getAllMemo()
        
        // RealmのMemoを全取得
        let realmMemoArray: [Memo] = realmManager.getAllMemo()
        
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
        
        // FirebaseのTargetを全取得(取得完了を待つ)
        let firebaseTargetArray: [Target] = await firebaseManager.getAllTarget()
        
        // RealmのTargetを全取得
        let realmTargetArray: [Target] = realmManager.getAllTarget()
        
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
        
        // FirebaseのNoteを全取得(取得完了を待つ)
        let firebaseNoteArray: [Note] = await firebaseManager.getAllNote()
        
        // RealmのNoteを全取得
        let realmNoteArray: [Note] = realmManager.getAllNote()
        
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
    
}
