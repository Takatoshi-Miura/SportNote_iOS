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
    func printInfo(task: TaskForAddNote) {
        let realmManager = RealmManager()
        let group = realmManager.getGroup(groupID: task.groupID)
        
        self.task = task
        if let measures = realmManager.getPriorityMeasuresInTask(taskID: task.taskID) {
            self.measures = measures
        }
        
        taskTitleLabel.text = task.title
        taskMeasuresTitleLabel.text = "\(TITLE_MEASURES):\(measures.title)"
        colorImageView.backgroundColor = Color.allCases[group.color].color
    }
    
    /// メモを入力
    func printMemo(memo: Memo) {
        memoLabel.text = memo.detail
    }
    
}
