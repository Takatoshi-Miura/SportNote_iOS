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
    private var taskArray: [[FilteredTask]] = [[FilteredTask]]()
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
        taskArray = realmManager.getTaskArrayForNoteFilterView(isFilter: true)
        tableView.reloadData()
    }
    
    
    // MARK: - Action
    
    /// キャンセル
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.noteFilterVCCancelDidTap(self)
    }
    
    /// クリア
    @IBAction func tapClearButton(_ sender: Any) {
        let realmManager = RealmManager()
        taskArray = realmManager.getTaskArrayForNoteFilterView(isFilter: false)
        tableView.reloadData()
    }
    
    /// 適用
    @IBAction func tapApplyButton(_ sender: Any) {
        // isFilter = true のTaskIDを保存
        var filteredTaskArray = [String]()
        for tasks in taskArray {
            let searchFilteredTask = tasks.filter {
                $0.isFilter == true
            }
            for task in searchFilteredTask {
                filteredTaskArray.append(task.taskID)
            }
        }
        if filteredTaskArray.isEmpty {
            UserDefaultsKey.filterTaskID.remove()
        } else {
            UserDefaultsKey.filterTaskID.set(value: filteredTaskArray)
        }
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
        let task = taskArray[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = task.title
        if task.isFilter {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        taskArray[indexPath.section][indexPath.row].isFilter.toggle()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
}
