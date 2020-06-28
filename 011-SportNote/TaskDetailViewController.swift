//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/27.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TaskViewControllerから受け取った課題データを表示する
        printTaskData(taskData)
    }
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    
    
    // 表示する課題データの格納用
    var taskData = TaskData()
    
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // 課題データを更新
        taskData.setTextData(taskTitle: taskTitleTextField.text!, taskCause: taskCauseTextView.text!)
        taskData.updateTaskData()
        
        // 課題画面に遷移
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    

}
