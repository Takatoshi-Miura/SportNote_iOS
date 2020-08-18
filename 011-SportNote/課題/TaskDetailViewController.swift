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

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        navigationController?.delegate = self

        // 受け取った課題データを表示する
        printTaskData(taskData)
        
        // TaskViewControllerから受け取った課題データの対策を取得
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
        createToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
        
        // デリゲートの設定
        taskTitleTextField.delegate = self
        taskCauseTextView.delegate = self
        
        // キーボードでテキストフィールドが隠れない設定
        self.configureObserver()
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()               // 課題データの格納用
    var measuresTitleArray:[String] = []    // 対策タイトルの格納用
    var indexPath:Int = 0                   // 行番号格納用
    var resolvedButtonTap:Bool = false      // 解決済みボタンのタップ判定
    var previousControllerName:String = ""  // 前のViewController名
    
    // キーボードでテキストフィールドが隠れないための設定用
    var selectedTextField: UITextField?
    var selectedTextView: UITextView?
    let screenSize = UIScreen.main.bounds.size
    var textHeight: CGFloat = 0.0
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // ボタン
    @IBOutlet weak var resolvedButton: UIButton!
    @IBOutlet weak var addMeasuresButton: UIButton!
    
    // 解決済みにするボタンの処理
    @IBAction func resolvedButton(_ sender: Any) {
        // タップ判定
        resolvedButtonTap = true
        
        // 解決済み or 未解決にする
        taskData.changeAchievement()
        
        // データ更新
        updateTaskData()
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
                self.taskData.addMeasures(title: textField.text!,effectiveness: "課題データに追記したノートデータ")
                
                // 最有力の対策に設定
                self.taskData.setMeasuresPriority(textField.text!)
                
                // 対策タイトルの配列に入力値を挿入。先頭に挿入する
                self.measuresTitleArray.insert(textField.text!,at:0)
                
                // データ更新
                self.updateTaskData()
                
                // テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
                
                // テーブル更新
                self.tableView.reloadData()
            }
        }
        // CANCELボタンを宣言
        let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        
        // ボタンを追加
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresTitleArray().count   // 対策の数を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        
        // 行番号に合った対策データをラベルに表示する
        cell.textLabel!.text = taskData.getMeasuresTitleArray()[indexPath.row]
        
        // 有効性コメントを取得
        if taskData.getMeasuresEffectivenessArray(at: indexPath.row).isEmpty == true {
            cell.detailTextLabel?.text = "有効性："
        } else {
            cell.detailTextLabel?.text = "有効性：\(self.taskData.getMeasuresEffectiveness(at: indexPath.row))"
        }
        cell.detailTextLabel?.textColor = UIColor.systemGray
        return cell
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // タップしたセルの行番号を取得
        self.indexPath = indexPath.row
        
        // 課題詳細確認画面へ遷移
        performSegue(withIdentifier: "goMeasuresDetailViewController", sender: nil)
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            return false
        } else {
            return true
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // アラートダイアログを生成
            let alertController = UIAlertController(title:"対策を削除",message:"対策を削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
            
            // OKボタンを宣言
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // 削除した対策が最有力だった場合、最有力を未設定にする
                if self.taskData.getMeasuresTitleArray()[indexPath.row] == self.taskData.getMeasuresPriority() {
                    self.taskData.setMeasuresPriority("")
                }
                
                // 次回以降、この対策データを取得しないようにする
                self.taskData.deleteMeasures(at: indexPath.row)
                
                // データを更新
                self.updateTaskData()
                
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                
                // リロード
                tableView.reloadData()
            }
            // CANCELボタンを宣言
            let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            
            // ボタンを追加
            alertController.addAction(okAction)
            alertController.addAction(cancelButton)
            
            //アラートダイアログを表示
            present(alertController,animated:true,completion:nil)
        }
    }
    
    // deleteの表示名を変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskViewController {
            // 課題データを更新
            updateTaskData()
        }
    }
    
    // 対策詳細画面に遷移する時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMeasuresDetailViewController" {
            // 課題データを対策詳細確認画面へ渡す
            let measuresDetailViewController = segue.destination as! MeasuresDetailViewController
            measuresDetailViewController.taskData  = taskData
            measuresDetailViewController.indexPath = indexPath
            measuresDetailViewController.previousControllerName = self.previousControllerName
        }
    }
    
    
    
    //MARK:- データベース関連
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 課題データを更新
        taskData.setTaskTitle(taskTitleTextField.text!)
        taskData.setTaskCause(taskCauseTextView.text!)
        
        // 更新日時を現在時刻にする
        taskData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let database = db.collection("TaskData").document("\(userID)_\(self.taskData.getTaskID())")

        // 変更する可能性のあるデータのみ更新
        database.updateData([
            "taskTitle"        : taskData.getTaskTitle(),
            "taskCause"        : taskData.getTaskCouse(),
            "taskAchievement"  : taskData.getTaskAchievement(),
            "isDeleted"        : taskData.getIsDeleted(),
            "updated_at"       : taskData.getUpdated_at(),
            "measuresData"     : taskData.getMeasuresData(),
            "measuresPriority" : taskData.getMeasuresPriority()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
                
                // 解決済みボタンをタップした場合
                if self.resolvedButtonTap == true {
                    // 前の画面に戻る
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // セルの内容を表示するメソッド
    func printTaskData(_ taskData:TaskData) {
        taskTitleTextField.text = taskData.getTaskTitle()
        taskCauseTextView.text  = taskData.getTaskCouse()
    }
    
    // テキストフィールド以外をタップでキーボードを下げる設定
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // キーボードを出したときの設定
    func configureObserver() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedTextField = textField
        self.textHeight = textField.frame.maxY
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.selectedTextView = textView
        self.textHeight = textView.frame.maxY
    }
        
    @objc func keyboardWillShow(_ notification: Notification?) {
            
        guard let rect = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification?.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
                    
        // サイズ取得
        let screenHeight = screenSize.height
        let keyboardHeight = rect.size.height
        
        // スクロールする高さを計算
        let hiddenHeight = keyboardHeight + textHeight - screenHeight
                
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
    
    // ツールバーを作成するメソッド
    func createToolBar() {
        // ツールバーのインスタンスを作成
        let toolBar = UIToolbar()

        // ツールバーに配置するアイテムのインスタンスを作成
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let okButton: UIBarButtonItem = UIBarButtonItem(title: "完了", style: UIBarButtonItem.Style.plain, target: self, action: #selector(tapOkButton(_:)))

        // アイテムを配置
        toolBar.setItems([flexibleItem, okButton], animated: true)

        // ツールバーのサイズを指定
        toolBar.sizeToFit()
        
        // テキストフィールドにツールバーを設定
        taskTitleTextField.inputAccessoryView = toolBar
        taskCauseTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
}
