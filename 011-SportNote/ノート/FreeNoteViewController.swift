//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase

class FreeNoteViewController: UIViewController,UINavigationControllerDelegate {

    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        navigationController?.delegate = self
        
        // 受け取ったフリーノートデータの文字列を表示
        printTitle()
        printDetail()
        
        // テキストビューの枠線付け
        detailTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailTextView.layer.borderWidth = 1.0
        
        // ツールバーを作成
        createToolBar()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // フリーノートデータ格納用
    var freeNoteData = FreeNote()
    
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is NoteViewController {
            // フリーノートデータを更新
            updateFreeNoteData(noteData: self.freeNoteData)
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 文字列表示メソッド
    func printTitle() {
        titleTextField.text = freeNoteData.getTitle()
    }
    
    func printDetail() {
        detailTextView.text = freeNoteData.getDetail()
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
        titleTextField.inputAccessoryView = toolBar
        detailTextView.inputAccessoryView = toolBar
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
    
    // Firebaseのデータを更新するメソッド
    func updateFreeNoteData(noteData freeNoteData:FreeNote) {
        // テキストデータをセット
        freeNoteData.setTitle(titleTextField.text!)
        freeNoteData.setDetail(detailTextView.text!)
        
        // 更新日時を現在時刻にする
        freeNoteData.setUpdated_at(getCurrentTime())
        
        // 更新したいデータを取得
        let db = Firestore.firestore()
        let data = db.collection("FreeNoteData").document("\(Auth.auth().currentUser!.uid)")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "title"      : freeNoteData.getTitle(),
            "detail"     : freeNoteData.getDetail(),
            "updated_at" : freeNoteData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }

}
