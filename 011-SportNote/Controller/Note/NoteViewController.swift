//
//  NoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD

protocol NoteViewControllerDelegate: AnyObject {
}

class NoteViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    private var targetArray: [Target] = []
    private var freeNote = FreeNote()
    private var noteArray: [Any] = []
    var delegate: NoteViewControllerDelegate?
    
    private enum Section: Int {
        case freeNote = 0
        case note
    }
    
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
    }
    
    func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
//        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let syncManager = SyncManager()
            syncManager.syncDatabase(completion: {
                let realmManager = RealmManager()
                // TODO: 日付の降順(新しい順)で表示
                self.noteArray = []
                self.noteArray.append(contentsOf: realmManager.getAllPracticeNote())
                self.noteArray.append(contentsOf: realmManager.getAllTournamentNote())
                self.targetArray = realmManager.getAllTarget()
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
                HUD.hide()
            })
        } else {
            tableView.refreshControl?.endRefreshing()
            tableView.reloadData()
        }
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
        adView.addSubview(adMobView!)
    }
    
    @IBAction func tapAddButton(_ sender: Any) {
        var alertActions: [UIAlertAction] = []
        let addTargetAction = UIAlertAction(title: TITLE_TARGET, style: .default) { _ in
//            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addPracticeNoteAction = UIAlertAction(title: TITLE_PRACTICE_NOTE, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        let addTournamentNoteAction = UIAlertAction(title: TITLE_TOURNAMENT_NOTE, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        alertActions.append(addTargetAction)
        alertActions.append(addPracticeNoteAction)
        alertActions.append(addTournamentNoteAction)
        
        showActionSheet(title: TITLE_ADD_TARGET_NOTE_TASK,
                        message: MESSAGE_ADD_TARGET_NOTE_TASK,
                        actions: alertActions,
                        frame: addButton.frame)
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        if targetArray.isEmpty {
            return ""
        }
        return String(targetArray[section].month)   // セクション名を返す
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if targetArray.isEmpty {
            return 1
        }
        return targetArray.count    // セクションの個数を返す
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        if !noteArray.isEmpty {
            if noteArray[indexPath.row] is PracticeNote {
                cell.textLabel?.text = PracticeNote(value: noteArray[indexPath.row]).detail
            } else {
                cell.textLabel?.text = TournamentNote(value: noteArray[indexPath.row]).target
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
        } else {
            if indexPath.section == Section.freeNote.rawValue {
                // TODO: フリーノートへ遷移
            } else {
                let note = noteArray[indexPath.row]
                if note is PracticeNote {
                    // TODO: 練習ノートへ遷移
                } else {
                    // TODO: 大会ノートへ遷移
                }
            }
        }
    }
    
}
