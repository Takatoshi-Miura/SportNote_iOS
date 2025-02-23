//
//  GroupViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/10.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol GroupViewControllerDelegate: AnyObject {
    // グループ削除時の処理
    func groupVCDeleteGroup()
}

class GroupViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private let viewModel: GroupViewModel
    private let disposeBag = DisposeBag()
    var delegate: GroupViewControllerDelegate?
    
    // MARK: - Initializer
    
    init(group: Group) {
        self.viewModel = GroupViewModel(group: group)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTextField(textField: titleTextField, placeholder: MESSAGE_GROUP_EXAMPLE, text: viewModel.group.value.title)
        initColorPicker()
        initTableView()
        initBind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            viewModel.updateFirebaseGroup()
        }
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitleTextField()
        bindColorButton()
        bindPicker()
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
    
    /// カラーボタンのバインド
    private func bindColorButton() {
        colorButton.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                titleTextField.resignFirstResponder()
                closePicker(pickerView)
                initPickerView()
                openPicker(pickerView, isModal: false)
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
    
    /// 削除ボタンのバインド
    /// - Parameter deleteButton: 削除ボタン
    private func bindDeleteButton(deleteButton: UIBarButtonItem) {
        deleteButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                // グループ数がゼロになる場合は削除不可
                let realmManager = RealmManager()
                if realmManager.getGroupArrayForTaskView().count == 1 {
                    showErrorAlert(message: MESSAGE_EMPTY_GROUP)
                    return
                }
                // グループ削除
                showDeleteAlert(title: TITLE_DELETE_GROUP, message: MESSAGE_DELETE_GROUP, OKAction: {
                    self.viewModel.deleteGroup()
                    self.delegate?.groupVCDeleteGroup()
                })
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_GROUP_DETAIL
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        deleteButton.tintColor = UIColor.red
        bindDeleteButton(deleteButton: deleteButton)
        navigationItem.rightBarButtonItems = [deleteButton]
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

extension GroupViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// TableView初期化
    private func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isEditing = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.groupArray.value.isEmpty {
            return 0
        } else {
            return viewModel.groupArray.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true     // 表示順のみ並び替え許可
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveGroup(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.groupArray.value[indexPath.row].title
        cell.backgroundColor = UIColor.systemGray6
        return cell
    }
    
}
