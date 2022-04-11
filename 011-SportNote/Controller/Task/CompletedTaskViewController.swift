//
//  CompletedTaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/12.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol CompletedTaskViewControllerDelegate: AnyObject {
    // 課題セルタップ時の処理
    func completedTaskVCTaskCellDidTap(task: Task)
}

class CompletedTaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    private var taskArray: [Task] = [Task]()
    var groupID: String?
    var delegate: CompletedTaskViewControllerDelegate?

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        let realmManager = RealmManager()
        taskArray = realmManager.getTasksInGroup(ID: groupID!, isCompleted: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 課題が未完了or削除されていれば取り除く
            let task = taskArray[selectedIndex.row]
            if !task.isComplete || task.isDeleted {
                taskArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    func initNavigationController() {
        self.title = TITLE_COMPLETED_TASK
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

}

extension CompletedTaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if taskArray.isEmpty {
            return 0
        } else {
            return taskArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let realmManager = RealmManager()
        cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(realmManager.getMeasuresTitleInTask(taskID: task.taskID))"
        cell.detailTextLabel?.textColor = UIColor.lightGray
        cell.accessibilityIdentifier = "TaskViewCell"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.completedTaskVCTaskCellDidTap(task: taskArray[indexPath.row])
    }
}
