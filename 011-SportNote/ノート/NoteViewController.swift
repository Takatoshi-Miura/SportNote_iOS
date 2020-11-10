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

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ユーザーデータの更新(利用状況の把握)
        let userData = UserData()
        userData.updateUserData()
        
        // 初回起動判定
        if UserDefaults.standard.bool(forKey: "firstLaunch") {
            // 初回起動時の処理
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            UserDefaults.standard.set(false, forKey: "firstLaunch")
            
            // 2回目以降の起動では「userID」を今回生成したIDで固定(アカウント持ちならFirebaseIDで固定)
            UserDefaults.standard.set(UserDefaults.standard.object(forKey: "userID") as! String, forKey: "userID")
            
            // フリーノートデータ作成
            createFreeNoteData()
            
            // チュートリアル画面に遷移
            let storyboard: UIStoryboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "PageViewController") as! PageViewController
            self.present(nextView, animated: true, completion: nil)
        }
        
        // 新規バージョンでの初回起動判定
        if UserDefaults.standard.bool(forKey: "ver1.4") == false {
            // ユーザーデータを作成
            let userData = UserData()
            userData.createUserData()
            
            // 利用規約を表示
            displayAgreement()
        }
        
        // デバック用
        //UserDefaults.standard.removeObject(forKey: "ver1.4")
    
        // 編集ボタンの設定(複数選択可能)
        tableView.allowsMultipleSelectionDuringEditing = true
        
        // ナビゲーションバーのボタンを宣言
        createNavigationBarButton()
        
        // ネビゲーションボタンをセット
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,calendarButton])
        
        // カスタムセルを登録
        tableView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellReuseIdentifier: "noteViewCell")
        
        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
        
        // 広告表示
        self.displayAdMob()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データ取得
        reloadData()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // データ格納用
    var freeNoteData = FreeNote()
    var targetDataArray = [TargetData]()
    var noteDataArray = [NoteData]()
    
    // テーブル用
    var sectionTitle:[String] = ["フリーノート"]
    var dataInSection:[[NoteData]] = [[]]
    var sortedIndexPaths:[IndexPath] = []
    var deleteFinished:Bool = false
    var sectionIndex:Int = 0
    var rowIndex:Int = 0
    
    // ナビゲーションバー用のボタン
    var deleteButton:UIBarButtonItem!   // ゴミ箱ボタン
    var addButton:UIBarButtonItem!      // 追加ボタン
    var calendarButton:UIBarButtonItem! // カレンダーボタン
    
    // 広告用
    let AdMobTest:Bool = false          // 広告テストモード
    let AdMobID = "ca-app-pub-9630417275930781/4051421921"  // 広告ユニットID
    let TEST_ID = "ca-app-pub-3940256099942544/2934735716"  // テスト用広告ユニットID
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            // 編集開始
            self.editButtonItem.title = "完了"
            
            // ナビゲーションバーのボタンをセット
            self.setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,deleteButton])
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            
            // ナビゲーションバーのボタンを表示
            self.setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,calendarButton])
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
        tableView.reloadData()
    }
    
    // ゴミ箱ボタンの処理
    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        // 選択された課題を削除
        self.deleteRows()
    }
    
    // ノート追加ボタンの処理
    @objc func addButtonTapped(_ sender: UIBarButtonItem) {
        // ノート追加画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddViewController")
        self.present(nextView, animated: true, completion: nil)
    }
    
    // カレンダーボタンの処理
    @objc func calendarButtonTapped(_ sender: UIBarButtonItem) {
        // カレンダー画面へ遷移
        performSegue(withIdentifier: "goCalendarViewController", sender: nil)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataInSection[section].count     // セルの個数(ノート数)を返却
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 最上位はフリーノートセル、それ以外はノートセル
        switch indexPath.section {
            case 0:
                // フリーノートセルを返却
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
                cell.textLabel!.text = freeNoteData.getTitle()
                cell.detailTextLabel!.text = freeNoteData.getDetail()
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
            return 60  // カスタムセルの高さ
        }
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        return sectionTitle[section]    //セクション名を返す
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count       //セクションの個数を返す
    }
    
    // セルをタップしたときの処理
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
    
    // 複数のセルを削除
    func deleteRows() {
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"ノートを削除",message:"選択されたノートを削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
        
        // OKボタンを宣言
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
        // CANCELボタンを宣言
        let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        
        // ボタンを追加
        alertController.addAction(cancelButton)
        alertController.addAction(okAction)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
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
            // アラートダイアログを生成
            let alertController = UIAlertController(title:"ノートを削除",message:"\(dataInSection[indexPath.section][indexPath.row].getCellTitle())\nを削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
            
            // OKボタンを宣言
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // OKボタンがタップされたときの処理
                // ノートデータを削除
                self.deleteFinished = true
                self.deleteNoteData(note: self.dataInSection[indexPath.section][indexPath.row])
            }
            //OKボタンを追加
            alertController.addAction(okAction)
            
            //CANCELボタンを宣言
            let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            //CANCELボタンを追加
            alertController.addAction(cancelButton)
            
            //アラートダイアログを表示
            present(alertController,animated:true,completion:nil)
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
        
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"目標を削除",message:"\(self.sectionTitle[self.sectionIndex])\nを削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            // ノートデータがない月のセクションであればセクションごと削除する
            if self.dataInSection[self.sectionIndex].isEmpty == true {
                self.dataInSection[self.sectionIndex - 1].removeAll()
                self.targetDataArray[self.sectionIndex - 1].setIsDeleted(true)
            } else {
                // ノートがある場合は目標テキストをクリア
                self.targetDataArray[self.sectionIndex - 1].setDetail("")
            }
            self.updateTargetData(target: self.targetDataArray[self.sectionIndex - 1])
        }
        //OKボタンを追加
        alertController.addAction(okAction)
        
        //CANCELボタンを宣言
        let cancelButton = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        //CANCELボタンを追加
        alertController.addAction(cancelButton)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteViewController" {
            // 表示するデータを確認画面へ渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController
            freeNoteViewController.freeNoteData = freeNoteData
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
            calendarViewController.freeNoteData  = self.freeNoteData
            calendarViewController.noteDataArray = self.noteDataArray
        }
    }
    
    // NoteViewControllerに戻ったときの処理
    @IBAction func goToNoteViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- データベース関連
    
    // Firebaseにフリーノートデータを作成するメソッド(初回起動時のみ実行)
    func createFreeNoteData() {
        // フリーノートデータを作成
        let freeNote = FreeNote()
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // ユーザーUIDをセット
        freeNote.setUserID(userID)
        
        // 現在時刻をセット
        freeNote.setCreated_at(getCurrentTime())
        freeNote.setUpdated_at(freeNote.getCreated_at())
        
        // Firebaseにデータを保存
        let db = Firestore.firestore()
        db.collection("FreeNoteData").document("\(freeNote.getUserID())").setData([
            "title"      : freeNote.getTitle(),
            "detail"     : freeNote.getDetail(),
            "userID"     : freeNote.getUserID(),
            "created_at" : freeNote.getCreated_at(),
            "updated_at" : freeNote.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // ユーザーUIDをセット
        freeNoteData.setUserID(userID)
        
        // 現在のユーザーのフリーノートデータを取得する
        let db = Firestore.firestore()
        db.collection("FreeNoteData")
            .whereField("userID", isEqualTo: userID)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let freeNoteDataCollection = document.data()
                    
                    // フリーノートデータを反映
                    self.freeNoteData.setTitle(freeNoteDataCollection["title"] as! String)
                    self.freeNoteData.setDetail(freeNoteDataCollection["detail"] as! String)
                    self.freeNoteData.setUserID(freeNoteDataCollection["userID"] as! String)
                    self.freeNoteData.setCreated_at(freeNoteDataCollection["created_at"] as! String)
                    self.freeNoteData.setUpdated_at(freeNoteDataCollection["updated_at"] as! String)
                }
            }
        }
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        // targetDataArrayを初期化
        targetDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーの目標データを取得する
        let db = Firestore.firestore()
        db.collection("TargetData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // 目標オブジェクトを作成
                    let target = TargetData()
                    
                    // 目標データを反映
                    let targetDataCollection = document.data()
                    target.setYear(targetDataCollection["year"] as! Int)
                    target.setMonth(targetDataCollection["month"] as! Int)
                    target.setDetail(targetDataCollection["detail"] as! String)
                    target.setIsDeleted(targetDataCollection["isDeleted"] as! Bool)
                    target.setUserID(targetDataCollection["userID"] as! String)
                    target.setCreated_at(targetDataCollection["created_at"] as! String)
                    target.setUpdated_at(targetDataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.targetDataArray.append(target)
                }
                // TargetDataとNoteDataのどちらが先にロードが終わるか不明なため、両方に記述
                // セクションデータを再構築
                self.reloadSectionData()
                
                // テーブルビューを更新
                self.tableView?.reloadData()
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        // noteDataArrayを初期化
        noteDataArray = []
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
        db.collection("NoteData")
            .whereField("userID", isEqualTo: userID)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "year", descending: true)
            .order(by: "month", descending: true)
            .order(by: "date", descending: true)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // オブジェクトを作成
                    let noteData = NoteData()
                    
                    // 目標データを反映
                    let dataCollection = document.data()
                    noteData.setNoteID(dataCollection["noteID"] as! Int)
                    noteData.setNoteType(dataCollection["noteType"] as! String)
                    noteData.setYear(dataCollection["year"] as! Int)
                    noteData.setMonth(dataCollection["month"] as! Int)
                    noteData.setDate(dataCollection["date"] as! Int)
                    noteData.setDay(dataCollection["day"] as! String)
                    noteData.setWeather(dataCollection["weather"] as! String)
                    noteData.setTemperature(dataCollection["temperature"] as! Int)
                    noteData.setPhysicalCondition(dataCollection["physicalCondition"] as! String)
                    noteData.setPurpose(dataCollection["purpose"] as! String)
                    noteData.setDetail(dataCollection["detail"] as! String)
                    noteData.setTarget(dataCollection["target"] as! String)
                    noteData.setConsciousness(dataCollection["consciousness"] as! String)
                    noteData.setResult(dataCollection["result"] as! String)
                    noteData.setReflection(dataCollection["reflection"] as! String)
                    noteData.setTaskTitle(dataCollection["taskTitle"] as! [String])
                    noteData.setMeasuresTitle(dataCollection["measuresTitle"] as! [String])
                    noteData.setMeasuresEffectiveness(dataCollection["measuresEffectiveness"] as! [String])
                    noteData.setIsDeleted(dataCollection["isDeleted"] as! Bool)
                    noteData.setUserID(dataCollection["userID"] as! String)
                    noteData.setCreated_at(dataCollection["created_at"] as! String)
                    noteData.setUpdated_at(dataCollection["updated_at"] as! String)
                    
                    // 取得データを格納
                    self.noteDataArray.append(noteData)
                }
                // TargetDataとNoteDataのどちらが先にロードが終わるか不明なため、両方に記述
                // セクションデータを再構築
                self.reloadSectionData()
                
                // テーブルビューを更新
                self.tableView?.reloadData()
                
                // HUDで処理中を非表示
                SVProgressHUD.dismiss()
            }
        }
    }
    
    // データを取得するメソッド
    func reloadData() {
        // HUDで処理中を表示
        SVProgressHUD.show()
        
        // データ取得
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
    }
    
    // ノートデータを削除するメソッド
    func deleteNoteData(note noteData:NoteData) {
        // isDeletedをセット
        noteData.setIsDeleted(true)
        
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let data = db.collection("NoteData").document("\(userID)_\(noteData.getNoteID())")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "isDeleted"  : true,
            "updated_at" : getCurrentTime()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
                // 最後の削除であればリロード
                if self.deleteFinished == true {
                    self.deleteFinished = false
                    self.reloadData()
                }
            }
        }
    }
    
    // Firebaseのデータを更新するメソッド
    func updateTargetData(target targetData:TargetData) {
        // ユーザーIDを取得
        let userID = UserDefaults.standard.object(forKey: "userID") as! String
        
        // 更新日時を現在時刻にする
        targetData.setUpdated_at(getCurrentTime())
        
        // 更新したい課題データを取得
        let db = Firestore.firestore()
        let data = db.collection("TargetData").document("\(userID)_\(targetData.getYear())_\(targetData.getMonth())")

        // 変更する可能性のあるデータのみ更新
        data.updateData([
            "detail"     : targetData.getDetail(),
            "isDeleted"  : targetData.getIsDeleted(),
            "updated_at" : targetData.getUpdated_at()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
                // リロード
                self.reloadData()
            }
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // ナビゲーションバーボタンの宣言
    func createNavigationBarButton() {
        calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style:UIBarButtonItem.Style.plain, target:self, action: #selector(calendarButtonTapped(_:)))
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        deleteButton  = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
    }
    
    // ナビゲーションバーボタンをセットするメソッド
    func setNavigationBarButton(leftBar leftBarItems:[UIBarButtonItem],rightBar rightBarItems:[UIBarButtonItem]) {
        navigationItem.leftBarButtonItems  = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }
    
    // 利用規約表示メソッド
    func displayAgreement() {
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"利用規約の更新",message:"本アプリの利用規約とプライバシーポリシーに同意します。",preferredStyle:UIAlertController.Style.alert)
        
        // 同意ボタンを宣言
        let agreeAction = UIAlertAction(title:"同意する",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 同意ボタンがタップされたときの処理
            // 次回以降、利用規約を表示しないようにする
            UserDefaults.standard.set(true, forKey: "ver1.4")
        }
        
        // 利用規約ボタンを宣言
        let termsAction = UIAlertAction(title:"利用規約を読む",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 利用規約ボタンがタップされたときの処理
            let url = URL(string: "https://sportnote-b2c92.firebaseapp.com/")
            UIApplication.shared.open(url!)
            
            // アラートが消えるため再度表示
            self.displayAgreement()
        }
        
        // ボタンを追加
        alertController.addAction(termsAction)
        alertController.addAction(agreeAction)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
    // 広告表示を行うメソッド
    func displayAdMob() {
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
    
    // 初期化sectionTitle
    func sectionTitleInit() {
        self.sectionTitle = ["フリーノート"]
    }
    
    // 初期化dataInSection
    func dataInSectionInit() {
        // フリーノート用に0番目にはダミーデータを入れる
        let dummyNoteData = NoteData()
        self.dataInSection = [[]]
        self.dataInSection[0].append(dummyNoteData)
    }
    
    // sectionTitleとdataInSectionを再構成するメソッド
    func reloadSectionData() {
        // データ初期化
        self.sectionTitleInit()
        self.dataInSectionInit()
        
        // targetDataArrayが空の時は更新しない（エラー対策）
        if self.targetDataArray.isEmpty == false {
            // テーブルデータ更新
            for index in 0...(self.targetDataArray.count - 1) {
                // 年間目標と月間目標の区別
                if self.targetDataArray[index].getMonth() == 13 {
                    // 年間目標セクション追加
                    self.sectionTitle.append("\(self.targetDataArray[index].getYear())年:\(self.targetDataArray[index].getDetail())")
                    self.dataInSection.append([])
                } else {
                    // 月間目標セクション追加
                    self.sectionTitle.append("\(self.targetDataArray[index].getMonth())月:\(self.targetDataArray[index].getDetail())")
                    
                    // ノートデータ追加
                    var noteArray:[NoteData] = []
                    // noteDataArrayが空の時は更新しない（エラー対策）
                    if self.noteDataArray.isEmpty == false {
                        // 年,月が合致するノート数だけappendする。
                        for count in 0...(self.noteDataArray.count - 1) {
                            if self.noteDataArray[count].getYear() == self.targetDataArray[index].getYear()
                                && self.noteDataArray[count].getMonth() == self.targetDataArray[index].getMonth() {
                                noteArray.append(self.noteDataArray[count])
                            }
                        }
                    }
                    self.dataInSection.append(noteArray)
                }
            }
        }
    }
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
    }
    
}
