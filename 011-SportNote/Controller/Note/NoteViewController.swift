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
import RxSwift
import RxCocoa

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
    // ノートページモードタップ時
    func noteVCNotePageDidTap(_ viewController: UIViewController)
}

class NoteViewController: UIViewController {
    
    // MARK: - UI,Variable
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    private var viewModel: NoteViewModel
    private let disposeBag = DisposeBag()
    var delegate: NoteViewControllerDelegate?
    
    // MARK: - Initializer
    
    init() {
        self.viewModel = NoteViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationBar()
        initSearchBar()
        initTableView()
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
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // ノートが削除されていれば取り除く
            if (viewModel.deleteNoteFromArray(indexPath: selectedIndex)) {
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    // MARK: - Bind
    
    /// バインド設定
    private func initBind() {
        bindSearchBar()
        bindTableView()
        bindAddButton()
    }
    
    /// ページビュー切替ボタンのバインド
    /// - Parameter button: ボタン
    private func bindPageModeButton(button: UIBarButtonItem) {
        button.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.delegate?.noteVCNotePageDidTap(self)
            })
            .disposed(by: disposeBag)
        
        // フリーノート以外存在しない場合は非活性
        viewModel.noteArray
            .map { $0.count > 1 }
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    /// searchBarのバインド
    private func bindSearchBar() {
        searchBar
            .rx.text
            .orEmpty
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] searchText in
                self?.viewModel.selectNote(searchText: searchText)
            })
            .disposed(by: disposeBag)
        
        searchBar
            .rx.searchButtonClicked
            .subscribe(onNext: { [weak self] in
                self?.searchBar.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
    
    /// TableViewのバインド
    private func bindTableView() {
        viewModel.noteArray
            .bind(to: tableView.rx.items(cellIdentifier: "NoteCell", cellType: NoteCell.self)) { (row, note, cell) in
                cell.printInfo(note: note)
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
    
    /// ノート追加ボタンのバインド
    private func bindAddButton() {
        addButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                var alertActions: [UIAlertAction] = []
                let addPracticeNoteAction = UIAlertAction(title: TITLE_PRACTICE_NOTE, style: .default) { _ in
                    self.delegate?.noteVCAddPracticeNoteDidTap(self)
                }
                let addTournamentNoteAction = UIAlertAction(title: TITLE_TOURNAMENT_NOTE, style: .default) { _ in
                    self.delegate?.noteVCAddTournamentNoteDidTap(self)
                }
                alertActions.append(addPracticeNoteAction)
                alertActions.append(addTournamentNoteAction)
                
                showActionSheet(title: TITLE_ADD_NOTE, message: MESSAGE_ADD_NOTE, actions: alertActions, frame: addButton.frame)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Other Methods
    
    /// NavigationBar初期化
    private func initNavigationBar() {
        self.title = TITLE_NOTE
        let pageModeButton = UIBarButtonItem(image: UIImage(systemName: "doc.plaintext"), style: .plain, target: self, action: nil)
        bindPageModeButton(button: pageModeButton)
        navigationItem.rightBarButtonItems = [pageModeButton]
    }
    
    /// SearchBar初期化
    private func initSearchBar() {
        searchBar.searchTextField.placeholder = TITLE_SEARCH_NOTE
    }
    
    /// TableView初期化
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(syncData), for: .valueChanged)
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 旧データ変換後に同期処理
    private func syncDataWithConvert() {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
        viewModel.syncDataWithConvert(completion: {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            HUD.hide()
        })
    }
    
    /// データの同期処理
    @objc func syncData() {
        HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
        viewModel.syncData(completion: {
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            HUD.hide()
        })
    }
    
    /// データの同期処理
    @objc func refreshData() {
        viewModel.refreshData()
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
        adView.addSubview(adMobView!)
    }
    
}
