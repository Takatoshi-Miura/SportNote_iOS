//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/13.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol TaskDetailViewControllerDelegate: AnyObject {
    // 課題の完了(未完了)時の処理
    func taskDetailVCCompleteTask(task: Task)
    // 課題削除時の処理
    func taskDetailVCDeleteTask(task: Task)
    // 対策セルタップ時の処理
    func taskDetailVCMeasuresCellDidTap(measures: Measures)
}

class TaskDetailViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var measuresArray: [Measures] = []
    var task = Task()
    var delegate: TaskDetailViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        addButton.isHidden = task.isComplete ? true : false
        let realmManager = RealmManager()
        measuresArray = realmManager.getMeasuresInTask(ID: task.taskID)
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 対策が削除されていれば取り除く
            let measures = measuresArray[selectedIndex.row]
            if measures.isDeleted {
                measuresArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.updateTask(task: task)
            for measures in measuresArray {
                firebaseManager.updateMeasures(measures: measures)
            }
        }
    }
    
    func initNavigationBar() {
        self.title = TITLE_TASK_DETAIL
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
        let image = task.isComplete ? UIImage(systemName: "exclamationmark.circle") : UIImage(systemName: "checkmark.circle")
        let completeButton = UIBarButtonItem(image: image, style: .done, target: self, action: #selector(completeTask))
        navigationItems.append(deleteButton)
        navigationItems.append(completeButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    func initTableView() {
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func initView() {
        titleLabel.text = TITLE_TITLE
        causeLabel.text = TITLE_CAUSE
        measuresLabel.text = TITLE_MEASURES
        titleTextField.text = task.title
        causeTextView.text = task.cause
        causeTextView.layer.borderColor = UIColor.systemGray6.cgColor
        causeTextView.layer.borderWidth = 1.0
        causeTextView.layer.cornerRadius = 5.0
        causeTextView.layer.masksToBounds = true
    }
    
    // MARK: - Action
    
    /// 課題を削除
    @objc func deleteTask() {
        showDeleteAlert(title: TITLE_DELETE_TASK, message: MESSAGE_DELETE_TASK, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateTaskIsDeleted(task: self.task)
            self.delegate?.taskDetailVCDeleteTask(task: self.task)
        })
    }
    
    /// 課題を完了(未完了)にする
    @objc func completeTask() {
        let isCompleted = task.isComplete
        let message = isCompleted ? MESSAGE_INCOMPLETE_TASK : MESSAGE_COMPLETE_TASK
        showOKCancelAlert(title: TITLE_COMPLETE_TASK, message: message, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateTaskIsCompleted(task: self.task, isCompleted: !isCompleted)
            self.delegate?.taskDetailVCCompleteTask(task: self.task)
        })
    }
    
    /// 対策を追加
    @IBAction func tapAddButton(_ sender: Any) {
        let alert = UIAlertController(title: TITLE_ADD_MEASURES, message: MESSAGE_ADD_MEASURES, preferredStyle: .alert)
        
        var alertTextField: UITextField?
        alert.addTextField(configurationHandler: {(textField) -> Void in
            alertTextField = textField
        })
        
        let OKAction = UIAlertAction(title: TITLE_ADD, style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
            if (alertTextField?.text == nil || alertTextField?.text == "") {
                self.showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
            } else {
                self.addMeasures(title: alertTextField!.text!)
            }
        })
        
        let cancelAction = UIAlertAction(title: TITLE_CANCEL, style: UIAlertAction.Style.cancel, handler: nil)
        
        let actions = [OKAction, cancelAction]
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    func addMeasures(title: String) {
        // 対策データを作成＆保存
        let realmManager = RealmManager()
        let measures = Measures()
        measures.taskID = task.taskID
        measures.title = title
        measures.order = realmManager.getMeasuresInTask(ID: task.taskID).count
        
        if !realmManager.createRealm(object: measures) {
            showErrorAlert(message: ERROR_MESSAGE_TASK_CREATE_FAILED)
            return
        }
        
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveMeasures(measures: measures, completion: {})
        }
        
        // tableView更新
        let index: IndexPath = [0, measures.order]
        measuresArray.append(measures)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
}

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true     // 並び替え可能
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 対策の並び順を保存
        let measures = measuresArray[sourceIndexPath.row]
        measuresArray.remove(at: sourceIndexPath.row)
        measuresArray.insert(measures, at: destinationIndexPath.row)
        let realmManager = RealmManager()
        realmManager.updateMeasuresOrder(measuresArray: measuresArray)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if measuresArray.isEmpty {
            return 0
        } else {
            return measuresArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = measuresArray[indexPath.row].title
        cell.backgroundColor = UIColor.systemGray6
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 対策画面へ遷移
        let measures = measuresArray[indexPath.row]
        delegate?.taskDetailVCMeasuresCellDidTap(measures: measures)
    }
    
}

extension TaskDetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == task.title {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
            textField.text = task.title
            return false
        }
        
        let realmManager = RealmManager()
        realmManager.updateTaskTitle(taskID: task.taskID, title: textField.text!)
        return true
    }
    
}

extension TaskDetailViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 差分がなければ何もしない
        if textView.text! == task.cause {
            return
        }
        
        let realmManager = RealmManager()
        realmManager.updateTaskCause(taskID: task.taskID, cause: textView.text!)
    }
    
}

