//
//  TaskMeasuresTableViewCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/09.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskMeasuresTableViewCell: UITableViewCell {

    //MARK:- UIの設定
    
    // ラベル
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskMeasuresTitleLabel: UILabel!
    
    // テキストビュー
    @IBOutlet weak var effectivenessTextView: UITextView!
    
    
    
    //MARK:- その他のメソッド
    
    // 課題データをラベルに表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        // ラベルに表示
        taskTitleLabel.text = taskData.getTaskTitle()
        if taskData.getAllMeasuresTitle().isEmpty == true {
            taskMeasuresTitleLabel.text = "対策が未登録です"
        } else {
            taskMeasuresTitleLabel.text = "対策：\(taskData.getMeasuresTitle(taskData.getMeasuresPriorityIndex()))"
        }
        
        // テキストフィールドの枠線追加
        effectivenessTextView.layer.borderColor = UIColor.systemGray.cgColor
        effectivenessTextView.layer.borderWidth = 1.0
    }
    
    
    
}
