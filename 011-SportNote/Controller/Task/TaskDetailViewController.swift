//
//  TaskDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/13.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol TaskDetailViewControllerDelegate: AnyObject {
    // 課題の完了(未完了)時の処理
    func taskDetailVCCompleteTask(task: Task)
    // 課題削除時の処理
    func taskDetailVCDeleteTask(task: Task)
    // 対策セルタップ時の処理
    func taskDetailVCMeasuresCellDidTap(measures: Measures)
}

class TaskDetailViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var causeLabel: UILabel!
    @IBOutlet weak var measuresLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var causeTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    private let viewModel: TaskDetailViewModel
    private let disposeBag = DisposeBag()
    var delegate: TaskDetailViewControllerDelegate?
    
    // MARK: - Initializer
    
    init(task: Task) {
        self.viewModel = TaskDetailViewModel(task: task)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initTableView()
        initView()
        initBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleSelectedCell()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            viewModel.updateFirebaseMeasures()
        }
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindTitleTextField()
        bindCauseTextView()
        bindAddButton()
    }
    
    /// タイトル入力欄のバインド
    private func bindTitleTextField() {
        titleTextField.rx.controlEvent(.editingDidEnd).asDriver()
            .drive(onNext: { [unowned self] _ in
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
    
    /// 原因入力欄のバインド
    private func bindCauseTextView() {
        causeTextView.rx.didEndEditing.asDriver()
            .drive(onNext: { [unowned self] _ in
                causeTextView.resignFirstResponder()
                viewModel.cause.accept(causeTextView.text)
            })
            .disposed(by: disposeBag)
    }
    
    /// 削除ボタンのバインド
    /// - Parameter deleteButton: 削除ボタン
    private func bindDeleteButton(deleteButton: UIBarButtonItem) {
        deleteButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                showDeleteAlert(title: TITLE_DELETE_TASK, message: MESSAGE_DELETE_TASK, OKAction: {
                    self.viewModel.deleteTask()
                    self.delegate?.taskDetailVCDeleteTask(task: self.viewModel.task)
                })
            })
            .disposed(by: disposeBag)
    }
    
    /// 課題完了ボタンのバインド
    /// - Parameter completeButton: 完了ボタン
    private func bindCompleteButton(completeButton: UIBarButtonItem) {
        completeButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let isCompleted = viewModel.task.isComplete
                let message = isCompleted ? MESSAGE_INCOMPLETE_TASK : MESSAGE_COMPLETE_TASK
                showOKCancelAlert(title: TITLE_COMPLETE_TASK, message: message, OKAction: {
                    self.viewModel.completeTask(isCompleted: !isCompleted)
                    self.delegate?.taskDetailVCCompleteTask(task: self.viewModel.task)
                })
            })
            .disposed(by: disposeBag)
    }
    
    /// 対策追加ボタンのバインド
    private func bindAddButton() {
        addButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let alert = UIAlertController(title: TITLE_ADD_MEASURES, message: MESSAGE_ADD_MEASURES, preferredStyle: .alert)
                
                var alertTextField: UITextField?
                alert.addTextField(configurationHandler: {(textField) -> Void in
                    alertTextField = textField
                })
                
                let OKAction = UIAlertAction(title: TITLE_ADD, style: UIAlertAction.Style.default, handler: {(action: UIAlertAction) in
                    if (alertTextField?.text == nil || alertTextField?.text == "") {
                        self.showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
                    } else {
                        // 対策データ作成
                        let result = self.viewModel.insertMeasures(title: alertTextField!.text!)
                        if (!result) {
                            self.showErrorAlert(message: ERROR_MESSAGE_TASK_CREATE_FAILED)
                            return
                        }
                        // tableView更新
                        let index: IndexPath = [0, self.viewModel.measuresArray.value.count - 1]
                        self.tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
                    }
                })
                
                let cancelAction = UIAlertAction(title: TITLE_CANCEL, style: UIAlertAction.Style.cancel, handler: nil)
                
                let actions = [OKAction, cancelAction]
                actions.forEach { alert.addAction($0) }
                present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_TASK_DETAIL
        var navigationItems: [UIBarButtonItem] = []
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        bindDeleteButton(deleteButton: deleteButton)
        let image = viewModel.task.isComplete ? UIImage(systemName: "exclamationmark.circle") : UIImage(systemName: "checkmark.circle")
        let completeButton = UIBarButtonItem(image: image, style: .done, target: self, action: nil)
        bindCompleteButton(completeButton: completeButton)
        navigationItems.append(deleteButton)
        navigationItems.append(completeButton)
        navigationItem.rightBarButtonItems = navigationItems
    }
    
    /// 画面表示の初期化
    private func initView() {
        titleLabel.text = TITLE_TITLE
        causeLabel.text = TITLE_CAUSE
        measuresLabel.text = TITLE_MEASURES_PRIORITY
        initTextField(textField: titleTextField, placeholder: MASSAGE_TASK_EXAMPLE, text: viewModel.task.title)
        initTextView(textView: causeTextView, text: viewModel.task.cause)
        addButton.isHidden = viewModel.task.isComplete ? true : false
    }
    
}

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// TableView初期化
    private func initTableView() {
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 選択されたセルの更新
    private func handleSelectedCell() {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 対策が削除されていれば取り除く
            if (viewModel.removeMeasures(index: selectedIndex.row)) {
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true     // 並び替え可能
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveMeasures(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.measuresArray.value.isEmpty {
            return 0
        } else {
            return viewModel.measuresArray.value.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = viewModel.measuresArray.value[indexPath.row].title
        cell.backgroundColor = UIColor.systemGray6
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 対策画面へ遷移
        let measures = viewModel.measuresArray.value[indexPath.row]
        delegate?.taskDetailVCMeasuresCellDidTap(measures: measures)
    }
    
}

