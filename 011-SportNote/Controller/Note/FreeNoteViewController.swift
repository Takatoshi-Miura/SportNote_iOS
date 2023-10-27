//
//  FreeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/23.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FreeNoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    private let viewModel: FreeNoteViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(freeNote: Note) {
        self.viewModel = FreeNoteViewModel(freeNote: freeNote)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initBind()
        // TODO: キーボードで入力欄が隠れない設定
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            viewModel.updateFirebaseNote()
        }
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitleTextField()
        bindDetailTextView()
    }
    
    /// タイトル入力欄のバインド
    private func bindTitleTextField() {
        titleTextField.rx.controlEvent(.editingDidEnd).asDriver()
            .drive(onNext: {[unowned self] _ in
                titleTextField.resignFirstResponder()
                if titleTextField.text!.isEmpty {
                    showOKAlert(title: TITLE_ERROR, message: ERROR_MESSAGE_EMPTY_TITLE, OKAction: {
                        self.titleTextField.text = self.viewModel.title.value
                        self.titleTextField.becomeFirstResponder()
                    })
                    return
                }
                viewModel.title.accept(titleTextField.text!)
            })
            .disposed(by: disposeBag)
    }
    
    /// 詳細入力欄のバインド
    private func bindDetailTextView() {
        detailTextView.rx.didEndEditing.asDriver()
            .drive(onNext: { [unowned self] _ in
                detailTextView.resignFirstResponder()
                viewModel.detail.accept(detailTextView.text)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        titleLabel.text = TITLE_TITLE
        detailLabel.text = TITLE_DETAIL_LABEL
        initTextField(textField: titleTextField, placeholder: "", text: viewModel.freeNote.value.title)
        initTextView(textView: detailTextView, text: viewModel.freeNote.value.detail)
    }
    
}
