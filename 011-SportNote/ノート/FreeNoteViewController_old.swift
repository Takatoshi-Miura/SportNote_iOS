//
//  FreeNoteViewController_old.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase

class FreeNoteViewController_old: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UITextViewDelegate {

    //MARK:- ライフサイクルメソッド

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // デリゲートの設定
        titleTextField.delegate = self
        detailTextView.delegate = self
        navigationController?.delegate = self
        
        // 受け取ったフリーノートデータの文字列を表示
        titleTextField.text = dataManager.freeNoteData.getTitle()
        detailTextView.text = dataManager.freeNoteData.getDetail()
        
        // テキストビューの枠線付け
        detailTextView.layer.borderColor = UIColor.systemGray.cgColor
        detailTextView.layer.borderWidth = 1.0
        
        // キーボードでテキストフィールドが隠れない設定
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // ツールバーを作成
        titleTextField.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
        detailTextView.inputAccessoryView = createToolBar(#selector(tapOkButton(_:)), #selector(tapOkButton(_:)))
    }
    
    
    
    //MARK:- 変数の宣言
    
    // フリーノートデータ格納用
    var dataManager = DataManager()
    
    
    //MARK:- UIの設定
    
    // テキスト
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    
    
    //MARK:- 画面遷移
    
    // 前画面に戻るときに呼ばれる処理
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let controller = viewController as? NoteViewController_old {
            // フリーノートデータを更新・受け渡し＆フリーノートセル再描画
            dataManager.updateFreeNoteData(titleTextField.text!, detailTextView.text!, {
                controller.dataManager.freeNoteData = self.dataManager.freeNoteData
                let row = IndexPath(row: 0, section: 0)
                controller.tableView.reloadRows(at: [row], with: UITableView.RowAnimation.fade)
            })
        }
    }
    
    
    //MARK:- キーボード
    
    // キーボードを出したときの設定
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            detailTextView.contentInset = .zero
        } else {
            detailTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        detailTextView.scrollIndicatorInsets = detailTextView.contentInset

        let selectedRange = detailTextView.selectedRange
        detailTextView.scrollRangeToVisible(selectedRange)
    }
    
    // OKボタンの処理
    @objc func tapOkButton(_ sender: UIButton){
        // キーボードを閉じる
        self.view.endEditing(true)
    }

}
