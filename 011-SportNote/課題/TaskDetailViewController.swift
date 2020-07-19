//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/27.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class TaskDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
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
        
        // ツールバーを作成
        createToolBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView?.reloadData()
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()               // 課題データの格納用
    var measuresTitleArray:[String] = []    // 対策タイトルの格納用
    var indexPath:Int = 0                   // 行番号格納用
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskCauseTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 解決済みにするボタンの処理
    @IBAction func resolvedButton(_ sender: Any) {
        // 解決済みにする
        taskData.changeAchievement()
        
        // 通知
        SVProgressHUD.showSuccess(withStatus: "解決済みにしました")
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
                self.taskData.addMeasures(title: textField.text!,effectiveness: "対策の有効性をコメントしましょう")
                
                // 対策タイトルの配列に入力値を挿入。先頭に挿入する
                self.measuresTitleArray.insert(textField.text!,at:0)
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
            }
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
    
    
    
    //MARK:- テーブルビューの設定
    
    // 対策の数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskData.getMeasuresTitleArray().count
    }
    
    // テーブルの行ごとのセルを返却する
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Storyboardで指定したtodoCell識別子を利用して再利用可能なセルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        
        //行番号に合った対策データをラベルに表示する
        cell.textLabel!.text = taskData.getMeasuresTitleArray()[indexPath.row]
        
        // 有効性コメントを取得
        if taskData.getMeasuresEffectivenessArray(at: indexPath.row).count == 0 {
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
        print(indexPath.row)
        
        // 課題詳細確認画面へ遷移
        performSegue(withIdentifier: "goMeasuresDetailViewController", sender: nil)
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // アラートダイアログを生成
            let alertController = UIAlertController(title:"対策を削除",message:"対策を削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
            
            // OKボタンを宣言
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // OKボタンがタップされたときの処理
                // 次回以降、この対策データを取得しないようにする
                self.taskData.deleteMeasures(at: indexPath.row)
                
                // 削除した対策が最有力だった場合、他の対策を最有力にする
                if indexPath.row == self.taskData.getMeasuresPriorityIndex() {
                    self.taskData.setMeasuresPriorityIndex(0)
                }
                
                // データを更新
                self.taskData.updateTaskData()
                    
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                
                // リロード
                tableView.reloadData()
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
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskViewController {
            // 課題データを更新
            taskData.setTaskTitle(taskTitleTextField.text!)
            taskData.setTaskCause(taskCauseTextView.text!)
            taskData.updateTaskData()
        }
    }
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goMeasuresDetailViewController" {
            // 課題データを対策詳細確認画面へ渡す
            let measuresDetailViewController = segue.destination as! MeasuresDetailViewController
            measuresDetailViewController.taskData = taskData
            measuresDetailViewController.indexPath = indexPath
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

}
