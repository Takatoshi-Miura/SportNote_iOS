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
import RxSwift
import RxCocoa

protocol TaskViewControllerDelegate: AnyObject {
    // グループ追加タップ時の処理
    func taskVCAddGroupDidTap(_ viewController: UIViewController)
    // 課題追加タップ時の処理
    func taskVCAddTaskDidTap(_ viewController: UIViewController)
    // セクションヘッダータップ時の処理
    func taskVCHeaderDidTap(group: Group)
    // 課題セルタップ時の処理
    func taskVCTaskCellDidTap(task: TaskData)
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
    private var adMobView: GADBannerView?
    private var viewModel: TaskViewModel
    private let disposeBag = DisposeBag()
    var delegate: TaskViewControllerDelegate?
    
    // MARK: - Initializer
    
    init(isComplete: Bool, groupID: String) {
        self.viewModel = TaskViewModel(isComplete: isComplete, groupID: groupID)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        initNotification()
        displayAgreement()
        initBind()
        // 初回のみ旧データ変換後に同期処理
        syncDataWithConvert()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleSelectedCell()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindAddButton()
    }
    
    /// 課題,グループ追加ボタンのバインド
    private func bindAddButton() {
        addButton.rx.tap
            .subscribe(onNext: { [unowned self] in
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
            })
            .disposed(by: disposeBag)
    }
    
    /// 設定ボタンのバインド
    /// - Parameter button: 設定ボタン
    private func bindSettingButton(button: UIBarButtonItem) {
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.delegate?.taskVCSettingDidTap(self)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        if viewModel.isComplete {
            self.title = TITLE_COMPLETED_TASK
            addButton.isHidden = true
        } else {
            self.title = TITLE_TASK
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: nil)
            bindSettingButton(button: settingButton)
            navigationItem.leftBarButtonItems = [settingButton]
        }
    }
    
    /// 通知設定
    private func initNotification() {
        // ログイン時のリロード用
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncData),
                                               name: NSNotification.Name(rawValue: "afterLogin"),
                                               object: nil)
        // ログアウト時のリロード用
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.syncDataWithConvert),
                                               name: NSNotification.Name(rawValue: "afterLogout"),
                                               object: nil)
    }
    
    /// データの同期処理
    @objc func syncData() {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
        viewModel.syncData()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        HUD.hide()
    }
    
    /// データ変換＆同期処理
    /// ログアウト後は未分類グループなどを自動生成する必要がある
    @objc func syncDataWithConvert() {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
        viewModel.syncDataWithConvert()
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
        HUD.hide()
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
        // 初回起動時に利用規約を表示
        if UserDefaultsKey.firstLaunch.bool() {
            UserDefaultsKey.firstLaunch.set(value: false)
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
    
    /// グループを挿入
    /// - Parameter group: グループ
    func insertGroup(group: Group) {
        let index = viewModel.insertGroup(group: group)
        tableView.insertSections(IndexSet(integer: index.section), with: UITableView.RowAnimation.right)
    }
    
    /// 課題を挿入(最後尾に追加)
    /// - Parameters:
    ///   - task: 挿入する課題
    func insertTask(task: TaskData) {
        let index = viewModel.insertTask(task: task)
        tableView.insertRows(at: [index], with: UITableView.RowAnimation.right)
    }
    
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// TableView初期化
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
    
    /// 選択されたセルを更新
    private func handleSelectedCell() {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // 課題が完了状態が更新or削除されていれば取り除く
            if (viewModel.deleteTaskFromArray(indexPath: selectedIndex)) {
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        } else {
            // グループから戻る場合はリロード
            viewModel.refreshData()
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.isComplete { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            headerView.delegate = self
            headerView.printInfo(group: viewModel.groupArray.value[section])
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.isComplete { return 0.1 }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: GroupHeaderView.self))
        if let headerView = view as? GroupHeaderView {
            return headerView.bounds.height
        }
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if viewModel.isComplete {
            // 課題セル
            let task = viewModel.completedTaskArray.value[indexPath.row]
            let realmManager = RealmManager()
            cell.textLabel?.text = task.title
            cell.detailTextLabel?.text = "\(TITLE_MEASURES)：\(realmManager.getMeasuresTitleInTask(taskID: task.taskID))"
            cell.detailTextLabel?.textColor = UIColor.lightGray
        } else {
            if indexPath.row >= viewModel.taskArray.value[indexPath.section].count {
                // 完了済み課題セル
                cell.textLabel?.text = TITLE_COMPLETED_TASK
                cell.textLabel?.textColor = UIColor.systemBlue
            } else {
                // 課題セル
                let task = viewModel.taskArray.value[indexPath.section][indexPath.row]
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
        return viewModel.getCanEditRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return viewModel.getCanMoveRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveTask(from: sourceIndexPath, to: destinationIndexPath)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.isComplete {
            // 課題セル
            let task = viewModel.completedTaskArray.value[indexPath.row]
            delegate?.taskVCTaskCellDidTap(task: task)
        } else {
            // 完了済み課題セル
            if indexPath.row >= viewModel.taskArray.value[indexPath.section].count {
                let groupID = viewModel.groupArray.value[indexPath.section].groupID
                delegate?.taskVCCompletedTaskCellDidTap(groupID: groupID)
                return
            }
            // 課題セル
            let task = viewModel.taskArray.value[indexPath.section][indexPath.row]
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
