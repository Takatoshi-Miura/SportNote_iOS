//
//  MeasuresViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/16.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

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
    private var memoArray = [Memo]()
    var measures = Measures()
    var delegate: MeasuresViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let realmManager = RealmManager()
        memoArray = realmManager.getMemo(measuresID: measures.measuresID)
        initNavigationBar()
        initTableView()
        initView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // メモが削除されていれば取り除く
            let memo = memoArray[selectedIndex.row]
            if memo.isDeleted {
                memoArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Firebaseに送信
        if Network.isOnline() {
            let firebaseManager = FirebaseManager()
            firebaseManager.updateMeasures(measures: measures)
        }
    }
    
    private func initNavigationBar() {
        self.title = TITLE_MEASURES_DETAIL
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteMeasures))
        navigationItem.rightBarButtonItems = [deleteButton]
    }
    
    private func initTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func initView() {
        titleLabel.text = TITLE_TITLE
        memoLabel.text = TITLE_NOTE
        initTextField(textField: titleTextField, placeholder: MASSAGE_MEASURES_EXAMPLE, text: measures.title)
    }
    
    /// 対策とそれに含まれるメモを削除
    @objc func deleteMeasures() {
        showDeleteAlert(title: TITLE_DELETE_MEASURES, message: MESSAGE_DELETE_MEASURES, OKAction: {
            let realmManager = RealmManager()
            realmManager.updateMeasuresIsDeleted(measures: self.measures)
            for memo in self.memoArray {
                realmManager.updateMemoIsDeleted(memoID: memo.memoID)
            }
            if Network.isOnline() {
                let firebaseManager = FirebaseManager()
                firebaseManager.updateMeasures(measures: self.measures)
                for memo in self.memoArray {
                    firebaseManager.updateMemo(memo: memo)
                }
            }
            self.delegate?.measuresVCDeleteMeasures()
        })
    }
    
}

extension MeasuresViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoArray.isEmpty {
            return 0
        }
        return memoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let memo = memoArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = memo.detail
        cell.backgroundColor = UIColor.systemGray6
        cell.textLabel?.numberOfLines = 0 // 全文表示
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !memoArray.isEmpty {
            delegate?.measuresVCMemoDidTap(memo: memoArray[indexPath.row])
        }
    }
    
}

extension MeasuresViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // 差分がなければ何もしない
        if textField.text! == measures.title {
            return true
        }
        
        // 入力チェック
        if textField.text!.isEmpty {
            showErrorAlert(message: ERROR_MESSAGE_EMPTY_TITLE)
            textField.text = measures.title
            return false
        }
        
        // 対策を更新
        let realmManager = RealmManager()
        realmManager.updateMeasuresTitle(measuresID: measures.measuresID, title: textField.text!)
        return true
    }
}
