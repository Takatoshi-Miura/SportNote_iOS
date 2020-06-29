//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/27.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        
        // TaskViewControllerから受け取った課題データを表示する
        printTaskData(taskData)
        
        // TaskViewControllerから受け取った課題データの対策を取得
        measuresTitleArray = taskData.getAllMeasuresTitle()
    }
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 課題データの格納用
    var taskData = TaskData()
    
    // 対策タイトルの格納用
    var measuresTitleArray:[String] = []
    
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // 課題データを更新
        taskData.setTextData(taskTitle: taskTitleTextField.text!, taskCause: taskCauseTextView.text!)
        taskData.updateTaskData()
        
        // 課題画面に遷移
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // 追加ボタンの処理
    @IBAction func addMeasuresButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"対策を追加",message:"対策を入力してください",preferredStyle:UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler:nil)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"OK",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            if let textField = alertController.textFields?.first {
                // データベースの対策データを追加
                self.taskData.addMeasures(textField.text!, "")
                
                // 対策タイトルの配列に入力値を挿入。先頭に挿入する
                self.measuresTitleArray.insert(textField.text!,at:0)
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
            }
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを宣言
        let cancelButton = UIAlertAction(title:"CANCEL",style:UIAlertAction.Style.cancel,handler:nil)
        //CANCELボタンを追加
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
    
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    
    
    // 対策の数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresCount()
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        
        //行番号に合った対策データをラベルに表示する
        cell.textLabel!.text = taskData.getMeasuresTitle(indexPath.row)
        //cell.detailTextLabel!.text = taskData.getMeasuresEffectiveness(indexPath.row)
        
        return cell
    }
    

}
