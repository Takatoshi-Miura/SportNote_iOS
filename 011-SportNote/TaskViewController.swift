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
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
        
        // リフレッシュ機能の設定
        tableView.refreshControl = refreshCtl
        refreshCtl.addTarget(self, action: #selector(TaskViewController.refresh(sender:)), for: .valueChanged)
        
        // 編集ボタンの設定(複数選択可能)
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.leftBarButtonItem = editButtonItem
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            // テーブルビューを更新
            self.reloadTableView()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    // TaskDataを格納する配列
    var taskDataArray = [TaskData]()
    
    // リフレッシュ機能用
    fileprivate let refreshCtl = UIRefreshControl()
    
    // 行番号格納用
    var indexPath:Int = 0
    var indexPathList:[Int] = []
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!

    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // 課題追加画面に遷移
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
        
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        //tableViewの編集モードを切り替える
        tableView.isEditing = editing
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // 解決済みの課題セルを編集不可能にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == taskDataArray.count { return false }
        return true
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 編集時の処理
        if tableView.isEditing {
            // 選択されたセルの行番号を格納
            //indexPathList.append(indexPath.row)
            //print("選択index:\(indexPathList)")
        } else {
            // 通常時の処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // タップしたセルの行番号を取得
            self.indexPath = indexPath.row
            
            // 課題詳細確認画面へ遷移
            if self.indexPath == taskDataArray.count {
                // 解決済みの課題セルがタップされたとき
                performSegue(withIdentifier: "goResolvedTaskViewController", sender: nil)
            } else {
                // 未解決の課題セルがタップされたとき
                performSegue(withIdentifier: "goTaskDetailViewController", sender: nil)
            }
        }
    }
    
    // 編集モード完了直後の処理
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {

    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // アラートダイアログを生成
            let alertController = UIAlertController(title:"課題を削除",message:"課題を削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
            
            // OKボタンを宣言
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // OKボタンがタップされたときの処理
                // 次回以降、この課題データを取得しないようにする
                self.taskDataArray[indexPath.row].deleteTask()
                self.taskDataArray[indexPath.row].updateTaskData()
                    
                // taskDataArrayから削除
                self.taskDataArray.remove(at:indexPath.row)
                    
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
            //OKボタンを追加
            alertController.addAction(okAction)
            
            //CANCELボタンを宣言
            let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            //CANCELボタンを追加
            alertController.addAction(cancelButton)
            
            //アラートダイアログを表示
            present(alertController,animated:true,completion:nil)
        }
    }
    
    // deleteの表示名を変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    // セルを解決済みにするときの処理（右スワイプ）
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // アクションの定義
        let resolveAction = UIContextualAction(style: .normal,title: "解決済み",handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            // 解決済みにする
            self.taskDataArray[indexPath.row].changeAchievement()
            self.taskDataArray[indexPath.row].updateTaskData()
            
            // taskDataArrayから削除
            self.taskDataArray.remove(at:indexPath.row)
            
            // セルをテーブルから削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            
            // 処理を実行完了した場合はtrue
            completion(true)
        })
        resolveAction.backgroundColor = UIColor.systemBlue
        
        return UISwipeActionsConfiguration(actions: [resolveAction])
    }
    
    // TaskDataArrayの項目の数 + 1(解決済みの課題一覧用セル)を返却する
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
    
    
    
    
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.taskData = taskDataArray[indexPath]
        } else if segue.identifier == "goResolvedTaskViewController" {
            // 解決済みの課題一覧画面へ遷移
        }
    }
    
    // TaskViewControllerに戻ったときの処理
    @IBAction func goToTaskViewController(_segue:UIStoryboardSegue) {
        // データの更新
        reloadTableView()
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テーブルビューを下に下げたときの処理(リフレッシュ機能)
    @objc func refresh(sender: UIRefreshControl) {
        // ここが引っ張られるたびに呼び出される
        reloadTableView()
        
        // 通信終了後、ロードインジケーター終了
        self.tableView.refreshControl?.endRefreshing()
    }
    
    // テーブルビューを更新するメソッド
    func reloadTableView() {
        // データベースの課題データを取得
        let databaseTaskData = TaskData()
        databaseTaskData.loadUnresolvedTaskData()
        
        // データの取得が終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
            // 課題データの受け取り
            self.taskDataArray = []
            self.taskDataArray = databaseTaskData.taskDataArray
        
            // テーブルビューの更新
            self.tableView?.reloadData()
        }
    }


}
