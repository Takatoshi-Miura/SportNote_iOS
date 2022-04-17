//
//  AddTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/15.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddTaskViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addTaskVCDismiss(_ viewController: UIViewController)
}

class AddTaskViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var measuresTextField: UITextField!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    private var realmGroupArray: [Group] = []
    private var pickerView = UIView()
    private let colorPicker = UIPickerView()
    private var pickerIndex: Int = 0
    var delegate: AddTaskViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmManager = RealmManager()
        realmGroupArray = realmManager.getGroupArrayForTaskView()
        initView()
        initColorPicker()
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // マルチタスクビュー対策
        colorPicker.frame.size.width = self.view.bounds.size.width
    }
    
    /// 画面の初期化
    private func initView() {
        naviItem.title = TITLE_ADD_TASK
        titleLabel.text = TITLE_TITLE
        causeLabel.text = TITLE_CAUSE
        measuresLabel.text = TITLE_MEASURES
        colorLabel.text = TITLE_GROUP
        titleTextField.text = ""
        titleTextField.placeholder = MASSAGE_TASK_EXAMPLE
        causeTextView.text = ""
        causeTextView.layer.borderColor = UIColor.systemGray6.cgColor
        causeTextView.layer.borderWidth = 1.0
        causeTextView.layer.cornerRadius = 5.0
        causeTextView.layer.masksToBounds = true
        measuresTextField.text = ""
        measuresTextField.placeholder = MASSAGE_MEASURES_EXAMPLE
        colorButton.backgroundColor = Color.allCases[realmGroupArray.first!.color].color
        colorButton.setTitle(realmGroupArray.first!.title, for: .normal)
        saveButton.setTitle(TITLE_SAVE, for: .normal)
        cancelButton.setTitle(TITLE_CANCEL, for: .normal)
    }
    
    /// カラーボタンの処理
    @IBAction func tapAddColorButton(_ sender: Any) {
        titleTextField.resignFirstResponder()
        closePicker(pickerView)
        pickerView = UIView(frame: colorPicker.bounds)
        pickerView.addSubview(colorPicker)
        pickerView.addSubview(createToolBar(#selector(doneAction), #selector(cancelAction)))
        openPicker(pickerView)
    }
    
    /// 保存ボタンの処理
    @IBAction func tapSaveButton(_ sender: Any) {
        // 入力チェック
        if titleTextField.text!.isEmpty {
            showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
            return
        }
        
        // 課題データを作成＆保存
        let realmManager = RealmManager()
        let task = Task()
        task.groupID = realmGroupArray[pickerIndex].groupID
        task.title = titleTextField.text!
        task.cause = causeTextView.text!
        task.order = realmManager.getTasksInGroup(ID: task.groupID, isCompleted: false).count
        if !realmManager.createRealm(object: task) {
            showErrorAlert(message: ERROR_MESSAGE_TASK_CREATE_FAILED)
            return
        }
        
        // 対策データを作成＆保存
        let measures = Measures()
        if !measuresTextField.text!.isEmpty {
            measures.taskID = task.taskID
            measures.title = measuresTextField.text!
            if !realmManager.createRealm(object: measures) {
                showErrorAlert(message: ERROR_MESSAGE_TASK_CREATE_FAILED)
                return
            }
        }
        
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveTask(task: task, completion: {})
            if !measuresTextField.text!.isEmpty {
                firebaseManager.saveMeasures(measures: measures, completion: {})
            }
        }
        self.dismissWithInsertTask(task: task)
    }
    
    /// 課題画面に課題を追加してモーダルを閉じる
    private func dismissWithInsertTask(task: Task) {
        let tabBar = self.presentingViewController as! UITabBarController
        let navigation = tabBar.selectedViewController as! UINavigationController
        let taskView = navigation.viewControllers.first as! TaskViewController
        taskView.insertTask(task: task)
        self.delegate?.addTaskVCDismiss(self)
    }
    
    /// キャンセルボタンの処理
    @IBAction func tapCancelButton(_ sender: Any) {
        dismissWithInputCheck()
    }
    
    /// 入力済みの場合、確認アラートを表示
    private func dismissWithInputCheck() {
        if !titleTextField.text!.isEmpty ||
           !causeTextView.text.isEmpty ||
           !measuresTextField.text!.isEmpty
        {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addTaskVCDismiss(self)
            })
            return
        }
        self.delegate?.addTaskVCDismiss(self)
    }
    
}

extension AddTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1    // 列数
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return realmGroupArray.count  // グループ数
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return realmGroupArray[row].title   // グループ名
    }
    
    /// Picker初期化
    private func initColorPicker() {
        colorPicker.delegate = self
        colorPicker.dataSource = self
        colorPicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: colorPicker.bounds.size.height + 44)
        colorPicker.backgroundColor = UIColor.systemGray5
    }
    
    @objc func doneAction() {
        // 選択したIndexを取得して閉じる
        pickerIndex = colorPicker.selectedRow(inComponent: 0)
        closePicker(pickerView)
        colorButton.backgroundColor = Color.allCases[realmGroupArray[pickerIndex].color].color
        colorButton.setTitle(realmGroupArray[pickerIndex].title, for: .normal)
    }
    
    @objc func cancelAction() {
        // Indexを元に戻して閉じる
        colorPicker.selectRow(pickerIndex, inComponent: 0, animated: false)
        closePicker(pickerView)
    }
    
}

extension AddTaskViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension AddTaskViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
    }
    
}
