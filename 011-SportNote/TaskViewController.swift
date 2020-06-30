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
        
        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        
        // リフレッシュ機能の設定
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(TaskViewController.refresh(sender:)), for: .valueChanged)
    }
    
    
    // TaskDataを格納する配列
    var taskDataArray = [TaskData]()
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // リフレッシュ機能用
    fileprivate let refreshCtl = UIRefreshControl()
    
    
    // TaskViewControllerが呼ばれたときの処理
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
        // テーブルビューを更新
        reloadTableView()
    }
    
    
    // テーブルビューを下に下げたときの処理(リフレッシュ機能)
    @objc func refresh(sender: UIRefreshControl) {
        // ここが引っ張られるたびに呼び出される
        reloadTableView()
        
        // 通信終了後、ロードインジケーター終了
        self.tableView.refreshControl?.endRefreshing()
    }
    
    
    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // 課題追加画面に遷移
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
    
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        
    }
    
    
    // テーブルビューを更新するメソッド
    func reloadTableView() {
        // データベースの課題データを取得
        let databaseTaskData = TaskData()
        databaseTaskData.loadTaskData()
        
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            // 課題データの受け取り
            self.taskDataArray = []
            self.taskDataArray = databaseTaskData.taskDataArray
        
            // テーブルビューの更新
            self.tableView?.reloadData()
        }
    }
    
    
    // セルをタップした時の処理
    var indexPath:Int = 0   // 行番号格納用
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルの行番号を取得
        self.indexPath = indexPath.row
        
        // 課題詳細確認画面へ遷移
        performSegue(withIdentifier: "goTaskDetailViewController", sender: nil)
    }
    
    
    // セルを削除したときの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // 次回以降、この課題データを取得しないようにする
            taskDataArray[indexPath.row].deleteTask()
            taskDataArray[indexPath.row].updateTaskData()
            
            // taskDataArrayから削除
            taskDataArray.remove(at:indexPath.row)
            
            // セルを削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }
    
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.taskData = taskDataArray[indexPath]
        }
    }

    
    // TaskDataArray配列の長さ(項目の数)を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataArray.count + 1
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 最下位は解決済みの課題セル、それ以外は未解決の課題セル
        switch indexPath.row {
            case taskDataArray.count:
                // 解決済みの課題セルを取得
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "resolvedTaskCell", for: indexPath)
                cell.textLabel!.text = "解決済みの課題一覧"
                cell.textLabel!.textColor = UIColor.systemBlue
                return cell
            default:
                // 未解決の課題セルを取得する
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
                // 行番号に合った課題データをラベルに表示する
                let taskData = taskDataArray[indexPath.row]
                cell.textLabel!.text = taskData.getTaskTitle()
                cell.detailTextLabel!.text = taskData.getTaskCouse()
                return cell
        }
    }
    
    // TaskViewControllerに戻ったときの処理
    @IBAction func goToTaskViewController(_segue:UIStoryboardSegue) {
        
    }


}
