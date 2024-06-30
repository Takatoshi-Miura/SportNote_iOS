//
//  TaskCellForNoteDetailView.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2024/01/01.
//  Copyright © 2024 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskCellForNoteDetailView: UITableViewCell {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskMeasuresTitleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    var task: TaskForAddNote?
    var measures = Measures()
    var memo = Memo()

    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// 課題データを表示
    /// - Parameter task: TaskForAddNote
    func printInfo(task: TaskForAddNote) {
        let realmManager = RealmManager()
        
        Task {
            if let group = await realmManager.getGroup(groupID: task.groupID) {
                DispatchQueue.main.async {
                    self.task = task
                    self.taskTitleLabel.text = task.title
                    self.colorImageView.backgroundColor = Color.allCases[group.color].color
                }
            }
            
            if let measures = await realmManager.getPriorityMeasuresInTask(taskID: task.taskID) {
                DispatchQueue.main.async {
                    self.measures = measures
                    self.taskMeasuresTitleLabel.text = "\(TITLE_MEASURES):\(measures.title)"
                }
            }
        }
    }
    
    /// メモを入力
    func printMemo(memo: Memo) {
        memoLabel.text = memo.detail
    }
    
}
