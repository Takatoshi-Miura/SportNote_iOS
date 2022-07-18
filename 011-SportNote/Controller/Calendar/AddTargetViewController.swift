//
//  AddTargetViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddTargetViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addTargetVCDismiss(_ viewController: UIViewController)
    // モーダルを閉じる時の処理(親ビューリロード付き)
    func addTargetVCDismissWithReload(_ viewController: UIViewController)
}

class AddTargetViewController: UIViewController {

    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearlyTargetSwitch: UISwitch!
    @IBOutlet weak var pickerView: UIPickerView!
    private let years  = (1950...2200).map { $0 }
    private let months = Month.allCases.map { $0 }
    var delegate: AddTargetViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        titleTextField.becomeFirstResponder()
    }
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_ADD_TARGET
        titleLabel.text = TITLE_TITLE
        targetLabel.text = TITLE_YEARLY_TARGET
        initTextField(textField: titleTextField, placeholder: MESSAGE_TARGET_EXAMPLE)
        pickerView.backgroundColor = UIColor.systemGray6
        pickerView.selectRow(72, inComponent: 0, animated: false)
    }
    
    // MARK: - Action
    
    /// 年間目標スイッチの処理
    @IBAction func tapYearlyTargetSwitch(_ sender: Any) {
        pickerView.reloadAllComponents()
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
        
        // 目標作成
        let target = Target()
        target.title = titleTextField.text!
        target.year = years[pickerView.selectedRow(inComponent: 0)]
        if yearlyTargetSwitch.isOn {
            target.isYearlyTarget = true
        } else {
            target.month = months[pickerView.selectedRow(inComponent: 1)].rawValue
        }
        
        // 目標の重複チェック
        let realmManager = RealmManager()
        if target.isYearlyTarget {
            if let realmTarget = realmManager.getTarget(year: target.year) {
                showOKCancelAlert(title: "", message: ERROR_MESSAGE_TARGET_EXIST, OKAction: {
                    realmManager.updateTargetIsDeleted(targetID: realmTarget.targetID)
                    self.saveTarget(target: target)
                })
                return
            }
        } else {
            if let realmTarget = realmManager.getTarget(year: target.year, month: target.month, isYearlyTarget: target.isYearlyTarget) {
                showOKCancelAlert(title: "", message: ERROR_MESSAGE_TARGET_EXIST, OKAction: {
                    realmManager.updateTargetIsDeleted(targetID: realmTarget.targetID)
                    self.saveTarget(target: target)
                })
                return
            }
        }
        
        // 保存
        saveTarget(target: target)
    }
    
    /// 目標データ保存＆送信処理
    private func saveTarget(target: Target) {
        let realmManager = RealmManager()
        if !realmManager.createRealm(object: target) {
            showErrorAlert(message: ERROR_MESSAGE_TARGET_CREATE_FAILED)
            return
        }
        
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.saveTarget(target: target, completion: {
                self.delegate?.addTargetVCDismissWithReload(self)
            })
        } else {
            self.delegate?.addTargetVCDismissWithReload(self)
        }
    }
    
    /// キャンセルボタンの処理
    @IBAction func tapCancelButton(_ sender: Any) {
        if !titleTextField.text!.isEmpty {
            showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                self.delegate?.addTargetVCDismiss(self)
            })
            return
        }
        delegate?.addTargetVCDismiss(self)
    }
    
}

extension AddTargetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if yearlyTargetSwitch.isOn {
            return 1    // 年のみ
        } else {
            return 2    // 年、月
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if !yearlyTargetSwitch.isOn && component == 1 {
            return months.count
        } else {
            return years.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !yearlyTargetSwitch.isOn && component == 1 {
            return months[row].title
        } else {
            return String(years[row])
        }
    }
    
}

extension AddTargetViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
