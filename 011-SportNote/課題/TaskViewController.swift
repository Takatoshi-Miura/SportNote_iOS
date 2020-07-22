//
//  TaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
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
        // テーブルビューを更新
        self.loadTaskData()
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
        if editing {
            // 編集開始
            self.editButtonItem.title = "完了"
            self.editButtonItem.tintColor = UIColor.systemBlue
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            self.editButtonItem.tintColor = UIColor.systemBlue
            self.deleteRows()
        }
        // 編集モード時のみ複数選択可能とする
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
        
        if tableView.isEditing {
            // 編集時の処理
            // 選択肢にチェックが一つでも入ってたら「削除」を表示する。
            if let _ = self.tableView.indexPathsForSelectedRows {
                self.editButtonItem.title = "削除"
                self.editButtonItem.tintColor = UIColor.systemRed
            }
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
    
    // 複数のセルを削除
    private func deleteRows() {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"課題を削除",message:"選択された課題を削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            // 配列の要素削除で、indexの矛盾を防ぐため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            for indexPathList in sortedIndexPaths {
                self.taskDataArray[indexPathList.row].setIsDeleted(true)
                self.updateTaskData(task: self.taskDataArray[indexPathList.row])
                self.taskDataArray.remove(at: indexPathList.row) // 選択肢のindexPathから配列の要素を削除
            }
            
            // tableViewの行を削除
            self.tableView.deleteRows(at: sortedIndexPaths, with: UITableView.RowAnimation.automatic)
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
                self.taskDataArray[indexPath.row].setIsDeleted(true)
                self.updateTaskData(task: self.taskDataArray[indexPath.row])
                    
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
            self.updateTaskData(task: self.taskDataArray[indexPath.row])
            
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
                cell.detailTextLabel!.text = "原因：\(taskData.getTaskCouse())"
                cell.detailTextLabel?.textColor = UIColor.systemGray
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
            taskDetailViewController.previousControllerName = "TaskViewController"
        } else if segue.identifier == "goResolvedTaskViewController" {
            // 解決済みの課題一覧画面へ遷移
        }
    }
    
    // TaskViewControllerに戻ったときの処理
    @IBAction func goToTaskViewController(_segue:UIStoryboardSegue) {
        // データの更新
        loadTaskData()
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テーブルビューを下に下げたときの処理(リフレッシュ機能)
    @objc func refresh(sender: UIRefreshControl) {
        // ここが引っ張られるたびに呼び出される
        loadTaskData()
        // 通信終了後、ロードインジケーター終了
        self.tableView.refreshControl?.endRefreshing()
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
    // 課題データを取得するメソッド
    func loadTaskData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 配列の初期化
        taskDataArray = []
        
        // ユーザーの未解決課題データ取得
        // ログインユーザーの課題データで、かつisDeletedがfalseの課題を取得
        // 課題画面にて、古い課題を下、新しい課題を上に表示させるため、taskIDの降順にソートする
        let db = Firestore.firestore()
        db.collection("TaskData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("taskAchievement", isEqualTo: false)
            .order(by: "taskID", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDataCollection = document.data()
                
                    // 取得データを基に、課題データを作成
                    let databaseTaskData = TaskData()
                    databaseTaskData.setTaskID(taskDataCollection["taskID"] as! Int)
                    databaseTaskData.setTaskTitle(taskDataCollection["taskTitle"] as! String)
                    databaseTaskData.setTaskCause(taskDataCollection["taskCause"] as! String)
                    databaseTaskData.setTaskAchievement(taskDataCollection["taskAchievement"] as! Bool)
                    databaseTaskData.setIsDeleted(taskDataCollection["isDeleted"] as! Bool)
                    databaseTaskData.setUserID(taskDataCollection["userID"] as! String)
                    databaseTaskData.setCreated_at(taskDataCollection["created_at"] as! String)
                    databaseTaskData.setUpdated_at(taskDataCollection["updated_at"] as! String)
                    databaseTaskData.setMeasuresData(taskDataCollection["measuresData"] as! [String:[[String:Int]]])
                    databaseTaskData.setMeasuresPriority(taskDataCollection["measuresPriority"] as! String)
                    
                    // 課題データを格納
                    self.taskDataArray.append(databaseTaskData)
                }
                // テーブルビューの更新
                self.tableView?.reloadData()
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData(task taskData:TaskData) {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // 更新日時を現在時刻にする
        taskData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(Auth.auth().currentUser!.uid)_\(taskData.getTaskID())")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "taskTitle"      : taskData.getTaskTitle(),
            "taskCause"      : taskData.getTaskCouse(),
            "taskAchievement": taskData.getTaskAchievement(),
            "isDeleted"      : taskData.getIsDeleted(),
            "updated_at"     : taskData.getUpdated_at(),
            "measuresData"   : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }

}
