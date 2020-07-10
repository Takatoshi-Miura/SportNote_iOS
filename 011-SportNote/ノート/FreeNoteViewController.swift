//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

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
            freeNoteData.setTitle(titleTextField.text!)
            freeNoteData.setDetail(detailTextView.text!)
            freeNoteData.updateFreeNoteData()
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

}
