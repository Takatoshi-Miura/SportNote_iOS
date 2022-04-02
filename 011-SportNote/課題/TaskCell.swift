//
//  TaskCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2021/07/25.
//  Copyright © 2021 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var cause: UILabel!
    @IBOutlet weak var measure: UILabel!
    
    func setTaskData(_ task: Task_old) {
        title.text = task.getTitle()
        cause.text = "　原因：\(task.getCause())"
        measure.text = "　対策：\(task.getMeasuresPriority())"
    }
    
}
