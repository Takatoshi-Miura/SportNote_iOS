//
//  MeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import SVProgressHUD

class MeasuresDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource {
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        tableView.delegate   = self
        tableView.dataSource = self
        navigationController?.delegate = self
        
        // チェックボックスの設定
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()

        // 受け取った対策データを表示
        printMeasuresData(taskData)
        
        // ツールバーを作成
        createToolBar()
    }
    
    
    
    //MARK:- 変数の宣言
    var taskData = TaskData()   // 課題データ格納用
    var indexPath = 0           // 行番号格納用
    let noteData = NoteData()   // ノートデータ格納用（有効性セルタップ時にデータを格納）
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var measuresTitleTextField: UITextField!
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // チェックボックス
    @IBOutlet weak var checkButton: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    // チェックボックスがタップされた時の処理
    @IBAction func checkButtonTap(_ sender: Any) {
        // 選択状態を反転させる
        self.checkButton.isSelected = !self.checkButton.isSelected
    }
    
    // 追加ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"有効性コメントを追加",message:"有効性を入力してください",preferredStyle:UIAlertController.Style.alert)
        
        // テキストエリアを追加
        alertController.addTextField(configurationHandler:nil)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"OK",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            if let textField = alertController.textFields?.first {
                // 有効性の配列にコメントを追加。
                self.taskData.addEffectiveness(self.taskData.getMeasuresTitleArray()[self.indexPath], textField.text!,0)
                
                // データを更新
                self.taskData.updateTaskData()
                
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 有効性コメント数を返却
        return self.taskData.getMeasuresEffectivenessArray(indexPath).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        // [有効性コメント:ノートID]配列を取得
        let effectivenessArray = self.taskData.getMeasuresEffectivenessArray(self.indexPath)
        
        // 有効性コメントのみの配列を作成
        var stringArray:[String] = []
        for num in 0...effectivenessArray.count - 1 {
            stringArray.append(contentsOf: effectivenessArray[num].keys)
        }
        
        // 有効性コメントを取得＆返却
        cell.textLabel!.text = "\(stringArray[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // [有効性コメント:ノートID]配列を取得
        let effectivenessArray = self.taskData.getMeasuresEffectivenessArray(self.indexPath)
        
        // 有効性コメントのみの配列を作成
        var stringArray:[String] = []
        for num in 0...effectivenessArray.count - 1 {
            stringArray.append(contentsOf: effectivenessArray[num].keys)
        }
        
        // タップされた有効性コメントを取得
        let comment:String = stringArray[indexPath.row]
        
        // ノートIDが存在をチェック
        if effectivenessArray[indexPath.row][comment] == 0 {
            // ノートIDがゼロなら何もしない
        } else {
            SVProgressHUD.showSuccess(withStatus: "ノート情報を取得しました。")
            
            // ノートデータを取得
            noteData.loadNoteData(effectivenessArray[indexPath.row][comment]!)
            
            // データの取得が終わるまで時間待ち
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                
                // ノート詳細確認画面へ遷移
                self.performSegue(withIdentifier: "goNoteDetailView", sender: nil)
            }
        }
    }
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskDetailViewController {
            // 対策データを更新
            if self.taskData.getMeasuresTitleArray()[indexPath] == measuresTitleTextField.text {
                // 何もしない
            } else {
                // 新しい対策名に更新
                self.taskData.updateMeasuresTitle(measuresTitleTextField.text!, indexPath)
            }
            
            // チェックボックスが選択されている場合は、この対策を最有力にする
            if self.checkButton.isSelected {
                taskData.setMeasuresPriorityIndex(indexPath)
            }
            
            taskData.updateTaskData()
        }
    }
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNoteDetailView" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            noteDetailViewController.noteData = self.noteData.noteDataArray[0]
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // データを表示するメソッド
    func printMeasuresData(_ taskData:TaskData) {
        // テキストの表示
        measuresTitleTextField.text = taskData.getMeasuresTitleArray()[indexPath]
        
        // 最有力の対策ならチェックボックスを選択済みにする
        if taskData.getMeasuresPriorityIndex() == indexPath {
            self.checkButton.isSelected = !self.checkButton.isSelected
        }
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
        measuresTitleTextField.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }

}
