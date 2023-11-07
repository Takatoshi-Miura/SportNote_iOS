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
        bindTableView()
    }
    
    /// キャンセルボタンのバインド
    private func bindCancelButton() {
        cancelButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                delegate?.settingVCCancelDidTap(self)
            })
            .disposed(by: disposeBag)
    }
    
    /// TableViewのバインド
    private func bindTableView() {
        viewModel.cells
            .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { (row, note, cell) in
                cell.imageView?.image = cells[indexPath.section][indexPath.row].image
                cell.textLabel?.text = cells[indexPath.section][indexPath.row].title
                cell.accessoryType = .disclosureIndicator
            }
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Note.self)
            .subscribe(onNext: { [weak self] selectedNote in
                guard let self = self else { return }
                switch NoteType.allCases[selectedNote.noteType] {
                case .free:
                    self.delegate?.noteVCFreeNoteDidTap(freeNote: selectedNote)
                case .practice:
                    self.delegate?.noteVCPracticeNoteDidTap(practiceNote: selectedNote)
                case .tournament:
                    self.delegate?.noteVCTournamentNoteDidTap(tournamentNote: selectedNote)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        naviItem.title = TITLE_SETTING
    }
    
    /// TableView初期化
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
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
        tableView.deselectRow(at: indexPath, animated: true)
        switch cells[indexPath.section][indexPath.row] {
        case .dataTransfer:
            delegate?.settingVCDataTransferDidTap(self)
            break
        case .help:
            delegate?.settingVCTutorialDidTap(self)
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
