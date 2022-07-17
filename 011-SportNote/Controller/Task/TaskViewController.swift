//
//  TaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD

protocol TaskViewControllerDelegate: AnyObject {
    // グループ追加タップ時の処理
    func taskVCAddGroupDidTap(_ viewController: UIViewController)
    // 課題追加タップ時の処理
    func taskVCAddTaskDidTap(_ viewController: UIViewController)
    // セクションヘッダータップ時の処理
    func taskVCHeaderDidTap(group: Group)
    // 課題セルタップ時の処理
    func taskVCTaskCellDidTap(task: Task)
    // 完了した課題セルタップ時の処理
    func taskVCCompletedTaskCellDidTap(groupID: String)
    // 設定ボタンタップ時の処理
    func taskVCSettingDidTap(_ viewController: UIViewController)
    // チュートリアル表示
    func taskVCShowTutorial(_ viewController: UIViewController)
}

class TaskViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var groupArray: [Group] = []
    private var taskArray: [[Task]] = []
    private var adMobView: GADBannerView?
    var delegate: TaskViewControllerDelegate?
    
    var isCompleted = false
    var groupID = ""
    private var completedTaskArray: [Task] = []
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        initNotification()
        // 初回のみ旧データ変換後に同期処理
        if !isCompleted && Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let dataConverter = DataConverter()
            dataConverter.convertOldToRealm(completion: {
                self.syncData()
            })
        } else {
            self.syncData()
        }
        displayAgreement()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 課題が完了状態が更新or削除されていれば取り除く
            if isCompleted {
                let task = completedTaskArray[selectedIndex.row]
                if !task.isComplete || task.isDeleted {
                    completedTaskArray.remove(at: selectedIndex.row)
                    tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                    return
                }
            } else {
                if selectedIndex.row < taskArray[selectedIndex.section].count {
                    let task = taskArray[selectedIndex.section][selectedIndex.row]
                    if task.isComplete || task.isDeleted {
                        taskArray[selectedIndex.section].remove(at: selectedIndex.row)
                        tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                        return
                    }
                }
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        } else {
            // グループから戻る場合はリロード
            refreshData()
        }
    }
    
    /// 画面初期化
    private func initView() {
        if isCompleted {
            self.title = TITLE_COMPLETED_TASK
            addButton.isHidden = true
        } else {
            self.title = TITLE_TASK
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                style: .plain,
                                                target: self,
                                                action: #selector(openSettingView(_:)))
            navigationItem.leftBarButtonItems = [settingButton]
        }
    }
    
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UINib(nibName: String(describing: GroupHeaderView.self), bundle: nil),
                           forHeaderFooterViewReuseIdentifier: String(describing: GroupHeaderView.self))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 通知設定
    private func initNotification() {
        // ログイン、ログアウト時のリロード用
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncData),
                                               name: NSNotification.Name(rawValue: "afterLogin"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncDataWithConvert),
                                               name: NSNotification.Name(rawValue: "afterLogout"),
                                               object: nil)
    }
    
    /// データの同期処理
    @objc func syncData() {
        if !isCompleted && Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let syncManager = SyncManager()
            syncManager.syncDatabase(completion: {
                self.refreshData()
                HUD.hide()
            })
        } else {
            self.refreshData()
        }
    }
    
    /// データ変換＆同期処理
    /// ログアウト後は未分類グループなどを自動生成する必要がある
    @objc func syncDataWithConvert() {
        if !isCompleted && Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let dataConverter = DataConverter()
            dataConverter.convertOldToRealm(completion: {
                self.syncData()
            })
        } else {
            self.syncData()
        }
    }
    
    /// データを再取得
    private func refreshData() {
        let realmManager = RealmManager()
        if isCompleted {
            completedTaskArray = realmManager.getTasksInGroup(ID: groupID, isCompleted: isCompleted)
        } else {
            groupArray = realmManager.getGroupArrayForTaskView()
            taskArray = realmManager.getTaskArrayForTaskView()
        }
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
    }
    
    /// バナー広告を表示
    private func showAdMob() {
        if let adMobView = adMobView {
            adMobView.frame.size = CGSize(width: self.view.frame.width, height: adMobView.frame.height)
            return
        }
        adMobView = GADBannerView()
        adMobView = GADBannerView(adSize: GADAdSizeBanner)
        adMobView!.adUnitID = "ca-app-pub-9630417275930781/4051421921"
        adMobView!.rootViewController = self
        adMobView!.load(GADRequest())
        adMobView!.frame.origin = CGPoint(x: 0, y: 0)
        adMobView!.frame.size = CGSize(width: self.view.frame.width, height: adMobView!.frame.height)
        self.adView.addSubview(adMobView!)
    }
    
    /// 利用規約同意画面を表示
    private func displayAgreement() {
        // 初回起動判定
        if UserDefaultsKey.firstLaunch.bool() {
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            UserDefaultsKey.firstLaunch.set(value: false)
            
            // 利用規約を表示
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
                self.delegate?.taskVCShowTutorial(self)
            })
        }
        
        // 同意していないなら利用規約を表示
        if !UserDefaultsKey.agree.bool() {
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
            })
        }
    }
    
    // MARK: - Action
    
    /// 追加ボタンの処理
    @IBAction func tapAddButton(_ sender: Any) {
        var alertActions: [UIAlertAction] = []
        let addGroupAction = UIAlertAction(title: TITLE_GROUP, style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addTaskAction = UIAlertAction(title: TITLE_TASK, style: .default) { _ in
            self.delegate?.taskVCAddTaskDidTap(self)
        }
        alertActions.append(addGroupAction)
        alertActions.append(addTaskAction)
        
        showActionSheet(title: TITLE_ADD_GROUP_TASK,
                        message: MESSAGE_ADD_GROUP_TASK,
                        actions: alertActions,
                        frame: addButton.frame)
    }
    
    /// 設定タップ時の処理
    @objc func openSettingView(_ sender: UIBarButtonItem) {
        delegate?.taskVCSettingDidTap(self)
    }
    
    /// グループを挿入
    /// - Parameters:
    ///    - group: 挿入するグループ
    func insertGroup(group: Group) {
        let index: IndexPath = [group.order, 0]
        groupArray.append(group)
        taskArray.append([])
        tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
    }
    
    /// 課題を挿入(最後尾に追加)
    /// - Parameters:
    ///   - task: 挿入する課題
    func insertTask(task: Task) {
        var index: IndexPath = [0, 0]
        for group in groupArray {
            if task.groupID == group.groupID {
                // グループに含まれる課題数を並び順にセットする
                let realmManager = RealmManager()
                let tasks = realmManager.getTasksInGroup(ID: group.groupID, isCompleted: false)
                realmManager.updateTaskOrder(task: task, order: tasks.count - 1)
                // tableViewに課題を追加
                index = [index.section, tasks.count - 1]
                taskArray[index.section].append(task)
                tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
            }
            index = [index.section + 1, task.order]
        }
    }
    
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isCompleted {
            return 1
        } else {
            return groupArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if isCompleted { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            headerView.delegate = self
            headerView.setProperty(group: groupArray[section])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isCompleted { return 0.1 }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            return headerView.bounds.height
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCompleted {
            return completedTaskArray.count
        } else {
            return taskArray[section].count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if isCompleted {
            // 課題セル
            let task = completedTaskArray[indexPath.row]
            let realmManager = RealmManager()
            cell.textLabel?.text = task.title
            cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(realmManager.getMeasuresTitleInTask(taskID: task.taskID))"
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            if indexPath.row >= taskArray[indexPath.section].count {
                // 完了済み課題セル
                cell.textLabel?.text = TITLE_COMPLETED_TASK
                cell.textLabel?.textColor = UIColor.systemBlue
            } else {
                // 課題セル
                let task = taskArray[indexPath.section][indexPath.row]
                let realmManager = RealmManager()
                cell.textLabel?.text = task.title
                cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(realmManager.getMeasuresTitleInTask(taskID: task.taskID))"
                cell.detailTextLabel?.textColor = UIColor.lightGray
            }
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isCompleted { return false }
        if indexPath.row >= taskArray[indexPath.section].count {
            return false    // 解決済みの課題セルは編集不可
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if isCompleted { return false }
        if indexPath.row >= taskArray[indexPath.section].count {
            return false    // 完了課題セルは並び替え不可
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 完了課題セルの下に入れようとした場合は課題の最下端に並び替え
        var destinationIndex = destinationIndexPath
        let count = taskArray[destinationIndex.section].count
        if destinationIndex.row >= count {
            destinationIndex.row = count == 0 ? 0 : count - 1
        }
        
        // 並び替え
        let task = taskArray[sourceIndexPath.section][sourceIndexPath.row]
        taskArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        taskArray[destinationIndex.section].insert(task, at: destinationIndex.row)
        
        // 並び順を保存
        let realmManager = RealmManager()
        realmManager.updateTaskOrder(taskArray: taskArray)
        if sourceIndexPath.section != destinationIndex.section {
            // グループが変わる場合はグループも更新
            let groupId = groupArray[destinationIndex.section].groupID
            realmManager.updateTaskGroupId(task: task, groupID: groupId)
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isCompleted {
            // 課題セル
            let task = completedTaskArray[indexPath.row]
            delegate?.taskVCTaskCellDidTap(task: task)
        } else {
            // 完了済み課題セル
            if indexPath.row >= taskArray[indexPath.section].count {
                let groupID = groupArray[indexPath.section].groupID
                delegate?.taskVCCompletedTaskCellDidTap(groupID: groupID)
                return
            }
            // 課題セル
            let task = taskArray[indexPath.section][indexPath.row]
            delegate?.taskVCTaskCellDidTap(task: task)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none    // 削除アイコンを非表示
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false    // 削除アイコンのスペースを詰める
    }
    
}

extension TaskViewController: GroupHeaderViewDelegate {
    
    // セクションヘッダータップ時の処理
    func headerDidTap(view: GroupHeaderView) {
        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
    // セクションヘッダーのinfoボタンタップ時の処理
    func infoButtonDidTap(view: GroupHeaderView) {
        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
}
