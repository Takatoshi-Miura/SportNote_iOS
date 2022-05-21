//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/22.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol SettingViewControllerDelegate: AnyObject {
    // キャンセルタップ時の処理
    func settingVCCancelDidTap(_ viewController: UIViewController)
}

class SettingViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    var delegate: SettingViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
    }
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_SETTING
    }
    
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Action
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.settingVCCancelDidTap(self)
    }
    
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
