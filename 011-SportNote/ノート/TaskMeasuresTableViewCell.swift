//
//  TaskMeasuresTableViewCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/09.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TaskMeasuresTableViewCell: UITableViewCell {

    //MARK:- UIの設定
    
    // ラベル
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskMeasuresTitleLabel: UILabel!
    
    // テキストビュー
    @IBOutlet weak var effectivenessTextView: UITextView!
    
    // チェックボックス
    @IBOutlet weak var checkBox: UIButton!
    private let checkedImage = UIImage(named: "check_on")
    private let uncheckedImage = UIImage(named: "check_off")
    
    @IBAction func chexBox(_ sender: Any) {
        // 選択状態を反転させる
        self.checkBox.isSelected = !self.checkBox.isSelected
    }

    
    
    //MARK:- その他のメソッド
    
    // 課題データをラベルに表示するメソッド
    func printTaskData(noteData note:NoteData,at index:Int) {
        // ラベルに表示
        taskTitleLabel.text = note.getTaskTitle()[index]
        taskMeasuresTitleLabel.text = "対策:\(note.getMeasuresTitle()[index])"
        effectivenessTextView.text  = note.getMeasuresEffectiveness()[index]
    }
    
    // テキストフィールドの枠線追加
    func addTextViewBorder() {
        effectivenessTextView.layer.borderColor = UIColor.systemGray.cgColor
        effectivenessTextView.layer.borderWidth = 1.0
    }
    
    // チェックボックスの設定
    func initCheckBox() {
        self.checkBox.setImage(uncheckedImage, for: .normal)
        self.checkBox.setImage(checkedImage, for: .selected)
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
        effectivenessTextView.inputAccessoryView = toolBar
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.endEditing(true)
    }
    
    
}
