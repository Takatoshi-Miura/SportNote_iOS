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
        noteTableView.tableFooterView = UIView()
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
    var noteDataArray:[NoteData] = []   // ノートデータ
    var cellDataArray:[NoteData] = []   // セルに表示するノートが格納される
    var targetDataArray = [TargetData]()
    var selectIndex:Int = 0
    
    
    
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
        
        
        // 編集状態を解除
        self.setEditing(false, animated: true)
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルの数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return 1    // フリーノートセルのみ
        } else {
            return self.cellDataArray.count     // 選択された日付に保存されているノート数
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
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
            if cellDataArray.isEmpty == false {
                cell.textLabel?.text       = cellDataArray[indexPath.row].getCellTitle()
                cell.detailTextLabel?.text = cellDataArray[indexPath.row].getNoteType()
                if cellDataArray[indexPath.row].getNoteType() == "大会記録" {
                    cell.detailTextLabel?.textColor = UIColor.systemRed
                } else {
                    cell.detailTextLabel?.textColor = UIColor.systemGreen
                }
            }
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
            // タップしたときの選択色を消去
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            if tableView.tag == 0 {
                // フリーノート確認画面へ遷移
                performSegue(withIdentifier: "goFreeNoteView", sender: nil)
            } else {
                // indexを取得
                self.selectIndex = indexPath.row
                
                // ノート確認画面へ遷移
                if cellDataArray[indexPath.row].getNoteType() == "練習記録" {
                    // 練習ノートセル
                    performSegue(withIdentifier: "goPracticeNoteDetailView", sender: nil)
                } else {
                    // 大会ノートセル
                    performSegue(withIdentifier: "goCompetitionNoteDetailView", sender: nil)
                }
            }
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
            
        }
    }
    
    
    
    //MARK:- カレンダーの設定
    
    // カレンダーをフリックした時の処理
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // カレンダーのヘッダーに目標をセット
        printTarget()
    }
    
    // 日付がタップされた時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択された日付を取得
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        
        // その日付のノートデータを取得し、cellDataに格納
        loadNoteData(year: year, month: month, date: day)
    }
    
    // ノートデータが存在する日付のセルを色付けるメソッド
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/dd"
        let da = formatter.string(from: date)
        
        // ノートデータがある日付のセルを色付け
        for noteData in self.noteDataArray {
            if da == "\(String(noteData.getYear()))/\(String(noteData.getMonth()))/\(String(noteData.getDate()))" {
                if noteData.getNoteType() == "練習記録" {
                    return UIColor.systemGreen
                } else if noteData.getNoteType() == "大会記録" {
                    return UIColor.systemRed
                }
            }
        }
        return nil
    }
    
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
        // ノートデータがある日付の数値を色付け
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/dd"
        let da = formatter.string(from: date)
        for noteData in self.noteDataArray {
            if da == "\(String(noteData.getYear()))/\(String(noteData.getMonth()))/\(String(noteData.getDate()))" {
                return UIColor.white
            }
        }
        
        // 今日の日付
        let now = Date()
        if da == formatter.string(from: now) {
            return UIColor.white
        }
        
        // 祝日判定をする（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        // 土日の判定を行う（土曜日は青色、日曜日は赤色で表示する）
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
    
    // カレンダーのヘッダーに目標を表示するメソッド
    func printTarget() {
        // 文字列の宣言
        var yearTarget:String  = ""
        var monthTarget:String = ""
        
        // フォーマットの宣言
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "yyyy/M"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        // 目標データの存在確認
        for targetData in targetDataArray {
            if monthFormatter.string(from: calendar.currentPage) == targetData.getYearMonth() {
                // 月間目標データがあれば文字列に登録
                monthTarget = "\(targetData.getDetail())"
            }
            if yearFormatter.string(from: calendar.currentPage) == String(targetData.getYear()) && targetData.getMonth() == 13 {
                // 年間目標データがあれば文字列に登録
                yearTarget = "\(targetData.getDetail())"
            }
        }
        
        // カレンダーのヘッダーに目標データを表示
        self.calendar.appearance.headerDateFormat = "YYYY年:\(yearTarget)\nM月:\(monthTarget)"
    }
    
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteView" {
            // フリーノートデータを渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController
            freeNoteViewController.freeNoteData = self.freeNoteData
        } else if segue.identifier == "goPracticeNoteDetailView" {
            // 練習ノートデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! PracticeNoteDetailViewController
            noteDetailViewController.noteData = cellDataArray[selectIndex]
        } else if segue.identifier == "goCompetitionNoteDetailView" {
            // 大会ノートデータを確認画面へ渡す
            let noteDetailViewController = segue.destination as! CompetitionNoteDetailViewController
            noteDetailViewController.noteData = cellDataArray[selectIndex]
        }
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 現在時刻を取得するメソッド
    func getCurrentTime() -> String {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: now)
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
                // カレンダーのヘッダーに目標をセット
                self.printTarget()
                
                // テーブルビューを更新
                self.tableView?.reloadData()
                self.calendar.reloadData()
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
                
                // テーブルビューを更新
                self.tableView?.reloadData()
                self.calendar.reloadData()
            }
        }
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData(year selectYear:Int,month selectMonth:Int,date selectDate:Int) {
        // cellDataArrayを初期化
        cellDataArray = []

        // 現在のユーザーのデータを取得する
        let db = Firestore.firestore()
        db.collection("NoteData")
            .whereField("userID", isEqualTo: Auth.auth().currentUser!.uid)
            .whereField("isDeleted", isEqualTo: false)
            .whereField("year", isEqualTo: selectYear)
            .whereField("month", isEqualTo: selectMonth)
            .whereField("date", isEqualTo: selectDate)
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
                    self.cellDataArray.append(noteData)
                }
                
                // テーブルビューを更新
                self.noteTableView?.reloadData()
            }
        }
    }
    

}
