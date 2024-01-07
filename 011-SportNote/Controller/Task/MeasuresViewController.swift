//
//  MeasuresViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/16.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol MeasuresViewControllerDelegate: AnyObject {
    // 対策削除時の処理
    func measuresVCDeleteMeasures()
    // メモタップ時の処理
    func measuresVCMemoDidTap(memo: Memo)
}

class MeasuresViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: MeasuresViewModel
    private let disposeBag = DisposeBag()
    var delegate: MeasuresViewControllerDelegate?
    
    // MARK: - Initializer
    
    init(measures: Measures) {
        self.viewModel = MeasuresViewModel(measures: measures)
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
        bindTableView()
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
    
    /// TableViewのバインド
    private func bindTableView() {
        viewModel.memoArray.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, memo, cell in
                cell.textLabel?.text = memo.detail
                cell.backgroundColor = UIColor.systemGray6
                cell.textLabel?.numberOfLines = 0
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                if let memo = self.viewModel.getMemo(index: indexPath.row) {
                    self.delegate?.measuresVCMemoDidTap(memo: memo)
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 削除ボタンのバインド
    /// - Parameter deleteButton: 削除ボタン
    private func bindDeleteButton(deleteButton: UIBarButtonItem) {
        deleteButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                // 対策とそれに含まれるメモを削除
                showDeleteAlert(title: TITLE_DELETE_MEASURES, message: MESSAGE_DELETE_MEASURES, OKAction: {
                    self.viewModel.deleteMeasures()
                    if Network.isOnline() {
                        self.viewModel.updateFirebaseMeasures()
                    }
                    self.delegate?.measuresVCDeleteMeasures()
                })
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_MEASURES_DETAIL
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        bindDeleteButton(deleteButton: deleteButton)
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    /// TableView初期化
    private func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 選択されたセルの更新
    private func handleSelectedCell() {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // メモが削除されていれば取り除く
            if (viewModel.removeMemo(index: selectedIndex.row)) {
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    /// 画面表示の初期化
    private func initView() {
        titleLabel.text = TITLE_TITLE
        memoLabel.text = TITLE_NOTE
        initTextField(textField: titleTextField, placeholder: MASSAGE_MEASURES_EXAMPLE, text: viewModel.title.value)
    }
    
}
