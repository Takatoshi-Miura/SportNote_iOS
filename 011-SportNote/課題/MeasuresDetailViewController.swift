//
//  MeasuresDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/06/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MeasuresDetailViewController: UIViewController,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate {
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの指定
        measuresTitleTextField.delegate = self
        navigationController?.delegate = self
        
        // チェックボックスの設定
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()

        // 対策データの表示
        measuresTitleTextField.text = taskData.getMeasuresTitleArray()[indexPath]
        
        // 最有力の対策ならチェックボックスを選択済みにする
        if taskData.getMeasuresPriority() == taskData.getMeasuresTitleArray()[indexPath] {
            self.checkButton.isSelected = !self.checkButton.isSelected
        }
        
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            // テキストを編集不可能にする
            self.measuresTitleTextField.isEnabled = false
        }
        
        // ツールバーを作成
        createToolBar()
    }
    
    
    
    //MARK:- 変数の宣言
    
    var taskData = TaskData()               // 課題データ格納用
    var indexPath = 0                       // 行番号格納用
    var noteData = NoteData()               // ノートデータ格納用（有効性セルタップ時にデータを格納）
    var previousControllerName:String = ""  // 前のViewController名
    
    
    
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
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            // 編集不可能
        } else {
            // 選択状態を反転させる
            self.checkButton.isSelected = !self.checkButton.isSelected
        }
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 有効性コメント数を返却
        if self.taskData.getMeasuresEffectivenessArray(at: indexPath).isEmpty {
            return 0
        } else {
            return self.taskData.getMeasuresEffectivenessArray(at: indexPath).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        // [有効性コメント:ノートID]配列を取得
        let effectivenessArray = self.taskData.getMeasuresEffectivenessArray(at: self.indexPath)
        
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
        let effectivenessArray = self.taskData.getMeasuresEffectivenessArray(at: self.indexPath)
        
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
            // ノートデータを取得
            loadNoteData(effectivenessArray[indexPath.row][comment]!)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            return false    // 編集不可能
        } else {
            return true     // 編集可能
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // OKボタン
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // 有効性データを削除
                let effectiveness = self.taskData.getMeasuresEffectivenessArray(at: self.indexPath)
                let title = self.taskData.getMeasuresTitleArray()[self.indexPath]
                self.taskData.deleteEffectiveness(measuresTitle: title, effectivenessArray: effectiveness, at: indexPath.row)
                // データを更新
                self.updateTaskData()
            }
            // CANCELボタン
            let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            showAlert(title: "有効性コメントを削除", message: "コメントを削除します。よろしいですか？", actions: [okAction,cancelAction])
        }
    }
    
    // deleteの表示名を変更
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "削除"
    }
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskDetailViewController {
            // データ更新
            updateTaskData()
        }
    }
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPracticeNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! PracticeNoteDetailViewController
            noteDetailViewController.noteData = self.noteData
        }
    }
    
    
    
    //MARK:- データベース関連
    
    // Firebaseの課題データを更新するメソッド
    func updateTaskData() {
        // 同じ対策名の登録がないか確認
        var measuresTitleCheck:Bool = false
        for num in 0...taskData.getMeasuresTitleArray().count - 1 {
            if num == indexPath {
                // 判定しない
            } else {
                // 対策名被りのチェック
                if measuresTitleTextField.text == taskData.getMeasuresTitleArray()[num] {
                    measuresTitleCheck = true
                }
            }
        }
        
        // 同じ対策名の登録があった場合
        if measuresTitleCheck == true {
            SVProgressHUD.showError(withStatus: "同じ対策名が存在します。\n別の名前にしてください。")
            return
        } else {
            // 対策を更新
            taskData.updateMeasuresTitle(newTitle: measuresTitleTextField.text!, at: indexPath)
        }
        
        // チェックボックスが選択されている場合は、この対策を最有力にする
        if self.checkButton.isSelected {
            taskData.setMeasuresPriority(measuresTitleTextField.text!)
        }
        
        // データを更新
        let dataManager = DataManager()
        dataManager.updateTaskData(task: self.taskData, {
            self.tableView.reloadData()
        })
    }
    
    // Firebaseから指定したノートIDのデータを取得するメソッド
    func loadNoteData(_ noteID:Int) {
        let dataManager = DataManager()
        dataManager.getNoteData(noteID, {
            // ノートデータ取得
            self.noteData = dataManager.noteDataArray[0]
            // ノート詳細確認画面へ遷移
            self.performSegue(withIdentifier: "goToPracticeNoteDetailViewController", sender: nil)
        })
    }
    
    
    
    //MARK:- その他のメソッド
    
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
