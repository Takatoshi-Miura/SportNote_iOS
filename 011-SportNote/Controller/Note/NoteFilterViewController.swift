//
//  NoteFilterViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/15.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol NoteFilterViewControllerDelegate: AnyObject {
    // キャンセルボタンタップ時の処理
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController)
    // 適用ボタンタップ時の処理
    func noteFilterVCApplyDidTap(_ viewController: NoteFilterViewController)
}

class NoteFilterViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    private var groupArray: [Group] = []
    private var taskArray: [[Task]] = [[Task]]()
    var delegate: NoteFilterViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initData()
    }
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_FILTER_NOTE
        clearButton.title = TITLE_CLEAR
        applyButton.setTitle(TITLE_APPLY, for: .normal)
    }
    
    private func initData() {
        let realmManager = RealmManager()
        groupArray = realmManager.getGroupArrayForTaskView()
        taskArray = realmManager.getTaskArrayForNoteFilterView()
    }
    
    
    // MARK: - Action
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.noteFilterVCCancelDidTap(self)
    }
    
    @IBAction func tapClearButton(_ sender: Any) {
    }
    
    @IBAction func tapApplyButton(_ sender: Any) {
        delegate?.noteFilterVCApplyDidTap(self)
    }
    
}

extension NoteFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groupArray[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        cell.textLabel?.text = taskArray[indexPath.section][indexPath.row].title
        cell.accessoryType = .checkmark
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskArray[indexPath.section][indexPath.row]
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == .checkmark {
            cell?.accessoryType = .none
        } else {
            cell?.accessoryType = .checkmark
        }
    }
    
}
