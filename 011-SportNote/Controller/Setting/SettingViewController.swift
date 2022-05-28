//
//  SettingViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/05/22.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import MessageUI

protocol SettingViewControllerDelegate: AnyObject {
    // キャンセルタップ時の処理
    func settingVCCancelDidTap(_ viewController: UIViewController)
}

class SettingViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    private var cells: [[Cell]] = [[Cell.dataTransfer], [Cell.help, Cell.inquiry]]
    var delegate: SettingViewControllerDelegate?
    
    private enum Section: Int, CaseIterable {
        case data
        case help
        var title: String {
            switch self {
            case .data: return TITLE_DATA
            case .help: return TITLE_HELP
            }
        }
    }
    
    private enum Cell: Int, CaseIterable {
        case dataTransfer
        case help
        case inquiry
        var title: String {
            switch self {
            case .dataTransfer: return TITLE_DATA_TRANSFER
            case .help: return TITLE_HOW_TO_USE_THIS_APP
            case .inquiry: return TITLE_INQUIRY
            }
        }
        var image: UIImage {
            switch self {
            case .dataTransfer: return UIImage(systemName: "icloud.and.arrow.up")!
            case .help: return UIImage(systemName: "questionmark.circle")!
            case .inquiry: return UIImage(systemName: "envelope")!
            }
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.imageView?.image = cells[indexPath.section][indexPath.row].image
        cell.textLabel?.text = cells[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cells[indexPath.section][indexPath.row] {
        // TODO: 定義
        case .dataTransfer:
            print("引き継ぎ")
            break
        case .help:
            print("使い方")
            break
        case .inquiry:
            startMailer()
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
        mailViewController.setMessageBody(TITLE_MAIL_MESSAGE, isHTML: false)
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