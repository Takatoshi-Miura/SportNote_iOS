//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/23.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class FreeNoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    var freeNote = Note()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // TODO: キーボードで入力欄が隠れない設定
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.updateNote(note: freeNote)
        }
    }
    
    /// 画面初期化
    private func initView() {
        titleLabel.text = TITLE_TITLE
        detailLabel.text = TITLE_DETAIL_LABEL
        titleTextField.text = freeNote.title
        titleTextField.inputAccessoryView = createToolBar(#selector(hideKeyboad(_:)))
        initTextView(textView: detailTextView)
        detailTextView.text = freeNote.detail
    }
    
    /// キーボードを隠す
    @objc func hideKeyboad(_ sender: UIButton){
        self.view.endEditing(true)
    }
    
}

extension FreeNoteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == freeNote.title {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
            textField.text = freeNote.title
            return false
        }
        
        let realmManager = RealmManager()
        realmManager.updateNoteTitle(noteID: freeNote.noteID, title: textField.text!)
        return true
    }
    
}

extension FreeNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 差分がなければ何もしない
        if textView.text! == freeNote.detail {
            return
        }
        
        let realmManager = RealmManager()
        realmManager.updateNoteDetail(noteID: freeNote.noteID, detail: textView.text!)
    }
    
}
