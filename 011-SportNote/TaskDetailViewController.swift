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
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    
    
    // 表示する課題データの格納用
    var taskData = TaskData()
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // goToTaskViewControllerを実行
    }
    
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    

}
