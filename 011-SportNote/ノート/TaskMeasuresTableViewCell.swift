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
        taskMeasuresTitleLabel.text = taskData.getMeasuresTitle(taskData.getMeasuresPriorityIndex())
        
        // 枠のカラー
        effectivenessTextView.layer.borderColor = UIColor.systemGray.cgColor
        
        // 枠の幅
        effectivenessTextView.layer.borderWidth = 1.0
    }
    
    
    
}
