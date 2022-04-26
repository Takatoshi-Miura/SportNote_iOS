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
    // 練習ノート追加ボタンタップ時
    func noteVCAddPracticeNoteDidTap(_ viewController: UIViewController)
    // 大会ノート追加ボタンタップ時
    func noteVCAddTournamentNoteDidTap(_ viewController: UIViewController)
    // フリーノートタップ時
    func noteVCFreeNoteDidTap(freeNote: FreeNote)
}

class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    private var freeNote = FreeNote()
    private var noteArray: [Any] = []
    var delegate: NoteViewControllerDelegate?
    
    private enum Section: Int, CaseIterable {
        case freeNote = 0
        case note
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initTableView()
        // 初回のみ旧データ変換後に同期処理
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            let dataConverter = DataConverter()
            dataConverter.convertOldToRealm(completion: {
                self.syncData()
            })
        } else {
            self.syncData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedIndex = tableView.indexPathForSelectedRow {
            switch Section.allCases[selectedIndex.section] {
            case .freeNote:
                break
            case .note:
                // ノートが削除されていれば取り除く
                let note = noteArray[selectedIndex.row]
                if note is PracticeNote {
                    if (note as! PracticeNote).isDeleted {
                        noteArray.remove(at: selectedIndex.row)
                        tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                    }
                } else {
                    if (note as! TournamentNote).isDeleted {
                        noteArray.remove(at: selectedIndex.row)
                        tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
                    }
                }
                break
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
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
                self.freeNote = realmManager.getFreeNote()
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
    
    /// 追加ボタンの処理
    @IBAction func tapAddButton(_ sender: Any) {
        var alertActions: [UIAlertAction] = []
        let addPracticeNoteAction = UIAlertAction(title: TITLE_PRACTICE_NOTE, style: .default) { _ in
            self.delegate?.noteVCAddPracticeNoteDidTap(self)
        }
        let addTournamentNoteAction = UIAlertAction(title: TITLE_TOURNAMENT_NOTE, style: .default) { _ in
            self.delegate?.noteVCAddTournamentNoteDidTap(self)
        }
        alertActions.append(addPracticeNoteAction)
        alertActions.append(addTournamentNoteAction)
        
        showActionSheet(title: TITLE_ADD_NOTE,
                        message: MESSAGE_ADD_NOTE,
                        actions: alertActions,
                        frame: addButton.frame)
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        switch Section.allCases[section] {
        case .freeNote:
            return TITLE_FREE_NOTE
        case .note:
            return TITLE_NOTE
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2    // セクションの個数
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section.allCases[section] {
        case .freeNote:
            return 1
        case .note:
            return noteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        switch Section.allCases[indexPath.section] {
        case .freeNote:
            cell.textLabel?.text = freeNote.title
            return cell
        case .note:
            if !noteArray.isEmpty {
                if noteArray[indexPath.row] is PracticeNote {
                    cell.textLabel?.text = PracticeNote(value: noteArray[indexPath.row]).detail
                } else {
                    cell.textLabel?.text = TournamentNote(value: noteArray[indexPath.row]).target
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
        } else {
            switch Section.allCases[indexPath.section] {
            case .freeNote:
                self.delegate?.noteVCFreeNoteDidTap(freeNote: freeNote)
            case .note:
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
