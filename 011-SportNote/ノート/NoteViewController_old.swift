//
//  NoteViewController_old.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds

class NoteViewController_old: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- 変数の宣言
    
    var dataManager = DataManager()
    
    // テーブル用
    var sectionTitle: [String] = ["フリーノート"]
    var noteInSection: [[Note_old]] = [[]]
    var selectedIndexPath: IndexPath = [0, 0]
    
    var isAdMobShow:Bool = false
    
    enum NoteType: Int {
        case freeNote = 0
        case practiceNote = 1
    }
    

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初回起動判定
        if UserDefaultsKey.firstLaunch.bool() {
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            UserDefaultsKey.firstLaunch.set(value: false)
            
            // フリーノートデータ作成
            dataManager.createFreeNoteData({})
            
            // 利用規約を表示
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
                // 同意後、チュートリアル画面に遷移
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController_old
                self.present(nextView, animated: true, completion: nil)
            })
        }
        
        // 同意していないなら利用規約を表示
        if !UserDefaultsKey.agree.bool() {
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
            })
        }
        
        setupTableView()
        setNavigationBarButtonDefault()
        reloadData()
    }
    
    /**
     tableViewの初期設定
     */
    func setupTableView() {
        tableView.allowsMultipleSelectionDuringEditing = true   // 複数選択可能
        tableView.tableFooterView = UIView()                    // データのないセルを非表示
        tableView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellReuseIdentifier: "noteViewCell")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /**
     通常時のNavigationBar設定
     */
    func setNavigationBarButtonDefault() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addNote(_:)))
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"),
                                             style: UIBarButtonItem.Style.plain,
                                             target: self,
                                             action: #selector(showCalendar(_:)))
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton, calendarButton])
    }
    
    /**
     編集時のNavigationBar設定
     */
    func setNavigationBarButtonIsEditing() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addNote(_:)))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                           target: self,
                                           action: #selector(deleteNotes(_:)))
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton, deleteButton])
    }
    
    /**
     ノートを追加(ノート追加画面に遷移)
     */
    @objc func addNote(_ sender: UIBarButtonItem) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddViewController")
        self.present(nextView, animated: true, completion: nil)
    }
    
    /**
     カレンダー表示
     */
    @objc func showCalendar(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goCalendarViewController", sender: nil)
    }
    
    /**
     ノートを複数削除
     */
    @objc func deleteNotes(_ sender: UIBarButtonItem) {
        guard let selectedIndexPaths = tableView.indexPathsForSelectedRows else {
            return
        }
        showDeleteNoteAlert(title: "ノートを削除" ,
                            message: "選択されたノートを削除します。よろしいですか？",
                            okAction:
        {
            // 配列の要素削除で、indexのずれを防ぐため、降順にソートする
            let sortedIndexPaths: [IndexPath] = selectedIndexPaths.sorted { $0.row > $1.row }
            for indexPath in sortedIndexPaths {
                self.deleteNote(indexPath)
            }
            self.setEditing(false, animated: true)
        })
    }
    
    /**
     ノートを1つ削除
     - Parameters:
     - indexPath: 削除したいノートが格納されているindexPath
     */
    func deleteNote(_ indexPath: IndexPath) {
        let note = noteInSection[indexPath.section][indexPath.row]
        dataManager.deleteNoteData(note, {})
        noteInSection[indexPath.section].remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
    }
    
    /**
     削除アラートを表示
     - Parameters:
      - title: アラートのタイトル
      - message: アラートのメッセージ
      - okAction: okタップ時の処理
     */
    func showDeleteNoteAlert(title: String, message: String, okAction: @escaping () -> ()) {
        showDeleteAlert(title: title, message: message, okAction: okAction)
    }
    
    /**
     NavigationBarにボタンをセット
     - Parameters:
      - leftBar: 左側に表示するボタン
      - rightBar: 右側に表示するボタン
     */
    func setNavigationBarButton(leftBar leftBarItems: [UIBarButtonItem],
                                rightBar rightBarItems: [UIBarButtonItem])
    {
        navigationItem.leftBarButtonItems = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    /**
     広告表示
     */
    func showAdMob() {
        if isAdMobShow { return }
        
        let AdMobTest: Bool = false     // 広告テストモード
        let AdMobID = "ca-app-pub-9630417275930781/4051421921"  // 広告ユニットID
        let TEST_ID = "ca-app-pub-3940256099942544/2934735716"  // テスト用広告ユニットID
        
        // バナー広告を宣言
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize:GADAdSizeBanner)
        
        // レイアウト調整(画面下部に設置)
        let tabBarController:UITabBarController = UITabBarController()
        let tabBarHeight = tabBarController.tabBar.frame.size.height
        admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - admobView.frame.height - tabBarHeight)
        admobView.frame.size = CGSize(width:self.view.frame.width, height:admobView.frame.height)
        
        // safeAreaの値を取得
        let bottomInsets = self.view.safeAreaInsets.bottom
        if(bottomInsets >= 30.0){
            admobView.frame.origin = CGPoint(x: 0, y: self.view.frame.size.height - admobView.frame.height - bottomInsets)
        }
        
        // テストモードの検出
        if AdMobTest {
            admobView.adUnitID = TEST_ID
        } else {
            admobView.adUnitID = AdMobID
        }
         
        admobView.rootViewController = self
        admobView.load(GADRequest())
         
        self.view.addSubview(admobView)
        
        isAdMobShow = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
    }
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.editButtonItem.title = "完了"
            setNavigationBarButtonIsEditing()
        } else {
            self.editButtonItem.title = "編集"
            setNavigationBarButtonDefault()
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
        tableView.reloadData()
    }
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteInSection[section].count     // 各セクションに含まれるノート数を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case NoteType.freeNote.rawValue:
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
                cell.textLabel!.text = dataManager.freeNoteData.getTitle()
                cell.detailTextLabel!.text = dataManager.freeNoteData.getDetail()
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
                cell.printNoteData(noteInSection[indexPath.section][indexPath.row])
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case NoteType.freeNote.rawValue:
                return 44   // セルのデフォルト高さ
            default:
                return 60   // カスタムセルの高さ
        }
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        return sectionTitle[section]    //セクション名を返す
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count       //セクションの個数を返す
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
        } else {
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // 画面遷移
            if indexPath.section == NoteType.freeNote.rawValue {
                performSegue(withIdentifier: "goFreeNoteViewController", sender: nil)
            } else {
                selectedIndexPath = indexPath
                if noteInSection[indexPath.section][indexPath.row].getNoteType() == "練習記録" {
                    performSegue(withIdentifier: "goPracticeNoteDetailViewController", sender: nil)
                } else {
                    performSegue(withIdentifier: "goCompetitionNoteDetailViewController", sender: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == NoteType.freeNote.rawValue {
            return false    // フリーノートセルは編集不可
        } else {
            return true     // 他のノートセルは編集可能
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            showDeleteNoteAlert(title: "ノートを削除",
                                message: "\(noteInSection[indexPath.section][indexPath.row].getCellTitle())\nを削除します。よろしいですか？",
                                okAction:
            {
                self.deleteNote(indexPath)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // ビューを作成
        let view = UIView(frame: CGRect.zero)
        let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "   \(sectionTitle[section])"
        label.textAlignment = NSTextAlignment.left
        label.backgroundColor = UIColor.systemGray5
        label.textColor =  UIColor.label
        view.addSubview(label)
        
        if section == NoteType.freeNote.rawValue {
            // フリーノートセクションは削除不可
        } else {
            // 目標セクション編集時の表示
            if tableView.isEditing {
                // セクションボタンの設定
                let button = UIButton(frame: CGRect(x:self.view.frame.maxX - 50, y:0, width:50, height: 30))
                button.backgroundColor = UIColor.systemRed
                button.setTitle("削除", for: .normal)
                button.tag = section //ボタンにタグをつける
                button.addTarget(self, action: #selector(deleteTarget(sender:)), for: .touchUpInside)
                view.addSubview(button)
            }
        }
        return view
    }
    
    /**
     目標を削除
     */
    @objc func deleteTarget(sender: UIButton){
        selectedIndexPath.section = sender.tag
        showDeleteNoteAlert(title: "目標を削除",
                            message: "\(sectionTitle[selectedIndexPath.section])\nを削除します。よろしいですか？",
                            okAction:
        {
            if self.noteInSection[self.selectedIndexPath.section].isEmpty {
                // ノートがない月ならセクションごと削除
                self.noteInSection[self.selectedIndexPath.section - 1].removeAll()
                self.dataManager.targetDataArray[self.selectedIndexPath.section - 1].setIsDeleted(true)
            } else {
                // ノートがある場合は目標テキストをクリア
                self.dataManager.targetDataArray[self.selectedIndexPath.section - 1].setDetail("")
            }
            self.updateTargetData(target: self.dataManager.targetDataArray[self.selectedIndexPath.section - 1])
        })
    }
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteViewController" {
            let freeNoteViewController = segue.destination as! FreeNoteViewController_old
            freeNoteViewController.dataManager.freeNoteData = dataManager.freeNoteData
        } else if segue.identifier == "goPracticeNoteDetailViewController" {
            let noteDetailViewController = segue.destination as! PracticeNoteDetailViewController
            noteDetailViewController.noteData = noteInSection[selectedIndexPath.section][selectedIndexPath.row]
        } else if segue.identifier == "goCompetitionNoteDetailViewController" {
            let noteDetailViewController = segue.destination as! CompetitionNoteDetailViewController
            noteDetailViewController.noteData = noteInSection[selectedIndexPath.section][selectedIndexPath.row]
        } else if segue.identifier == "goCalendarViewController" {
            let calendarViewController = segue.destination as! calendarViewController
            calendarViewController.dataManager.freeNoteData  = dataManager.freeNoteData
            calendarViewController.dataManager.noteDataArray = dataManager.noteDataArray
        }
    }
    
    // NoteViewControllerに戻ったときの処理
    @IBAction func goToNoteViewController(_segue:UIStoryboardSegue) {
    }
    
    
    //MARK:- データベース関連
    
    // フリーノートデータを取得
    func loadFreeNoteData() {
        dataManager.getFreeNoteData({})
    }
    
    // 目標データを取得
    func loadTargetData() {
        dataManager.getTargetData({
            // TargetDataとNoteDataのどちらが先にロードが終わるか不明なため、両方に記述
            // セクションデータを再構築
            self.resetSectionData()
            self.tableView?.reloadData()
        })
    }
    
    // ノートデータを取得
    func loadNoteData() {
        dataManager.getNoteData({
            // セクションデータを再構築
            self.resetSectionData()
            self.tableView?.reloadData()
        })
    }
    
    /**
     sectionTitleを初期化
     */
    func initSectionTitle() {
        sectionTitle = ["フリーノート"]
    }
    
    /**
     noteInSectionを初期化
     (フリーノート用に0番目にはダミーのノートを入れる)
     */
    func initNoteInSection() {
        let dummyNoteData = Note_old()
        self.noteInSection = [[]]
        self.noteInSection[NoteType.freeNote.rawValue].append(dummyNoteData)
    }
    
    /**
     sectionTitleとnoteInSectionを再構成
     */
    func resetSectionData() {
        initSectionTitle()
        initNoteInSection()
        
        if dataManager.targetDataArray.isEmpty {
        } else {
            for target in dataManager.targetDataArray {
                if target.getMonth() == 13 {
                    // 年間目標セクション追加
                    sectionTitle.append("\(target.getYear())年:\(target.getDetail())")
                    noteInSection.append([])
                } else {
                    // 月間目標セクション追加
                    sectionTitle.append("\(target.getMonth())月:\(target.getDetail())")
                    noteInSection.append(getNoteArray(target))
                }
            }
        }
    }
    
    /**
     目標データの年月と合致するノートを取得
     - Parameters:
     - target: 目標データ
     - returns: ノートデータ
     */
    func getNoteArray(_ target: Target_old) -> [Note_old] {
        var noteArray:[Note_old] = []
        for note in dataManager.noteDataArray {
            if note.getYear() == target.getYear()
                && note.getMonth() == target.getMonth()
            {
                noteArray.append(note)
            }
        }
        return noteArray
    }
    
    // データを取得
    func reloadData() {
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
    }
    
    // 目標を更新
    func updateTargetData(target targetData:Target_old) {
        dataManager.updateTargetData(targetData, {
            self.reloadData()
        })
    }
    
}
