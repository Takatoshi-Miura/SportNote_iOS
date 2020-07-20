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

class NoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // デリゲートとデータソースの指定
        tableView.delegate = self
        tableView.dataSource = self
    
        // 編集ボタンの設定(複数選択可能)
        tableView.allowsMultipleSelectionDuringEditing = true
        navigationItem.leftBarButtonItem = editButtonItem
        
        // データのないセルを非表示
        self.tableView.tableFooterView = UIView()
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
    var sectionIndex:Int = 0
    var rowIndex:Int = 0
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    
    // ＋ボタンの処理
    @IBAction func addButton(_ sender: Any) {
        // ノート追加画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddViewController")
        self.present(nextView, animated: true, completion: nil)
    }
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            // 編集開始
            self.editButtonItem.title = "完了"
            self.editButtonItem.tintColor = UIColor.systemBlue
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            self.editButtonItem.tintColor = UIColor.systemBlue
            self.deleteRows()
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
        tableView.reloadData()
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
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for:indexPath)
                cell.textLabel?.text       = dataInSection[indexPath.section][indexPath.row].getCellTitle()
                cell.detailTextLabel?.text = dataInSection[indexPath.section][indexPath.row].getNoteType()
                if dataInSection[indexPath.section][indexPath.row].getNoteType() == "練習記録" {
                    cell.detailTextLabel?.textColor = UIColor.systemGreen
                } else {
                    cell.detailTextLabel?.textColor = UIColor.systemRed
                }
                return cell
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
        // 編集時の処理
        if tableView.isEditing {
            // 選択肢にチェックが一つでも入ってたら「削除」を表示する。
            if let _ = self.tableView.indexPathsForSelectedRows {
                self.editButtonItem.title = "削除"
                self.editButtonItem.tintColor = UIColor.systemRed
            }
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
                    performSegue(withIdentifier: "goNoteDetailViewController", sender: nil)
                } else {
                    // 大会ノートセル
                    performSegue(withIdentifier: "goCompetitionNoteDetailViewController", sender: nil)
                }
            }
        }
    }
    
    // 複数のセルを削除
    private func deleteRows() {
        
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"ノートを削除",message:"選択されたノートを削除します。よろしいですか？",preferredStyle:UIAlertController.Style.alert)
        
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // OKボタンがタップされたときの処理
            
            // 配列の要素削除で、indexの矛盾を防ぐため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
            for num in 0...sortedIndexPaths.count - 1 {
                // 選択されたノートを削除
                self.dataInSection[sortedIndexPaths[num][0]][sortedIndexPaths[num][1]].setIsDeleted(true)
                self.dataInSection[sortedIndexPaths[num][0]][sortedIndexPaths[num][1]].updateNoteData()
            }
            
            for _ in 0...sortedIndexPaths.count - 1 {
                // セルの個数を揃える(上記のループ内にまとめると削除が正常に完了しないため、このループに記述)
                self.dataInSection[sortedIndexPaths[0][0]].remove(at: 0)
            }
            
            // tableViewの行を削除
            self.tableView.deleteRows(at: sortedIndexPaths, with: UITableView.RowAnimation.automatic)
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
                // 次回以降、このノートデータを取得しないようにする
                self.dataInSection[indexPath.section][indexPath.row].setIsDeleted(true)
                self.dataInSection[indexPath.section][indexPath.row].updateNoteData()
                    
                // セルのみを削除(セクションは残す)
                self.dataInSection[indexPath.section].remove(at:indexPath.row)
                    
                // セルを削除
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
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
        let view = UIView(frame: CGRect.zero)
        
        if section == 0 {
            // フリーノートセクションは削除不可
            // セクションラベルの設定
            let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 30))
            label.text = "   \(sectionTitle[section])"
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.systemGray5
            label.textColor =  UIColor.black
            view.addSubview(label)
        } else {
            // セクションラベルの設定
            let label = UILabel(frame: CGRect(x:0, y:0, width: tableView.bounds.width, height: 30))
            label.text = "   \(sectionTitle[section])"
            label.textAlignment = NSTextAlignment.left
            label.backgroundColor = UIColor.systemGray5
            label.textColor =  UIColor.black
            view.addSubview(label)
            
            // 編集時の表示
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
            self.targetDataArray[self.sectionIndex - 1].updateTargetData()
            self.reloadData()
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
        } else if segue.identifier == "goNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! NoteDetailViewController
            noteDetailViewController.noteData = dataInSection[sectionIndex][rowIndex]
        } else if segue.identifier == "goCompetitionNoteDetailViewController" {
            // 表示するデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! CompetitionNoteDetailViewController
            noteDetailViewController.noteData = dataInSection[sectionIndex][rowIndex]
        }
    }
    
    // NoteViewControllerに戻ったときの処理
    @IBAction func goToNoteViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- その他のメソッド
    
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
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        // ユーザーUIDをセット
        freeNoteData.setUserID(Auth.auth().currentUser!.uid)
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーのフリーノートデータを取得する
        db.collection("FreeNoteData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
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
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーの目標データを取得する
        db.collection("TargetData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
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
        
        // Firebaseにアクセス
        let db = Firestore.firestore()
        
        // 現在のユーザーのデータを取得する
        db.collection("NoteData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
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
    
}
