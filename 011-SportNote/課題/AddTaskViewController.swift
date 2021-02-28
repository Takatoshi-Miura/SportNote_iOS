//
//  AddTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/26.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class AddTaskViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
        
        // テキストビューの枠線付け
        causeTextView.layer.borderColor = UIColor.systemGray.cgColor
        causeTextView.layer.borderWidth = 1.0
        
        // ツールバーを作成
        createToolBar()
    }
        
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()         // データ用
    var measuresTitleArray:[String] = []    // 対策タイトルを格納する配列
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
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
                // 対策タイトルの配列に入力値を挿入。先頭に挿入する
                self.measuresTitleArray.insert(textField.text!,at:0)
                
                // 最有力の対策に設定
//                self.taskData.setMeasuresPriority(textField.text!)
                
                //テーブルに行が追加されたことをテーブルに通知
                self.tableView.insertRows(at: [IndexPath(row:0,section:0)],with: UITableView.RowAnimation.right)
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
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        // モーダルを閉じる
        dismiss(animated: true, completion: nil)
    }
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // 課題データを保存
        measuresTitleArray.reverse()
        dataManager.saveTaskData(title: taskTitleTextField.text!, cause: causeTextView.text!, measuresTitleArray: measuresTitleArray, {
            // モーダルを閉じる
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // 対策の項目数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measuresTitleArray.count
    }
    
    // セルを返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 対策セルを返却
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        cell.textLabel?.text = measuresTitleArray[indexPath.row]
        return cell
    }
    
    
    //MARK:- その他のメソッド
    
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
        causeTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }

}
