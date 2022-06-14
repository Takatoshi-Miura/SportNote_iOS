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
    func noteVCFreeNoteDidTap(freeNote: Note)
    // 練習ノートタップ時
    func noteVCPracticeNoteDidTap(practiceNote: Note)
    // 大会ノートタップ時
    func noteVCTournamentNoteDidTap(tournamentNote: Note)
    // フィルタータップ時
    func noteVCFilterDidTap(_ viewController: UIViewController)
}

class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    private var noteArray: [Note] = []
    private var isFiltered: Bool = false
    var delegate: NoteViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        initSearchBar()
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
            // ノートが削除されていれば取り除く
            let note = noteArray[selectedIndex.row]
            if note.isDeleted {
                noteArray.remove(at: selectedIndex.row)
                tableView.deleteRows(at: [selectedIndex], with: UITableView.RowAnimation.left)
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
        let iconImage = isFiltered ? UIImage(named: "icon_filter_fill")! : UIImage(named: "icon_filter_empty")!
        let filterButton = UIBarButtonItem(image: iconImage,
                                           style: .done,
                                           target: self,
                                           action: #selector(moveNoteFilterVC))
        navigationItem.rightBarButtonItems = [filterButton]
    }
    
    func initSearchBar() {
        searchBar.searchTextField.placeholder = TITLE_SEARCH_NOTE
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
                self.refreshData()
                HUD.hide()
            })
        } else {
            refreshData()
        }
    }
    
    /// データを取得
    func refreshData() {
        let realmManager = RealmManager()
        noteArray = realmManager.getPracticeTournamentNote()
        noteArray.insert(realmManager.getFreeNote(), at: 0)
        tableView.refreshControl?.endRefreshing()
        tableView.reloadData()
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
    
    // MARK: - Action
    
    /// ノートの検索フィルタ画面へ遷移
    @objc func moveNoteFilterVC() {
        delegate?.noteVCFilterDidTap(self)
    }
    
    /// 検索フィルタによる検索
    func searchNoteWithFilter() {
        
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

extension NoteViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 未入力の場合は全検索
        if searchBar.text == "" {
            
        }
        // TODO: 検索機能の実装
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1    // セクションの個数
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        if noteArray.isEmpty {
            return cell
        }
        
        switch NoteType.allCases[noteArray[indexPath.row].noteType] {
        case .free:
            cell.textLabel?.text = noteArray[indexPath.row].title
            break
        case .practice:
            cell.textLabel?.text = noteArray[indexPath.row].detail
            break
        case .tournament:
            cell.textLabel?.text = noteArray[indexPath.row].target
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
        } else {
            switch NoteType.allCases[noteArray[indexPath.row].noteType] {
            case .free:
                self.delegate?.noteVCFreeNoteDidTap(freeNote: noteArray[indexPath.row])
                break
            case .practice:
                self.delegate?.noteVCPracticeNoteDidTap(practiceNote: noteArray[indexPath.row])
                break
            case .tournament:
                self.delegate?.noteVCTournamentNoteDidTap(tournamentNote: noteArray[indexPath.row])
                break
            }
        }
    }
    
}
