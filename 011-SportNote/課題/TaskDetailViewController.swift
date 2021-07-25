//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/27.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class TaskDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()
    var taskData = Task()                   // 課題データの格納用
    var measuresTitleArray: [String] = []   // 対策タイトルの格納用
    var indexPath: IndexPath = [0, 0]       // 行番号格納用
    var previousControllerName: String = "" // 前のViewController名
    var textFrame_y: CGFloat = 0.0          // textのY座標
    

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self

        // 受け取った課題データを表示する
        taskTitleTextField.text = taskData.getTitle()
        taskCauseTextView.text  = taskData.getCause()
        measuresTitleArray = taskData.getMeasuresTitleArray()
        
        // テキストビューの枠線付け
        taskCauseTextView.layer.borderColor = UIColor.systemGray.cgColor
        taskCauseTextView.layer.borderWidth = 1.0
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
        
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            // 解決済みボタンを未解決ボタンに変更
            self.resolvedButton.backgroundColor = UIColor.systemRed
            self.resolvedButton.setTitle("未解決に戻す", for: .normal)
            
            // 対策追加ボタンを隠す
            self.addMeasuresButton.isHidden = true
            
            // テキストを編集不可能にする
            self.taskTitleTextField.isEnabled = false
            self.taskCauseTextView.isEditable = false
            self.taskCauseTextView.isSelectable = false
        }
        
        // ツールバーを作成
        taskTitleTextField.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
        taskCauseTextView.inputAccessoryView = taskTitleTextField.inputAccessoryView
    }
    
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView?.reloadData()
        
        taskTitleTextField.delegate = self
        taskCauseTextView.delegate = self
        
        addKeyboadObserver()
    }
    
    /**
     キーボードの通知設定(キーボードでテキストフィールドが隠れない設定)
     */
    func addKeyboadObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self,
                                 selector: #selector(keyboardWillShow(_:)),
                                 name: UIResponder.keyboardWillShowNotification,
                                 object: nil)
        notification.addObserver(self,
                                 selector: #selector(keyboardWillHide(_:)),
                                 name: UIResponder.keyboardWillHideNotification,
                                 object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification?) {
        guard let keyboad = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        // スクロールする高さを計算
        let hiddenHeight = keyboad.size.height + textFrame_y - UIScreen.main.bounds.size.height
                
        // スクロール処理
        if hiddenHeight > 0 {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -(hiddenHeight + 20))
                self.view.transform = transform
            }
        } else {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -(0))
                self.view.transform = transform
            }
        }
    }
        
    @objc func keyboardWillHide(_ notification: Notification?)  {
        guard let duration = notification?.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.textFrame_y = textField.frame.maxY
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.textFrame_y = textView.frame.maxY
    }
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resolvedButton: UIButton!
    @IBOutlet weak var addMeasuresButton: UIButton!
    
    // 解決済みにするボタンの処理
    @IBAction func resolvedButton(_ sender: Any) {
        // 解決済み or 未解決にする
        taskData.changeAchievement()
        
        // データ更新
        taskData.setTitle(taskTitleTextField.text!)
        taskData.setCause(taskCauseTextView.text!)
        taskData.setOrder(0)
        dataManager.updateTaskData(taskData, {
            // 前の画面に戻る
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    // 追加ボタンの処理
    @IBAction func addMeasuresButton(_ sender: Any) {
        // アラートを生成
        let alertController = UIAlertController(title: "対策を追加", message: "対策を入力してください", preferredStyle: UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler: nil)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                // 対策を追加
                self.taskData.setTitle(self.taskTitleTextField.text!)
                self.taskData.setCause(self.taskCauseTextView.text!)
                self.taskData.setMeasuresPriority(textField.text!)
                self.taskData.addMeasures(title: textField.text!, effectiveness: "連動したノートが表示されます")
                self.dataManager.updateTaskData(self.taskData, {})
                
                // テーブルに反映
                self.measuresTitleArray.insert(textField.text!, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
            }
        }
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresTitleArray().count   // 対策の数を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 対策セルを返却
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        cell.textLabel!.text = taskData.getMeasuresTitleArray()[indexPath.row]
        cell.detailTextLabel?.textColor = UIColor.systemGray
        if taskData.getMeasuresEffectivenessArray(at: indexPath.row).isEmpty {
            cell.detailTextLabel?.text = "有効性："
        } else {
            cell.detailTextLabel?.text = "有効性：\(self.taskData.getMeasuresEffectiveness(at: indexPath.row))"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 課題詳細確認画面へ遷移
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        self.indexPath = indexPath
        performSegue(withIdentifier: "goMeasuresDetailViewController", sender: nil)
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if previousControllerName == "ResolvedTaskViewController" {
            return false
        } else {
            return true
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteMeasureAlert({
                self.deleteMeasure(indexPath)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            })
        }
    }
    
    /**
     対策削除アラートを表示
     - Parameters:
      - okAction: okタップ時の処理
     */
    func showDeleteMeasureAlert(_ okAction: @escaping () -> ()) {
        let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.destructive) {(action: UIAlertAction) in
            okAction()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        showAlert(title: "対策を削除", message: "対策を削除します。よろしいですか？", actions: [okAction, cancelAction])
    }
    
    /**
     対策を削除
     - Parameters:
      - indexPath: 削除する対策のIndexPath
     */
    func deleteMeasure(_ indexPath: IndexPath) {
        taskData.deleteMeasures(at: indexPath.row)
        if taskData.getMeasuresTitleArray()[indexPath.row] == taskData.getMeasuresPriority() {
            taskData.setMeasuresPriority("")
        }
        dataManager.updateTaskData(taskData, {})
    }
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskViewController {
            // 課題データを更新
            taskData.setTitle(taskTitleTextField.text!)
            taskData.setCause(taskCauseTextView.text!)
            dataManager.updateTaskData(taskData, {})
        }
    }
    
    // 対策詳細画面に遷移する時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMeasuresDetailViewController" {
            // 課題データを対策詳細確認画面へ渡す
            let measuresDetailViewController = segue.destination as! MeasuresDetailViewController
            measuresDetailViewController.taskData  = taskData
            measuresDetailViewController.indexPath = indexPath.row
            measuresDetailViewController.previousControllerName = self.previousControllerName
        }
    }
    
}
