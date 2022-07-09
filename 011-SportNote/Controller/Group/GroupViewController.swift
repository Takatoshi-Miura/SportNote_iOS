//
//  GroupViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/10.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

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
    var group = Group()
    private var groupArray: [Group] = []
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    var delegate: GroupViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initColorPicker()
        let realmManager = RealmManager()
        groupArray = realmManager.getGroupArrayForTaskView()
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
            let firebaseManager = FirebaseManager()
            firebaseManager.updateGroup(group: group)
        }
    }
    
    /// 画面初期化
    private func initView() {
        self.title = TITLE_GROUP_DETAIL
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteGroup))
        navigationItem.rightBarButtonItems = [deleteButton]
        titleLabel.text = TITLE_TITLE
        colorLabel.text = TITLE_COLOR
        orderLabel.text = TITLE_ORDER
        initTextField(textField: titleTextField, placeholder: MESSAGE_GROUP_EXAMPLE, text: group.title)
        colorButton.backgroundColor = Color.allCases[group.color].color
        colorButton.setTitle(Color.allCases[group.color].title, for: .normal)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isEditing = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
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
    
    /// グループを削除
    @objc func deleteGroup() {
        /// グループ数チェック
        let realmManager = RealmManager()
        if realmManager.getGroupArrayForTaskView().count == 1 {
            showErrorAlert(message: MESSAGE_EMPTY_GROUP)
            return
        }
        
        showDeleteAlert(title: TITLE_DELETE_GROUP, message: MESSAGE_DELETE_GROUP, OKAction: {
            realmManager.updateGroupIsDeleted(group: self.group)
            self.delegate?.groupVCDeleteGroup()
        })
    }
    
}

extension GroupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == group.title {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showOKAlert(title: TITLE_ERROR, message: ERROR_MESSAGE_EMPTY_TITLE, OKAction: {
                self.titleTextField.text = self.group.title
                self.titleTextField.becomeFirstResponder()
            })
            return false
        }
        
        // グループを更新
        let realmManager = RealmManager()
        realmManager.updateGroupTitle(groupID: group.groupID, title: textField.text!)
        groupArray = realmManager.getGroupArrayForTaskView()
        tableView.reloadData()
        return true
    }
    
}

extension GroupViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        
        let realmManager = RealmManager()
        realmManager.updateGroupColor(groupID: group.groupID, color: pickerIndex)
        groupArray = realmManager.getGroupArrayForTaskView()
        tableView.reloadData()
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}

extension GroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if groupArray.isEmpty {
            return 0
        } else {
            return groupArray.count
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
        let group = groupArray[sourceIndexPath.row]
        groupArray.remove(at: sourceIndexPath.row)
        groupArray.insert(group, at: destinationIndexPath.row)
        
        let realmManager = RealmManager()
        realmManager.updateGroupOrder(groupArray: groupArray)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = groupArray[indexPath.row].title
        cell.backgroundColor = UIColor.systemGray6
        return cell
    }
    
}
