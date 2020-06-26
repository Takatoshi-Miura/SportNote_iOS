//
//  AddTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddTaskViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // モーダルを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        let taskData = TaskData()
        
        // 入力されたテキストをTaskDataにセット
        taskData.setTaskData(taskTitleTextField.text!, causeTextView.text!)
        
        // データベースに保存
        taskData.saveTaskData()
        
        // モーダルを閉じる
        dismiss(animated: true, completion: nil)
    }
    

}
