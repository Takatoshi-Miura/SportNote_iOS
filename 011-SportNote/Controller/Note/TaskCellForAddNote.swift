//
//  TaskCellForAddNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/09.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskCellForAddNote: UITableViewCell {

    // MARK: - UI
    
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskMeasuresTitleLabel: UILabel!
    @IBOutlet weak var effectivenessTextView: UITextView!
    var task: TaskForAddNote?
    var measures = Measures()
    var memo = Memo()

    // MARK: - LifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        effectivenessTextView.layer.borderColor = UIColor.systemGray.cgColor
        effectivenessTextView.layer.borderWidth = 1.0
        effectivenessTextView.layer.cornerRadius = 5.0
        effectivenessTextView.text = ""
        createToolBar()
    }
    
    /// ツールバーを作成
    private func createToolBar() {
        let toolBar = UIToolbar()
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))
        toolBar.setItems([flexibleItem, okButton], animated: true)
        toolBar.sizeToFit()
        effectivenessTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.endEditing(true)
    }
    
    /// 課題データを表示
    func printInfo(memo: Memo) {
        // データ取得
        let realmManager = RealmManager()
        self.memo = memo
        measures = realmManager.getMeasures(measuresID: memo.measuresID)
        let task = realmManager.getTask(taskID: measures.taskID)
        self.task = TaskForAddNote(task: task)
        
        // データ表示
        taskTitleLabel.text = task.title
        taskMeasuresTitleLabel.text = "\(TITLE_MEASURES):\(measures.title)"
        effectivenessTextView.text  = memo.detail
    }
    
    /// 課題データを表示
    func printInfo(task: TaskForAddNote) {
        self.task = task
        let realmManager = RealmManager()
        taskTitleLabel.text = task.title
        taskMeasuresTitleLabel.text = realmManager.getMeasuresTitleInTask(taskID: task.taskID)
    }
    
}
