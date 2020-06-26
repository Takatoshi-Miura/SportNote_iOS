//
//  TaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class TaskViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    // TaskDataを格納した配列
    var taskDataArray = [TaskData]()
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    
    // TaskViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データベースの課題データを取得
        let databaseTaskData = TaskData()
        databaseTaskData.loadDatabase()
        
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            // 課題データの受け取り
            self.taskDataArray = []
            self.taskDataArray = databaseTaskData.taskDataArray
        
            // テーブルビューの更新
            self.tableView?.reloadData()
        
            // HUDを非表示
            SVProgressHUD.dismiss()
        }
    }
    
    
    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // 課題追加画面に遷移
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
    
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        
    }
    
    
    
    // TaskDataArray配列の長さ(項目の数)を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataArray.count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Storyboardで指定したセルを取得する
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        //行番号に合った課題データをラベルに表示する
        let taskData = taskDataArray[indexPath.row]
        cell.textLabel!.text = taskData.getTaskTitle()
        cell.detailTextLabel!.text = taskData.getTaskCouse()
        
        return cell
    }


}
