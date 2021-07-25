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
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()         // データ用
    var measuresPriorityTitle = ""          // 最有力の対策名を格納
    var measuresTitleArray: [String] = []   // 対策名を格納する配列
    
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
        
        // テキストビューの枠線付け
        causeTextView.layer.borderColor = UIColor.systemGray.cgColor
        causeTextView.layer.borderWidth = 1.0
        
        // ツールバーを作成
        taskTitleTextField.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
        causeTextView.inputAccessoryView = taskTitleTextField.inputAccessoryView
    }
    
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    
    // 追加ボタンの処理
    @IBAction func addMeasuresButton(_ sender: Any) {
        // アラートを生成
        let alertController = UIAlertController(title: "対策を追加", message: "対策を入力してください", preferredStyle: UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler:nil)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {(action: UIAlertAction) in
            if let textField = alertController.textFields?.first {
                self.addMeasure(textField.text!)
            }
        }
        let cancelButton = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil)
        
        alertController.addAction(okAction)
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /**
     対策を追加
     - Parameters:
     - title: 対策名
     */
    func addMeasure(_ title: String) {
        if measuresTitleArray.firstIndex(of: title) == nil {
            measuresPriorityTitle = title
            measuresTitleArray.insert(title, at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: UITableView.RowAnimation.right)
        } else {
            SVProgressHUD.showError(withStatus: "同じ対策名が存在します。\n別の名前にしてください。")
        }
    }
    
    // 戻るボタンの処理
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // 課題データを保存
        measuresTitleArray.reverse()
        dataManager.saveTaskData(title: taskTitleTextField.text!,
                                 cause: causeTextView.text!,
                                 measuresTitleArray: measuresTitleArray,
                                 measuresPriority: measuresPriorityTitle,
        {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return measuresTitleArray.count // 対策の項目数を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "measuresCell", for: indexPath)
        cell.textLabel?.text = measuresTitleArray[indexPath.row]
        return cell // 対策セルを返却
    }

}
