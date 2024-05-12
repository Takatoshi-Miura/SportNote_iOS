//
//  AddTargetViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/17.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddTargetViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addTargetVCDismiss(_ viewController: UIViewController)
    // モーダルを閉じる時の処理(親ビューリロード付き)
    func addTargetVCDismissWithReload(_ viewController: UIViewController)
}

class AddTargetViewController: UIViewController {

    // MARK: - UI,Variable
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var yearlyTargetSwitch: UISwitch!
    @IBOutlet weak var pickerView: UIPickerView!
    private let years  = Year.years.map { $0 }
    private let months = Month.allCases.map { $0 }
    private var viewModel: AddTargetViewModel
    private let disposeBag = DisposeBag()
    var delegate: AddTargetViewControllerDelegate?
    
    // MARK: - Initializer
    
    init() {
        self.viewModel = AddTargetViewModel()
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
        titleTextField.becomeFirstResponder()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindCancelButton()
        bindSaveButton()
        bindYearlyTargetSwitch()
    }
    
    /// キャンセルボタンのバインド
    private func bindCancelButton() {
        cancelButton.rx.tap
            .subscribe(onNext: {[unowned self] _ in
                if !titleTextField.text!.isEmpty {
                    showOKCancelAlert(title: "", message: MESSAGE_DELETE_INPUT, OKAction: {
                        self.delegate?.addTargetVCDismiss(self)
                    })
                    return
                }
                delegate?.addTargetVCDismiss(self)
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
                
                // 目標作成
                var target = Target()
                if yearlyTargetSwitch.isOn {
                    target = viewModel.createTarget(title: titleTextField.text!,
                                                    year: years[pickerView.selectedRow(inComponent: 0)],
                                                    month: 0,
                                                    isYearly: true)
                } else {
                    target = viewModel.createTarget(title: titleTextField.text!,
                                                        year: years[pickerView.selectedRow(inComponent: 0)],
                                                        month: months[pickerView.selectedRow(inComponent: 1)].rawValue,
                                                        isYearly: false)
                }
                
                // 目標の重複チェック
                if let targetID = viewModel.doubleCheck(target: target) {
                    showOKCancelAlert(title: "", message: ERROR_MESSAGE_TARGET_EXIST, OKAction: {
                        self.viewModel.deleteTarget(targetID: targetID)
                        if !self.viewModel.insertTarget(target: target) {
                            self.showErrorAlert(message: ERROR_MESSAGE_TARGET_CREATE_FAILED)
                            return
                        }
                        self.viewModel.insertFirebase(target: target, completion: {
                            self.delegate?.addTargetVCDismissWithReload(self)
                        })
                    })
                    return
                }
                
                // 保存
                if !viewModel.insertTarget(target: target) {
                    showErrorAlert(message: ERROR_MESSAGE_TARGET_CREATE_FAILED)
                    return
                }
                viewModel.insertFirebase(target: target, completion: {
                    self.delegate?.addTargetVCDismissWithReload(self)
                })
            })
            .disposed(by: disposeBag)
    }
    
    /// 年間目標スイッチのバインド
    private func bindYearlyTargetSwitch() {
        yearlyTargetSwitch.rx.controlEvent(.valueChanged)
            .withLatestFrom(yearlyTargetSwitch.rx.value)
            .subscribe(onNext: {[unowned self] _ in
                pickerView.reloadAllComponents()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_ADD_TARGET
        titleLabel.text = TITLE_TITLE
        targetLabel.text = TITLE_YEARLY_TARGET
        initTextField(textField: titleTextField, placeholder: MESSAGE_TARGET_EXAMPLE)
        initPickerView()
    }
    
}

extension AddTargetViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    /// PickerView初期化
    private func initPickerView() {
        pickerView.backgroundColor = UIColor.systemGray6
        pickerView.selectRow(Year.getCurrentYearIndex(), inComponent: 0, animated: false)
        pickerView.selectRow(Month.getCurrentMonthIndex(), inComponent: 1, animated: false)
    }
    
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
