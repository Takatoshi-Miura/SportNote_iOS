//
//  calendarViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/29.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit
import Firebase
import FSCalendar
import CalculateCalendarLogic

class calendarViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ナビゲーションバーのタイトル
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center
        label.text = "ノート"
        self.navigationItem.titleView = label
        
        // ナビゲーションバーのボタンを宣言
        listButton   = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style:UIBarButtonItem.Style.plain, target: self, action: #selector(listButtonTapped(_:)))
        addButton    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
        editButtonItem.title = "編集"
        
        // ナビゲーションバーのボタンを追加
        navigationItem.leftBarButtonItem   = editButtonItem
        navigationItem.rightBarButtonItems = [addButton,listButton]
        
        // セルの複数選択を許可
        noteTableView.allowsMultipleSelectionDuringEditing = true
        
        // データのないセルを非表示
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // データの読み込み
        reloadData()
    }
    
    
    
    //MARK:- 変数の宣言
    
    // ナビゲーションバー用のボタン
    var listButton:UIBarButtonItem!     // リストボタン
    var addButton:UIBarButtonItem!      // 追加ボタン
    var deleteButton:UIBarButtonItem!   // ゴミ箱ボタン
    
    // テーブル用
    var freeNoteData = FreeNote()       // フリーノートデータ
    var noteDataArray:[NoteData] = []   // セルに表示するデータを格納する配列
    var targetDataArray = [TargetData]()
    
    
    
    //MARK:- UIの設定
    
    // テーブルビュー
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noteTableView: UITableView!
    
    // カレンダー
    @IBOutlet weak var calendar: FSCalendar!
    
    // 編集ボタンの処理
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            // 編集開始
            self.editButtonItem.title = "完了"
            
            // ナビゲーションバーに追加ボタン,ゴミ箱ボタンを表示
            self.navigationItem.rightBarButtonItems = [addButton,deleteButton]
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            
            // ナビゲーションバーに追加ボタンを表示
            self.navigationItem.rightBarButtonItems = [addButton,listButton]
        }
        // 編集モード時のみ複数選択可能とする
        tableView.isEditing = editing
    }
    
    // リストボタンの処理
    @objc func listButtonTapped(_ sender: UIBarButtonItem) {
        // ノート画面に遷移
        self.navigationController?.popViewController(animated: false)
    }
    
    // ノート追加ボタンの処理
    @objc func addButtonTapped(_ sender: UIBarButtonItem) {
        // ノート追加画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddViewController")
        self.present(nextView, animated: true, completion: nil)
    }
    
    // ゴミ箱ボタンの処理
    @objc func deleteButtonTapped(_ sender: UIBarButtonItem) {
        // 選択要素のIndexを降順にソートする
        guard let selectedIndexPaths = self.tableView.indexPathsForSelectedRows else {
            return
        }
        let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
        
        // Indexの大きいデータから順に削除
        for indexPathList in sortedIndexPaths {
            self.noteDataArray.remove(at: indexPathList.row)
            self.tableView.deleteRows(at: [indexPathList], with: UITableView.RowAnimation.right)
        }
        
        // データを保存
        self.saveData()
        
        // 編集状態を解除
        self.setEditing(false, animated: true)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルの数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return 1    // フリーノートセルのみ
        } else {
            return self.noteDataArray.count     // 選択された日付に保存されているノート数
        }
    }
    
    // セル(表示内容)を返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            // フリーノートセルを返却
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
            cell.textLabel!.text = freeNoteData.getTitle()
            cell.detailTextLabel!.text = freeNoteData.getDetail()
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else {
            // ノートセルを返却
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for:indexPath)
            //cell.textLabel?.text       = dataInSection[indexPath.section][indexPath.row].getCellTitle()
            //cell.detailTextLabel?.text = dataInSection[indexPath.section][indexPath.row].getNoteType()
//            if dataInSection[indexPath.section][indexPath.row].getNoteType() == "練習記録" {
//                cell.detailTextLabel?.textColor = UIColor.systemGreen
//            } else {
//                cell.detailTextLabel?.textColor = UIColor.systemRed
//            }
            return cell
        }
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return false    // フリーノートは編集不可
        } else {
            return true     // ノートセルは編集可能
        }
    }
    
    // セルをタップした時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // 編集時の処理
            
        } else {
            // 通常時の処理
            if tableView.tag == 0 {
                // フリーノート確認画面へ遷移
                performSegue(withIdentifier: "goFreeNoteView", sender: nil)
            }
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        }
    }
    
    // 左スワイプの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // dataArrayとテーブルから削除
            self.noteDataArray.remove(at:indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.right)
            
            // データを保存
            self.saveData()
        }
    }
    
    
    
    //MARK:- カレンダーの設定
    
    // 祝日判定を行い結果を返すメソッド(True:祝日)
    func judgeHoliday(_ date : Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    // date型 -> 年月日をIntで取得
    func getDay(_ date:Date) -> (Int,Int,Int){
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        return (year,month,day)
    }

    // 曜日判定(日曜日:1 〜 土曜日:7)
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    // 土日や祝日の日の文字色を変えるメソッド
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        //祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }

        //土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {   //日曜日
            return UIColor.red
        }
        else if weekday == 7 {  //土曜日
            return UIColor.blue
        }
        
        // ラベルの色を変更
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red       // 日曜日は赤
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.black     // 平日は黒
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.black
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.black
        
        return nil
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteView" {
            // フリーノートデータを渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController
            freeNoteViewController.freeNoteData = self.freeNoteData
        }
    }
    
    
    //MARK:- その他のメソッド

    // データをUserDefaultsに保存するメソッド
    func saveData() {
        let userDefaults = UserDefaults.standard
        userDefaults.set(self.noteDataArray,forKey:"dataArray")
        userDefaults.synchronize()
    }
    
    // データを取得するメソッド
    func reloadData() {
        // データ取得
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
    }
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        // ユーザーUIDをセット
        freeNoteData.setUserID(Auth.auth().currentUser!.uid)
        
        // 現在のユーザーのフリーノートデータを取得する
        let db = Firestore.firestore()
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

        // 現在のユーザーの目標データを取得する
        let db = Firestore.firestore()
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
                //self.reloadSectionData()
                
                // テーブルビューを更新
                self.tableView?.reloadData()
            }
        }
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        // noteDataArrayを初期化
        noteDataArray = []

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
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
                //self.reloadSectionData()
                
                // テーブルビューを更新
                self.tableView?.reloadData()
            }
        }
    }
    

}
