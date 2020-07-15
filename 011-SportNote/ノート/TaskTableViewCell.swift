//
//  TaskTableViewCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/14.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    //MARK:- UIの設定
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var measuresTitle: UILabel!
    @IBOutlet weak var measuresEffectiveness: UITextView!
    
    
    
    //MARK:- その他のメソッド
    
    // 課題データをラベルに表示するメソッド
    func printTaskData(_ noteData:NoteData,_ index:Int) {
        taskTitle.text             = noteData.getTaskTitle()[index]
        measuresTitle.text         = "対策：\(noteData.getMeasuresTitle()[index])"
        measuresEffectiveness.text = noteData.getMeasuresEffectiveness()[index]
    }
    
}
