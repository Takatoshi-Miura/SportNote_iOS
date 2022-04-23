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
        
        // ナビゲーションバーのタイトルをセット
        setNavigationTitle(title: "ノート")
        
        // ナビゲーションバーのボタンを宣言
        createNavigationBarButton()
        
        // ナビゲーションバーのボタンを追加
        setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,listButton])
        
        // セルの複数選択を許可
        noteTableView.allowsMultipleSelectionDuringEditing = true
        
        // カスタムセルを登録
        noteTableView.register(UINib(nibName: "NoteViewCell", bundle: nil), forCellReuseIdentifier: "noteViewCell")
        
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
    var dataManager = DataManager()
    var cellDataArray:[Note_old] = []   // セルに表示するノートが格納される
    var selectIndex:Int = 0
    
    // フラグ
    var deleteFinished:Bool = false
    
    
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
            setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,deleteButton])
        } else {
            // 編集終了
            self.editButtonItem.title = "編集"
            
            // ナビゲーションバーに追加ボタンを表示
            setNavigationBarButton(leftBar: [editButtonItem], rightBar: [addButton,listButton])
        }
        // 編集モード時のみ複数選択可能とする
        noteTableView.isEditing = editing
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
        // ノート削除
        self.deleteRows()
    }
    
    
    
    //MARK:- テーブルビューの設定
    
    // セルの数を返却
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return 1    // フリーノートセルのみ
        } else {
            if cellDataArray.isEmpty == false {
                return self.cellDataArray.count     // 選択された日付に保存されているノート数
            } else {
                return 1                            // ノートはありませんセル用
            }
        }
    }
    
    // セル(表示内容)を返却
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            // フリーノートセルを返却
            let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "freeNoteCell", for: indexPath)
            cell.textLabel!.text = dataManager.freeNoteData.getTitle()
            cell.detailTextLabel!.text = dataManager.freeNoteData.getDetail()
            cell.detailTextLabel?.textColor = UIColor.systemGray
            return cell
        } else {
            // ノートセルを返却
            if cellDataArray.isEmpty == false {
                // ノートセルを返却
                let cell = tableView.dequeueReusableCell(withIdentifier: "noteViewCell", for: indexPath) as! NoteViewCell
                cell.printNoteData(cellDataArray[indexPath.row])
                return cell
            } else {
                let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
                cell.textLabel?.text = "ノートはありません"
                return cell
            }
        }
    }
    
    // セルの編集可否設定
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.tag == 0 {
            return false        // フリーノートは編集不可
        } else {
            if cellDataArray.isEmpty {
                return false    // ノートはありませんセルは編集不可
            } else {
                return true     // ノートセルは編集可能
            }
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
                if cellDataArray.isEmpty == false {
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
    }
    
    // 左スワイプの処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // 削除処理かどうかの判定
        if editingStyle == UITableViewCell.EditingStyle.delete {
            // OKボタンを宣言
            let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
                // ノートデータを削除
                self.deleteFinished = true
                self.deleteNoteData(note: self.cellDataArray[indexPath.row])
                self.cellDataArray.remove(at: indexPath.row)
            }
            // CANCELボタンを宣言
            let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
            showAlert(title: "ノートを削除", message: "\(self.dataManager.noteDataArray[indexPath.row].getCellTitle())\nを削除します。よろしいですか？", actions: [okAction,cancelAction])
        }
    }
    
    // 複数のセルを削除
    func deleteRows() {
        guard let selectedIndexPaths = self.noteTableView.indexPathsForSelectedRows else {
            return
        }
        // OKボタンを宣言
        let okAction = UIAlertAction(title:"削除",style:UIAlertAction.Style.destructive){(action:UIAlertAction)in
            // 配列の要素削除で、indexのずれを防ぐため、降順にソートする
            let sortedIndexPaths =  selectedIndexPaths.sorted { $0.row > $1.row }
               
            for num in sortedIndexPaths {
                // 最後の削除であればフラグをtrueにする
                if num == sortedIndexPaths.last {
                    self.deleteFinished = true
                    // 選択されたノートを削除
                    self.deleteNoteData(note: self.cellDataArray[num.row])
                    self.cellDataArray.remove(at: num.row)
                    
                    // 編集状態を解除
                    self.setEditing(false, animated: true)
                } else {
                    // 選択されたノートを削除
                    self.deleteNoteData(note: self.cellDataArray[num.row])
                    self.cellDataArray.remove(at: num.row)
                }
            }
        }
        // CANCELボタンを宣言
        let cancelAction = UIAlertAction(title:"キャンセル",style:UIAlertAction.Style.cancel,handler:nil)
        showAlert(title: "ノートを削除", message: "選択されたノートを削除します。\nよろしいですか？", actions: [okAction,cancelAction])
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
        formatter.dateFormat = "yyyy/M/d"
        let da = formatter.string(from: date)
        
        // ノートデータがある日付のセルを色付け
        for noteData in self.dataManager.noteDataArray {
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
        formatter.dateFormat = "yyyy/M/d"
        let da = formatter.string(from: date)
        for noteData in self.dataManager.noteDataArray {
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
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.label     // 平日は黒
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.label
        
        return UIColor.label
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
        for targetData in dataManager.targetDataArray {
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
        self.calendar.appearance.headerDateFormat = "YYYY年 M月\n\(monthTarget)"
    }
    
    
    //MARK:- 画面遷移
    
    // 画面遷移時に呼ばれる処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goFreeNoteView" {
            // フリーノートデータを渡す
            let freeNoteViewController = segue.destination as! FreeNoteViewController_old
            freeNoteViewController.dataManager.freeNoteData = dataManager.freeNoteData
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
    
    
    //MARK:- データベース関連
    
    // データを取得するメソッド
    func reloadData() {
        // データ取得
        loadFreeNoteData()
        loadTargetData()
        loadNoteData()
    }
    
    // Firebaseからフリーノートデータを読み込むメソッド
    func loadFreeNoteData() {
        dataManager.getFreeNoteData({})
    }
    
    // Firebaseから目標データを取得するメソッド
    func loadTargetData() {
        dataManager.getTargetData({
            // カレンダーのヘッダーに目標をセット
            self.printTarget()
            // テーブルビューを更新
            self.tableView?.reloadData()
            self.calendar.reloadData()
        })
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData() {
        dataManager.getNoteData({
            // テーブルビューを更新
            self.tableView?.reloadData()
            self.noteTableView.reloadData()
            self.calendar.reloadData()
        })
    }
    
    // Firebaseからデータを取得するメソッド
    func loadNoteData(year selectYear:Int,month selectMonth:Int,date selectDate:Int) {
        dataManager.getNoteData(selectYear, selectMonth, selectDate, {
            self.cellDataArray = self.dataManager.noteDataArray
            self.noteTableView?.reloadData()
        })
    }
    
    // ノートデータを削除するメソッド
    func deleteNoteData(note noteData:Note_old) {
        dataManager.deleteNoteData(noteData, {
            // 最後の削除であればリロード
            if self.deleteFinished {
                self.deleteFinished = false
                self.reloadData()
            }
        })
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
    
    // ナビゲーションタイトルをセット
    func setNavigationTitle(title titleText:String) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .center
        label.text = titleText
        self.navigationItem.titleView = label
    }
    
    // ナビゲーションバーボタンを宣言
    func createNavigationBarButton() {
        listButton   = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style:UIBarButtonItem.Style.plain, target: self, action: #selector(listButtonTapped(_:)))
        addButton    = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteButtonTapped(_:)))
    }
    
    // ナビゲーションバーボタンをセットするメソッド
    func setNavigationBarButton(leftBar leftBarItems:[UIBarButtonItem],rightBar rightBarItems:[UIBarButtonItem]) {
        navigationItem.leftBarButtonItems  = leftBarItems
        navigationItem.rightBarButtonItems = rightBarItems
    }

}
