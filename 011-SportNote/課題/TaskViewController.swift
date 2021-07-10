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
        
        // ナビゲーションバーボタン作成
        addButton     = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        deleteButton  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
        resolveButton = UIBarButtonItem(image: UIImage(named: "check_on"), style:UIBarButtonItem.Style.plain, target:self, action: #selector(resolveButtonTapped(_:)))
        
        // ナビゲーションバーのボタンをセット
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton])
        
        // 編集ボタンの設定(複数選択可能)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    /**
     ナビゲーションボタンをセット
     - Parameters:
      - leftBar: 左側に表示するボタン
      - rightBar: 右側に表示するボタン
     */
    func setNavigationBarButton(leftBar leftBarItems: [UIBarButtonItem], rightBar rightBarItems: [UIBarButtonItem]) {
        navigationItem.leftBarButtonItems  = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 未解決課題データを取得
        refreshTask()
    }
    
    /**
     リフレッシュ処理
     */
    func refreshTask() {
        dataManager.getUnresolvedTaskData({
            self.tableView?.reloadData()
            self.dataManager.sortTaskByOrder()
            self.dataManager.setTaskOrder()
            for task in self.dataManager.taskDataArray {
                self.dataManager.updateTaskData(task, {})
            }
        })
    }
    
    
    //MARK:- 変数の宣言
    
    // データ
    var dataManager = DataManager()
    
    // リフレッシュ機能用
    fileprivate let refreshCtl = UIRefreshControl()
    
    // 行番号格納用
    var indexPath: Int = 0
    
    // ナビゲーションバーのボタン
    var deleteButton: UIBarButtonItem!   // ゴミ箱ボタン
    var resolveButton: UIBarButtonItem!  // 解決済みボタン
    var addButton: UIBarButtonItem!      // 課題追加ボタン
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 解決済みの課題一覧
    @IBAction func resolvedTaskListBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "goResolvedTaskViewController", sender: nil)
    }
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,deleteButton,resolveButton])
            self.editButtonItem.title = "完了"
        } else {
            self.setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton])
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
    }
    
    // ゴミ箱ボタンの処理
    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        self.deleteRows()
    }
    
    // 複数のセルを削除
    func deleteRows() {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        // OKボタン
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // 配列の要素削除で、indexの矛盾を防ぐため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            // 選択された課題を削除する
            for indexPathList in sortedIndexPaths {
                self.dataManager.taskDataArray[indexPathList.row].setIsDeleted(true)
                self.dataManager.updateTaskData(self.dataManager.taskDataArray[indexPathList.row], {})
                self.dataManager.taskDataArray.remove(at: indexPathList.row)
            }
            // tableViewの行を削除
            self.tableView.deleteRows(at: sortedIndexPaths, with: UITableView.RowAnimation.automatic)
            // 編集状態を解除
            self.setEditing(false, animated: true)
        }
        // CANCELボタン
        let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        showAlert(title: "課題を削除", message: "選択された課題を削除します。\nよろしいですか？", actions: [okAction,cancelAction])
    }
    
    // 解決済みボタンの処理
    @objc func resolveButtonTapped(_ sender: UIBarButtonItem) {
        self.resolveRows()
    }
    
    // 複数のセルを解決済みにする
    func resolveRows() {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"OK",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 配列の要素削除で、indexの矛盾を防ぐため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            
            // 選択された課題を解決済みにする
            for indexPathList in sortedIndexPaths {
                self.dataManager.taskDataArray[indexPathList.row].changeAchievement()
                self.dataManager.updateTaskData( self.dataManager.taskDataArray[indexPathList.row], {})
                self.dataManager.taskDataArray.remove(at: indexPathList.row)
            }
            
            // tableViewの行を削除
            self.tableView.deleteRows(at: sortedIndexPaths, with: UITableView.RowAnimation.automatic)
            
            // 編集状態を解除
            self.setEditing(false, animated: true)
        }
        // CANCELボタン
        let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        showAlert(title: "課題を解決済みにする", message: "選択された課題を解決済みにします。\nよろしいですか？", actions: [okAction,cancelAction])
    }
    
    // 課題追加ボタンの処理
    @objc func addButtonTapped(_ sender: UIBarButtonItem) {
        // 課題追加画面に遷移
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルの編集を許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルの並び替えを許可
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルの並び替え時の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 並び順を保存
        let task: Task = dataManager.taskDataArray[sourceIndexPath.row]
        self.dataManager.taskDataArray.remove(at: sourceIndexPath.row)
        self.dataManager.taskDataArray.insert(task, at: destinationIndexPath.row)
        self.dataManager.setTaskOrder()
        for task in self.dataManager.taskDataArray {
            self.dataManager.updateTaskData(task, {})
        }
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
        } else {
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // 課題詳細確認画面へ遷移
            self.indexPath = indexPath.row
            performSegue(withIdentifier: "goTaskDetailViewController", sender: nil)
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // OKボタン
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // taskDataを更新
                self.dataManager.taskDataArray[indexPath.row].setIsDeleted(true)
                self.dataManager.updateTaskData( self.dataManager.taskDataArray[indexPath.row], {})
                    
                // taskDataArrayから削除
                self.dataManager.taskDataArray.remove(at:indexPath.row)
                    
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
            // CANCELボタン
            let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            showAlert(title: "課題を削除", message: "課題を削除します。\nよろしいですか？", actions: [okAction,cancelAction])
        }
    }
    
    // セルを解決済みにするときの処理（右スワイプ）
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // アクションの定義
        let resolveAction = UIContextualAction(style: .normal,title: "解決済み",handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            // 解決済みにする
            self.dataManager.taskDataArray[indexPath.row].changeAchievement()
            self.dataManager.updateTaskData( self.dataManager.taskDataArray[indexPath.row], {})
            
            // taskDataArrayから削除
            self.dataManager.taskDataArray.remove(at:indexPath.row)
            
            // セルをテーブルから削除
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            
            // 処理を実行完了した場合はtrue
            completion(true)
        })
        resolveAction.backgroundColor = UIColor.systemBlue
        
        return UISwipeActionsConfiguration(actions: [resolveAction])
    }
    
    // 課題数を返却する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.taskDataArray.count
    }
    
    // セルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 未解決の課題セルを取得する
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        cell.textLabel!.text = dataManager.taskDataArray[indexPath.row].getTitle()
        cell.detailTextLabel!.text = "原因：\(dataManager.taskDataArray[indexPath.row].getCause())"
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTaskDetailViewController" {
            // 表示する課題データを課題詳細確認画面へ渡す
            let taskDetailViewController = segue.destination as! TaskDetailViewController
            taskDetailViewController.taskData = dataManager.taskDataArray[indexPath]
            taskDetailViewController.previousControllerName = "TaskViewController"
        } else if segue.identifier == "goResolvedTaskViewController" {
            // 解決済みの課題一覧画面へ遷移
        }
    }
    
    // TaskViewControllerに戻ったときの処理
    @IBAction func goToTaskViewController(_segue:UIStoryboardSegue) {
        dataManager.getUnresolvedTaskData({
            // テーブルビューの更新
            self.tableView?.reloadData()
        })
    }

}
