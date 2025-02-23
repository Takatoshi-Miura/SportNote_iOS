//
//  AddGroupViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/05.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddGroupViewControllerDelegate: AnyObject {
    // キャンセル時の処理
    func addGroupVCCancel(_ viewController: UIViewController)
    // グループ追加時の処理
    func addGroupVCAddGroup(_ viewController: UIViewController, group: Group)
}

class AddGroupViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private let viewModel: AddGroupViewModel
    private let disposeBag = DisposeBag()
    var delegate: AddGroupViewControllerDelegate?
    
    // MARK: - Initializer
    
    init () {
        self.viewModel = AddGroupViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initColorPicker()
        initBind()
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindCancelButton()
        bindSaveButton()
        bindColorButton()
        bindPicker()
    }
    
    /// キャンセルボタンのバインド
    private func bindCancelButton() {
        cancelButton.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                if titleTextField.text!.isEmpty {
                    self.delegate?.addGroupVCCancel(self)
                } else {
                    showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                        self.delegate?.addGroupVCCancel(self)
                    })
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 保存ボタンのバインド
    private func bindSaveButton() {
        saveButton.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                // 入力チェック
                if titleTextField.text!.isEmpty {
                    showOKAlert(title: TITLE_ERROR, message: ERROR_MESSAGE_EMPTY_TITLE, OKAction: {
                        self.titleTextField.becomeFirstResponder()
                    })
                    return
                }
                
                // グループ作成
                let group = viewModel.insertGroup(title: titleTextField.text!)
                guard let group else {
                    showErrorAlert(message: ERROR_MESSAGE_GROUP_CREATE_FAILED)
                    return
                }
                
                // Firebaseに送信
                if Network.isOnline() {
                    let firebaseManager = FirebaseManager()
                    firebaseManager.saveGroup(group: group, completion: {
                        self.delegate?.addGroupVCAddGroup(self, group: group)
                    })
                } else {
                    self.delegate?.addGroupVCAddGroup(self, group: group)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// カラーボタンのバインド
    private func bindColorButton() {
        colorButton.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                titleTextField.resignFirstResponder()
                closePicker(pickerView)
                initPickerView()
                openPicker(pickerView)
            })
            .disposed(by: disposeBag)
        
        viewModel.buttonTitle
            .bind(to: colorButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel.buttonBackgroundColor
            .bind(to: colorButton.rx.backgroundColor)
            .disposed(by: disposeBag)
    }
    
    /// Picker項目のバインド
    private func bindPicker() {
        Observable.just(Color.allCases).bind(to: colorPicker.rx.itemAttributedTitles) { (row, element) in
            return getColorPickerItems(color: element.color, title: element.title)
        }
        .disposed(by: disposeBag)
    }
    
    /// Pickerツールバーのバインド
    /// - Parameters:
    ///   - doneItem: 完了ボタン
    ///   - cancelItem: キャンセルボタン
    private func bindPickerToolBar(doneItem: UIBarButtonItem, cancelItem: UIBarButtonItem) {
        doneItem.rx.tap.asDriver()
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                // 選択したIndexを反映
                viewModel.colorIndex.accept(colorPicker.selectedRow(inComponent: 0))
                closePicker(pickerView)
            })
            .disposed(by: disposeBag)
        
        cancelItem.rx.tap.asDriver()
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                // Indexを元に戻して閉じる
                colorPicker.selectRow(viewModel.colorIndex.value, inComponent: 0, animated: false)
                closePicker(pickerView)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面表示の初期化
    private func initView() {
        naviItem.title = TITLE_ADD_GROUP
        titleLabel.text = TITLE_TITLE
        colorLabel.text = TITLE_COLOR
        initTextField(textField: titleTextField, placeholder: MESSAGE_GROUP_EXAMPLE)
    }
    
    /// ColorPicker初期化
    private func initColorPicker() {
        colorPicker.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: colorPicker.bounds.size.height)
        colorPicker.backgroundColor = UIColor.systemGray5
    }
    
    /// PickerVIewの初期化
    private func initPickerView() {
        let toolBarHeight: CGFloat = 44
        let safeAreaBottom: CGFloat = view.safeAreaInsets.bottom
        pickerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: colorPicker.bounds.size.height + toolBarHeight + safeAreaBottom))
        pickerView.backgroundColor = UIColor.systemGray5
        pickerView.addSubview(colorPicker)
        pickerView.addSubview(createPickerToolBar())
    }
    
    /// Picker用ツールバーを作成
    private func createPickerToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil)
        let cancelItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        bindPickerToolBar(doneItem: doneItem, cancelItem: cancelItem)
        toolbar.setItems([cancelItem, flexibleItem, doneItem], animated: true)
        return toolbar
    }

}
