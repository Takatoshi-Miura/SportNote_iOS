//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class FreeNoteViewController: UIViewController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        navigationController?.delegate = self
        
        // 受け取ったフリーノートデータの文字列を表示
        printTitle()
        printDetail()
    }
    
    // テキスト
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    // フリーノートデータ格納用
    var freeNoteData = FreeNote()
    
    
    // 文字列表示メソッド
    func printTitle() {
        titleTextField.text = freeNoteData.getTitle()
    }
    
    func printDetail() {
        detailTextView.text = freeNoteData.getDetail()
    }
    
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController is NoteViewController {
            // フリーノートデータを更新
            freeNoteData.setTitle(titleTextField.text!)
            freeNoteData.setDetail(detailTextView.text!)
            freeNoteData.updateFreeNoteData()
        }
    }

}
