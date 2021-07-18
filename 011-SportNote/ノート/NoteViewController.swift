//
//  NoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/03.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import GoogleMobileAds

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var dataManager = DataManager()
    
    // テーブル用
    var sectionTitle:[String] = ["フリーノート"]
    var dataInSection:[[Note]] = [[]]
    var sortedIndexPaths:[IndexPath] = []
    var deleteFinished:Bool = false
    var sectionIndex:Int = 0
    var rowIndex:Int = 0
    
    // 広告用
    let AdMobTest: Bool = false     // 広告テストモード
    let AdMobID = "ca-app-pub-9630417275930781/4051421921"  // 広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"  // テスト用広告ユニットID
    

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初回起動判定
        if UserDefaultsKey.firstLaunch.bool() {
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            UserDefaultsKey.firstLaunch.set(value: false)
            
            // ユーザーデータを作成
            let userData = UserData()
            userData.createUserData()
            UserDefaultsKey.userID.set(value: UserDefaults.standard.object(forKey: "userID") as! String)
            
            // フリーノートデータ作成
            dataManager.createFreeNoteData({})
            
            // 利用規約を表示
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
                // 同意後、チュートリアル画面に遷移
                let storyboard: UIStoryboard = self.storyboard!
                let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
                self.present(nextView, animated: true, completion: nil)
            })
        }
        
        // 同意していないなら利用規約を表示
        if !UserDefaultsKey.agree.bool() {
            displayAgreement({
                UserDefaultsKey.agree.set(value: true)
            })
        }
        
        // ユーザーデータの更新(利用状況の把握)
        let userData = UserData()
        userData.updateUserData()
        
        setupTableView()
        setNavigationBarButtonDefault()
        showAdMob()
        reloadData()
    }
    
    /**
     tableViewの初期設定
     */
    func setupTableView() {
        tableView.allowsMultipleSelectionDuringEditing = true   // 複数選択可能
        tableView.tableFooterView = UIView()                    // データのないセルを非表示
        tableView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellReuseIdentifier: "noteViewCell")
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
                                           action: #selector(deleteNote(_:)))
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
     ノートを削除
     */
    @objc func deleteNote(_ sender: UIBarButtonItem) {
        // ノートが選択されていない時は何もしない
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        // OKボタン
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // 配列の要素削除で、indexのずれを防ぐため、降順にソートする
            self.sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            
            for num in 0...self.sortedIndexPaths.count - 1 {
                // 最後の削除であればフラグをtrueにする
                if num == (self.sortedIndexPaths.count - 1) {
                    self.deleteFinished = true
                    // 選択されたノートを削除
                    self.deleteNoteData(note: self.dataInSection[self.sortedIndexPaths[num][0]][self.sortedIndexPaths[num][1]])
                } else {
                    // 選択されたノートを削除
                    self.deleteNoteData(note: self.dataInSection[self.sortedIndexPaths[num][0]][self.sortedIndexPaths[num][1]])
                }
            }
            // 編集状態を解除
            self.setEditing(false, animated: true)
        }
        // CANCELボタン
        let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        // アラート表示
        showAlert(title: "ノートを削除", message: "選択されたノートを削除します。よろしいですか？", actions: [okAction,cancelAction])
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
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        // 編集モード
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
        return dataInSection[section].count     // 各セクションに含まれるノート数を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                // フリーノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
                cell.textLabel!.text = dataManager.freeNoteData.getTitle()
                cell.detailTextLabel!.text = dataManager.freeNoteData.getDetail()
                cell.detailTextLabel?.textColor = UIColor.systemGray
                return cell
            default:
                // ノートセルを返却
                let cell = tableView.dequeueReusableCell(withIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
                cell.printNoteData(dataInSection[indexPath.section][indexPath.row])
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
            case 0:
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
            // 編集時の処理
        } else {
            // 通常時の処理
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            // 画面遷移
            if indexPath.section == 0 {
                // フリーノートセルがタップされたとき
                performSegue(withIdentifier: "goFreeNoteViewController", sender: nil)
            } else {
                // 選択されたIndexを取得
                sectionIndex = indexPath.section
                rowIndex = indexPath.row
                
                // ノートセルがタップされたとき
                if dataInSection[indexPath.section][indexPath.row].getNoteType() == "練習記録" {
                    // 練習ノートセル
                    performSegue(withIdentifier: "goPracticeNoteDetailViewController", sender: nil)
                } else {
                    // 大会ノートセル
                    performSegue(withIdentifier: "goCompetitionNoteDetailViewController", sender: nil)
                }
            }
        }
    }
    
    // セルの編集可否の設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false    // フリーノートセルは編集不可
        } else {
            return true     // 他のノートセルは編集可能
        }
    }
    
    // セルを削除したときの処理（左スワイプ）
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // OKボタン
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // ノートデータを削除
                self.deleteFinished = true
                self.deleteNoteData(note: self.dataInSection[indexPath.section][indexPath.row])
            }
            // CANCELボタン
            let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            showAlert(title: "ノートを削除", message: "\(dataInSection[indexPath.section][indexPath.row].getCellTitle())\nを削除します。よろしいですか？", actions: [okAction,cancelAction])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // ビューを作成
        let view = UIView(frame: CGRect.zero)
        
        // セクションラベルの設定
        let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "   \(sectionTitle[section])"
        label.textAlignment = NSTextAlignment.left
        label.backgroundColor = UIColor.systemGray5
        label.textColor =  UIColor.label
        view.addSubview(label)
        
        if section == 0 {
            // フリーノートセクションは削除不可
        } else {
            // 目標セクション編集時の表示
            if tableView.isEditing {
                // セクションボタンの設定
                let button = UIButton(frame: CGRect(x:self.view.frame.maxX - 50, y:0, width:50, height: 30))
                button.backgroundColor = UIColor.systemRed
                button.setTitle("削除", for: .normal)
                button.tag = section //ボタンにタグをつける
                button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
                view.addSubview(button)
            }
        }
        return view
    }
    
    @objc func buttonTapped(sender:UIButton){
        sectionIndex = sender.tag
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // ノートデータがない月のセクションであればセクションごと削除する
            if self.dataInSection[self.sectionIndex].isEmpty == true {
                self.dataInSection[self.sectionIndex - 1].removeAll()
                self.dataManager.targetDataArray[self.sectionIndex - 1].setIsDeleted(true)
            } else {
                // ノートがある場合は目標テキストをクリア
                self.dataManager.targetDataArray[self.sectionIndex - 1].setDetail("")
            }
            self.updateTargetData(target: self.dataManager.targetDataArray[self.sectionIndex - 1])
        }
        //CANCELボタンを宣言
        let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        showAlert(title: "目標を削除", message: "\(self.sectionTitle[self.sectionIndex])\nを削除します。よろしいですか？", actions: [okAction,cancelAction])
    }
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteViewController" {
            // 表示するデータを確認画面へ渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController
            freeNoteViewController.dataManager.freeNoteData = dataManager.freeNoteData
        } else if segue.identifier == "goPracticeNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! PracticeNoteDetailViewController
            noteDetailViewController.noteData = dataInSection[sectionIndex][rowIndex]
        } else if segue.identifier == "goCompetitionNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! CompetitionNoteDetailViewController
            noteDetailViewController.noteData = dataInSection[sectionIndex][rowIndex]
        } else if segue.identifier == "goCalendarViewController" {
            // データを遷移先に渡す
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
            self.reloadSectionData()
            // テーブルビューを更新
            self.tableView?.reloadData()
        })
    }
    
    // ノートデータを取得
    func loadNoteData() {
        dataManager.getNoteData({
            // セクションデータを再構築
            self.reloadSectionData()
            // テーブルビューを更新
            self.tableView?.reloadData()
        })
    }
    
    // データを取得
    func reloadData() {
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
    }
    
    // ノートデータを削除
    func deleteNoteData(note noteData:Note) {
        dataManager.deleteNoteData(noteData, {
            // 最後の削除であればリロード
            if self.deleteFinished {
                self.deleteFinished = false
                self.reloadData()
            }
        })
    }
    
    // 目標を更新
    func updateTargetData(target targetData:Target) {
        dataManager.updateTargetData(targetData, {
            self.reloadData()
        })
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 広告表示を行うメソッド
    func showAdMob() {
        // バナー広告を宣言
        var admobView = GADBannerView()
        admobView = GADBannerView(adSize:kGADAdSizeBanner)
        
        // レイアウト調整(画面下部に設置)
        admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - admobView.frame.height - 49)
        admobView.frame.size = CGSize(width:self.view.frame.width, height:admobView.frame.height)
        
        // safeAreaの値を取得
        let safeAreaInsets = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
        if(safeAreaInsets! >= 30.0){
            admobView.frame.origin = CGPoint(x:0, y:self.view.frame.size.height - admobView.frame.height - 80)
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
    }
    
    // 初期化dataInSection
    func dataInSectionInit() {
        // フリーノート用に0番目にはダミーデータを入れる
        let dummyNoteData = Note()
        self.dataInSection = [[]]
        self.dataInSection[0].append(dummyNoteData)
    }
    
    // sectionTitleとdataInSectionを再構成するメソッド
    func reloadSectionData() {
        // データ初期化
        self.sectionTitle = ["フリーノート"]
        self.dataInSectionInit()
        
        // targetDataArrayが空の時は更新しない（エラー対策）
        if self.dataManager.targetDataArray.isEmpty == false {
            // テーブルデータ更新
            for index in 0...(self.dataManager.targetDataArray.count - 1) {
                // 年間目標と月間目標の区別
                if self.dataManager.targetDataArray[index].getMonth() == 13 {
                    // 年間目標セクション追加
                    self.sectionTitle.append("\(self.dataManager.targetDataArray[index].getYear())年:\(self.dataManager.targetDataArray[index].getDetail())")
                    self.dataInSection.append([])
                } else {
                    // 月間目標セクション追加
                    self.sectionTitle.append("\(self.dataManager.targetDataArray[index].getMonth())月:\(self.dataManager.targetDataArray[index].getDetail())")
                    
                    // ノートデータ追加
                    var noteArray:[Note] = []
                    // noteDataArrayが空の時は更新しない（エラー対策）
                    if self.dataManager.noteDataArray.isEmpty == false {
                        // 年,月が合致するノート数だけappendする。
                        for count in 0...(self.dataManager.noteDataArray.count - 1) {
                            if self.dataManager.noteDataArray[count].getYear() == self.dataManager.targetDataArray[index].getYear()
                                && self.dataManager.noteDataArray[count].getMonth() == self.dataManager.targetDataArray[index].getMonth() {
                                noteArray.append(self.dataManager.noteDataArray[count])
                            }
                        }
                    }
                    self.dataInSection.append(noteArray)
                }
            }
        }
    }
    
}
