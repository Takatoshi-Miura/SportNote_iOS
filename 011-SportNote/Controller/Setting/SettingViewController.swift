//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/22.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import MessageUI
import RxSwift
import RxCocoa

protocol SettingViewControllerDelegate: AnyObject {
    // キャンセルタップ時の処理
    func settingVCCancelDidTap(_ viewController: UIViewController)
    // データの引継ぎタップ時の処理
    func settingVCDataTransferDidTap(_ viewController: UIViewController)
    // アプリの使い方タップ時の処理
    func settingVCTutorialDidTap(_ viewController: UIViewController)
}

class SettingViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    private var viewModel: SettingViewModel
    private let disposeBag = DisposeBag()
    var delegate: SettingViewControllerDelegate?
    
    // MARK: - Initializer
    
    init() {
        self.viewModel = SettingViewModel()
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
        initBind()
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindCancelButton()
    }
    
    /// キャンセルボタンのバインド
    private func bindCancelButton() {
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                delegate?.settingVCCancelDidTap(self)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_SETTING
    }
    
    /// クラッシュログ取得テスト用
    private func crashlyticsTest() {
        fatalError("Crashlytics test")
    }
    
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    /// TableView初期化
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        #if DEBUG
        return SettingViewModel.Section.allCases.count
        #else
        // 本番ではクラッシュテストは非表示
        return SettingViewModel.Section.allCases.count - 1
        #endif
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return SettingViewModel.Section.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.cells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if (indexPath.section == SettingViewModel.Section.systemInfo.rawValue) {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
            cell.detailTextLabel?.text = "\(AppInfo.getAppVersion())"
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.accessoryType = .disclosureIndicator
        }
        
        let viewModelCell = viewModel.cells[indexPath.section][indexPath.row]
        cell.imageView?.image = viewModelCell.image
        cell.textLabel?.text = viewModelCell.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch viewModel.cells[indexPath.section][indexPath.row] {
        case .dataTransfer:
            delegate?.settingVCDataTransferDidTap(self)
            break
        case .help:
            delegate?.settingVCTutorialDidTap(self)
            break
        case .inquiry:
            startMailer()
            break
        case .appVersion:
            break
        case .crashlyticsTest:
            crashlyticsTest()
            break
        }
    }
    
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    /// メーラーを起動
    private func startMailer() {
        if MFMailComposeViewController.canSendMail() == false {
            showErrorAlert(message: MESSAGE_MAILER_ERROR)
            return
        }
        let mailViewController = MFMailComposeViewController()
        mailViewController.mailComposeDelegate = self
        mailViewController.setToRecipients(["SportsNote開発者<it6210ge@gmail.com>"])
        mailViewController.setSubject(TITLE_MAIL_SUBJECT)
        let deviceName = AppInfo.getDeviceName()
        let osVersion = AppInfo.getOSVersion()
        let appVersion = AppInfo.getAppVersion()
        let message = String(format: TITLE_MAIL_MESSAGE, deviceName, osVersion, appVersion)
        mailViewController.setMessageBody(message, isHTML: false)
        self.present(mailViewController, animated: true, completion: nil)
    }
    
    /// メーラーを終了
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
        
        switch result {
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            showOKAlert(title: TITLE_SUCCESS, message: MESSAGE_MAIL_SEND_SUCCESS)
            break
        case .failed:
            showErrorAlert(message: MESSAGE_MAIL_SEND_FAILED)
            break
        default:
            break
        }
    }
    
}
