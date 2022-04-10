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
}

class TaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var groupArray: [Group] = []
    private var taskArray: [[Task]] = []
    private var adMobView: GADBannerView?
    var delegate: TaskViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        // 初回のみ旧データ変換後に同期処理
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
        let dataConverter = DataConverter()
        dataConverter.convertOldToRealm(completion: {
            self.syncData()
        })
    }
    
    func initNavigationController() {
        self.title = TITLE_TASK
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(openSettingView(_:)))
        navigationItem.rightBarButtonItems = [settingButton]
    }
    
    func initTableView() {
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
    
    /// データの同期処理
    @objc func syncData() {
        let realmManager = RealmManager()
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let syncManager = SyncManager()
            syncManager.syncDatabase(completion: {
                // TODO: 日付の降順(新しい順)で表示
                self.groupArray = []
                self.taskArray = []
                self.groupArray.append(contentsOf: realmManager.getGroupArrayForTaskView())
                self.taskArray.append(contentsOf: realmManager.getTaskArrayForTaskView())
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                HUD.hide()
            })
        } else {
            self.groupArray = []
            self.taskArray = []
            self.groupArray.append(contentsOf: realmManager.getGroupArrayForTaskView())
            self.taskArray.append(contentsOf: realmManager.getTaskArrayForTaskView())
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    @objc func openSettingView(_ sender: UIBarButtonItem) {
//        self.delegate?.taskVCHumburgerMenuButtonDidTap(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    /// バナー広告を表示
    func showAdMob() {
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
    
    @IBAction func tapAddButton(_ sender: Any) {
        var alertActions: [UIAlertAction] = []
        let addGroupAction = UIAlertAction(title: TITLE_GROUP, style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addTaskAction = UIAlertAction(title: TITLE_TASK, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        alertActions.append(addGroupAction)
        alertActions.append(addTaskAction)
        
        showActionSheet(title: TITLE_ADD_GROUP_TASK,
                        message: MESSAGE_ADD_GROUP_TASK,
                        actions: alertActions,
                        frame: addButton.frame)
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
    
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            headerView.delegate = self
            headerView.setProperty(group: groupArray[section])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            return headerView.bounds.height
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray[section].count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.row >= taskArray[indexPath.section].count {
            // 完了済み課題セル
            cell.textLabel?.text = TITLE_COMPLETED_TASK
            cell.textLabel?.textColor = UIColor.systemBlue
        } else {
            // 課題セル
            let task = taskArray[indexPath.section][indexPath.row]
            cell.textLabel?.text = task.title
            let realmManager = RealmManager()
            cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(realmManager.getMeasuresTitleInTask(taskID: task.taskID))"
            cell.detailTextLabel?.textColor = UIColor.lightGray
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row >= taskArray[indexPath.section].count {
            return false    // 解決済みの課題セルは編集不可
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
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
        
        // 並び順を保存
        let task = taskArray[sourceIndexPath.section][sourceIndexPath.row]
        taskArray[sourceIndexPath.section].remove(at: sourceIndexPath.row)
        taskArray[destinationIndex.section].insert(task, at: destinationIndex.row)
        // TODO: 並び替え保存
        //updateTaskOrderRealm(taskArray: taskArray)
        
        // グループが変わる場合はグループも更新
//        if sourceIndexPath.section != destinationIndex.section {
//            let groupId = groupArray[destinationIndex.section].getGroupID()
//            updateTaskGroupIdRealm(task: task, ID: groupId)
//        }
        tableView.reloadData()
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
        print("セクションタップ判定")
//        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
    // セクションヘッダーのinfoボタンタップ時の処理
    func infoButtonDidTap(view: GroupHeaderView) {
        print("infoボタンタップ判定")
//        delegate?.taskVCHeaderDidTap(group: view.group)
    }
    
}
