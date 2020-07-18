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
    
    // チェックボックス
    @IBOutlet weak var checkBox: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    @IBAction func chexBox(_ sender: Any) {
        // 選択状態を反転させる
        self.checkBox.isSelected = !self.checkBox.isSelected
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 課題データをラベルに表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        // ラベルに表示
        taskTitleLabel.text = taskData.getTaskTitle()
        if taskData.getMeasuresTitleArray().isEmpty == true {
            taskMeasuresTitleLabel.text = "対策が未登録です"
        } else {
            taskMeasuresTitleLabel.text = "対策：\(taskData.getMeasuresTitle(taskData.getMeasuresPriorityIndex()))"
        }
        
        // テキストフィールドの枠線追加
        effectivenessTextView.layer.borderColor = UIColor.systemGray.cgColor
        effectivenessTextView.layer.borderWidth = 1.0
        
        // チェックボックスの設定
        self.checkBox.setImage(uncheckedImage, for: .normal)
        self.checkBox.setImage(checkedImage, for: .selected)
    }
    
    
}
