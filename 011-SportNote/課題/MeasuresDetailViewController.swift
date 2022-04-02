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
    
    //MARK:- 変数の宣言
    
    var task = Task_old()                       // 課題データ格納用
    var indexPath: IndexPath = [0, 0]       // 行番号格納用
    var noteData = Note_old()                   // ノートデータ格納用（有効性セルタップ時にデータを格納）
    var previousControllerName: String = "" // 前のViewController名
    
    
    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        measuresTitleTextField.delegate = self
        navigationController?.delegate = self
        
        // チェックボックスの設定
        checkButton.setImage(UIImage(named: "check_off"), for: .normal)
        checkButton.setImage(UIImage(named: "check_on"), for: .selected)
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()

        // 対策データの表示
        measuresTitleTextField.text = task.getMeasuresTitleArray()[indexPath.row]
        
        // 最有力の対策ならチェックボックスを選択済みにする
        if task.getMeasuresPriority() == task.getMeasuresTitleArray()[indexPath.row] {
            checkButton.isSelected = !checkButton.isSelected
        }
        
        // 解決済みの課題の場合の設定
        if previousControllerName == "ResolvedTaskViewController" {
            // テキストを編集不可能にする
            self.measuresTitleTextField.isEnabled = false
        }
        
        // ツールバーを作成
        measuresTitleTextField.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
    }
    
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var measuresTitleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBAction func checkButtonTap(_ sender: Any) {
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
        let measuresEffectiveness: [[String: Int]] = task.getMeasuresEffectivenessArray(at: indexPath.row)
        if measuresEffectiveness.isEmpty {
            return 0
        } else {
            return measuresEffectiveness.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 連動したノートのセルを取得
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let measuresEffectivenessComments = task.getEffectivenessComments(at: self.indexPath.row)
        if measuresEffectivenessComments.count > 0 {
            cell.textLabel!.text = "\(measuresEffectivenessComments[indexPath.row])"
        }
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // タップしたときの選択色を消去
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        // 連動するノートを取得
        let effectivenessComments = task.getEffectivenessComments(at: self.indexPath.row)
        if effectivenessComments.count > 0 {
            let comment = effectivenessComments[indexPath.row]
            if let noteID = task.getEffectivenessNoteID(at: self.indexPath.row, indexPath.row, comment) {
                loadNoteData(noteID)
            }
        }
    }
    
    /**
     連動するノートを取得＆遷移
     - Parameters:
     - noteID: ノートID
     */
    func loadNoteData(_ noteID: Int) {
        let dataManager = DataManager()
        dataManager.getNoteData(noteID, {
            self.noteData = dataManager.noteDataArray[0]
            self.performSegue(withIdentifier: "goToPracticeNoteDetailViewController", sender: nil)
        })
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
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteEffectivenessAlert({
                // 有効性データを削除
                let effectiveness = self.task.getMeasuresEffectivenessArray(at: self.indexPath.row)
                let title = self.task.getMeasuresTitleArray()[self.indexPath.row]
                self.task.deleteEffectiveness(measuresTitle: title, effectivenessArray: effectiveness, at: indexPath.row)
                let dataManager = DataManager()
                dataManager.updateTaskData(self.task, {
                    tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
                })
            })
        }
    }
    
    /**
     有効性コメント削除アラートを表示
     - Parameters:
      - okAction: okタップ時の処理
     */
    func showDeleteEffectivenessAlert(_ okAction: @escaping () -> ()) {
        showDeleteAlert(title: "有効性コメントを削除", message: "コメントを削除します。よろしいですか？", okAction: okAction)
    }
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is TaskDetailViewController {
            updateTaskData()
        }
    }
    
    /**
     対策データを更新
     */
    func updateTaskData() {
        // 同じ対策名の登録がないか確認
        for num in 0...task.getMeasuresTitleArray().count - 1 {
            if num == indexPath.row {
                // 判定しない
            } else {
                // 対策名被りのチェック
                if measuresTitleTextField.text == task.getMeasuresTitleArray()[num] {
                    SVProgressHUD.showError(withStatus: "同じ対策名が存在します。\n別の名前にしてください。")
                    return
                }
            }
        }
        task.updateMeasuresTitle(newTitle: measuresTitleTextField.text!, at: indexPath.row)
        if self.checkButton.isSelected {
            task.setMeasuresPriority(measuresTitleTextField.text!)
        }
        
        // データを更新
        let dataManager = DataManager()
        dataManager.updateTaskData(self.task, {})
    }
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPracticeNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! PracticeNoteDetailViewController
            noteDetailViewController.noteData = self.noteData
        }
    }

}
