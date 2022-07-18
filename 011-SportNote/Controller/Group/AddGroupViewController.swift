//
//  AddGroupViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/05.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddGroupViewControllerDelegate: AnyObject {
    // キャンセル時の処理
    func addGroupVCCancel(_ viewController: UIViewController)
    // グループ追加時の処理
    func addGroupVCAddGroup(_ viewController: UIViewController, group: Group)
}

class AddGroupViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    var delegate: AddGroupViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initColorPicker()
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    /// 画面表示の初期化
    private func initView() {
        naviItem.title = TITLE_ADD_GROUP
        titleLabel.text = TITLE_TITLE
        colorLabel.text = TITLE_COLOR
        initTextField(textField: titleTextField, placeholder: MESSAGE_GROUP_EXAMPLE)
        colorButton.backgroundColor = Color.allCases[pickerIndex].color
        colorButton.setTitle(Color.allCases[pickerIndex].title, for: .normal)
    }
    
    /// Picker初期化
    private func initColorPicker() {
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: colorPicker.bounds.size.height + 44)
        colorPicker.backgroundColor = UIColor.systemGray5
    }
    
    // MARK: - Action
    
    /// カラーボタンの処理
    @IBAction func tapColorButton(_ sender: Any) {
        titleTextField.resignFirstResponder()
        closePicker(pickerView)
        pickerView = UIView(frame: colorPicker.bounds)
        pickerView.addSubview(colorPicker)
        pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
        openPicker(pickerView)
    }
    
    /// キャンセルボタンの処理
    @IBAction func tapCancelButton(_ sender: Any) {
        if titleTextField.text!.isEmpty {
            self.delegate?.addGroupVCCancel(self)
        } else {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addGroupVCCancel(self)
            })
        }
    }
    
    /// 保存ボタンの処理
    @IBAction func tapSaveButton(_ sender: Any) {
        // 入力チェック
        if titleTextField.text!.isEmpty {
            showOKAlert(title: TITLE_ERROR, message: ERROR_MESSAGE_EMPTY_TITLE, OKAction: {
                self.titleTextField.becomeFirstResponder()
            })
            return
        }
        
        // グループ作成
        let realmManager = RealmManager()
        let group = Group()
        group.title = titleTextField.text!
        group.color = pickerIndex
        group.order = realmManager.getNumberOfGroups()
        if !realmManager.createRealm(object: group) {
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
    }

}

extension AddGroupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Color.allCases.count  // カラーの項目数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Color.allCases[row].title   // 文字列
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
        pickerIndex = colorPicker.selectedRow(inComponent: 0)
        closePicker(pickerView)
        colorButton.backgroundColor = Color.allCases[pickerIndex].color
        colorButton.setTitle(Color.allCases[pickerIndex].title, for: .normal)
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}
