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
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()
    var index: Int = 0  // 行番号格納用
    
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarButtonDefault()
        setupTableView()
    }
    
    /**
     通常時のNavigationBar設定
     */
    func setNavigationBarButtonDefault() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonTapped(_:)))
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton])
    }
    
    /**
     編集時のNavigationBar設定
     */
    func setNavigationBarButtonIsEditing() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addButtonTapped(_:)))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(deleteButtonTapped(_:)))
        let resolveButton = UIBarButtonItem(image: UIImage(named: "check_on"),
                                            style: UIBarButtonItem.Style.plain,
                                            target: self,
                                            action: #selector(resolveButtonTapped(_:)))
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton, deleteButton, resolveButton])
    }
    
    @objc func addButtonTapped(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goAddTaskViewController", sender: nil)
    }
    
    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        guard self.tableView.indexPathsForSelectedRows != nil else { return }
        self.showDeleteTaskAlert({
            self.deleteTasks()
            self.setEditing(false, animated: true)
        })
    }
    
    /**
     課題削除アラートを表示
     - Parameters:
      - okAction: okタップ時の処理
     */
    func showDeleteTaskAlert(_ okAction: @escaping () -> ()) {
        let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive) {(action: UIAlertAction) in
            okAction()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        showAlert(title: "課題を削除", message: "選択された課題を削除します。\nよろしいですか？", actions: [okAction, cancelAction])
    }
    
    /**
     課題を複数個削除
     */
    func deleteTasks() {
        // 配列の要素削除でindexの矛盾を防ぐため、降順にソートしてから削除
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else { return }
        let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
        for indexPath in sortedIndexPaths {
            deleteTask(indexPath)
        }
    }
    
    /**
     課題を1つ削除
     */
    func deleteTask(_ indexPath: IndexPath) {
        dataManager.taskDataArray[indexPath.row].setIsDeleted(true)
        dataManager.updateTaskData(dataManager.taskDataArray[indexPath.row], {})
        dataManager.taskDataArray.remove(at:indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
    }
    
    @objc func resolveButtonTapped(_ sender: UIBarButtonItem) {
        guard self.tableView.indexPathsForSelectedRows != nil else { return }
        self.showResolveTaskAlert({
            self.resolveTasks()
            self.setEditing(false, animated: true)
        })
    }
    
    /**
     課題を解決済みにするアラートを表示
     */
    func showResolveTaskAlert(_ okAction: @escaping () -> ()) {
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            okAction()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        showAlert(title: "課題を解決済みにする", message: "選択された課題を解決済みにします。\nよろしいですか？", actions: [okAction,cancelAction])
    }
    
    /**
     選択された課題を解決済みにする
     */
    func resolveTasks() {
        // 配列の要素削除でindexの矛盾を防ぐため、降順にソートしてから解決済みにする
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else { return }
        let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
        for indexPath in sortedIndexPaths {
            resolveTask(indexPath)
        }
    }
    
    /**
     課題を1つ解決済みにする
     */
    func resolveTask(_ indexPath: IndexPath) {
        dataManager.taskDataArray[indexPath.row].changeAchievement()
        dataManager.updateTaskData(dataManager.taskDataArray[indexPath.row], {})
        dataManager.taskDataArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
    }
    
    /**
     NavigationBarにボタンをセット
     - Parameters:
      - leftBar: 左側に表示するボタン
      - rightBar: 右側に表示するボタン
     */
    func setNavigationBarButton(leftBar leftBarItems: [UIBarButtonItem],
                                rightBar rightBarItems: [UIBarButtonItem])
    {
        navigationItem.leftBarButtonItems = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    /**
     tableViewの初期設定
     */
    func setupTableView() {
        tableView.allowsMultipleSelectionDuringEditing = true   // 複数選択可能
        tableView.tableFooterView = UIView()                    // データのないセルを非表示
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUnresolvedTask()
    }
    
    /**
     未解決の課題を取得
     */
    func getUnresolvedTask() {
        dataManager.getUnresolvedTaskData({
            self.tableView?.reloadData()
            self.dataManager.sortTaskByOrder()
            self.dataManager.setTaskOrder()
            for task in self.dataManager.taskDataArray {
                self.dataManager.updateTaskData(task, {})
            }
        })
    }
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var tableView: UITableView!
    
    // 解決済みの課題一覧
    @IBAction func resolvedTaskListBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "goResolvedTaskViewController", sender: nil)
    }
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            setNavigationBarButtonIsEditing()
            self.editButtonItem.title = "完了"
        } else {
            setNavigationBarButtonDefault()
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
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
            self.index = indexPath.row
            performSegue(withIdentifier: "goTaskDetailViewController", sender: nil)
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            self.showDeleteTaskAlert({
                self.deleteTask(indexPath)
            })
        }
    }
    
    // セルを解決済みにするときの処理（右スワイプ）
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let resolveAction = UIContextualAction(style: .normal, title: "解決済み", handler: { (action: UIContextualAction, view: UIView, completion: (Bool) -> Void) in
            self.resolveTask(indexPath)
            completion(true)
        })
        resolveAction.backgroundColor = UIColor.systemBlue
        return UISwipeActionsConfiguration(actions: [resolveAction])
    }
    
    // 課題数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.taskDataArray.count
    }
    
    // 未解決の課題セルを取得
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            taskDetailViewController.taskData = dataManager.taskDataArray[index]
            taskDetailViewController.previousControllerName = "TaskViewController"
        } else if segue.identifier == "goResolvedTaskViewController" {
            // 解決済みの課題一覧画面へ遷移
        }
    }
    
    // TaskViewControllerに戻ったときの処理
    @IBAction func goToTaskViewController(_segue:UIStoryboardSegue) {
        dataManager.getUnresolvedTaskData({
            self.tableView?.reloadData()
        })
    }

}
