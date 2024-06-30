//
//  TaskCellForAddNote.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/09.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskCellForAddNote: UITableViewCell {

    // MARK: - UI,Variable
    
    @IBOutlet weak var colorImageView: UIImageView!
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
        effectivenessTextView.layer.masksToBounds = true
        effectivenessTextView.text = ""
        if !isiPad() {
            createToolBar()
        }
    }
    
    /// ツールバーを作成
    private func createToolBar() {
        let toolbar = UIToolbar()
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(hideKeyboard(_:)))
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleItem, doneItem], animated: true)
        toolbar.sizeToFit()
        effectivenessTextView.inputAccessoryView = toolbar
    }
    
    /// キーボードを閉じる
    @objc func hideKeyboard(_ sender: UIButton){
        self.endEditing(true)
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
        effectivenessTextView.text = memo.detail
    }
    
}
