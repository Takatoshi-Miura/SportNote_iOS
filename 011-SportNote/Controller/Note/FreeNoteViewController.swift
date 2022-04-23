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
    var freeNote = FreeNote()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        // TODO: キーボードで入力欄が隠れない設定
    }
    
    /// 画面初期化
    private func initView() {
        titleLabel.text = TITLE_TITLE
        detailLabel.text = "詳細"
        titleTextField.text = freeNote.title
        detailTextView.text = freeNote.detail
        detailTextView.layer.borderColor = UIColor.systemGray5.cgColor
        detailTextView.layer.borderWidth = 1.0
        detailTextView.layer.cornerRadius = 5.0
        detailTextView.layer.masksToBounds = true
        detailTextView.inputAccessoryView = createToolBar(#selector(hideKeyboad(_:)), #selector(hideKeyboad(_:)))
    }
    
    /// キーボードを隠す
    @objc func hideKeyboad(_ sender: UIButton){
        self.view.endEditing(true)
    }
    
}
