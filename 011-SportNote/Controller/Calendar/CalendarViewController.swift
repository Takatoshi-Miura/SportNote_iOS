//
//  CalendarViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/03.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD
import FSCalendar
import CalculateCalendarLogic

protocol CalendarViewControllerDelegate: AnyObject {
    // 目標追加ボタンタップ時
    func calendarVCAddTargetDidTap(_ viewController: UIViewController)
    // 練習ノートタップ時
    func calendarVCPracticeNoteDidTap(practiceNote: Note)
    // 大会ノートタップ時
    func calendarVCTournamentNoteDidTap(tournamentNote: Note)
}

class CalendarViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var yearlyTargetLabel: UILabel!
    @IBOutlet weak var monthlyTargetLabel: UILabel!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    private var noteArray: [Note] = []
    private var selectedNoteArray: [Note] = []
    var delegate: CalendarViewControllerDelegate?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initTableView()
        syncData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
        calendar.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleSelectedCell()
        refreshData()
    }
    
    // MARK: - Other Methods
    
    /// 画面初期化
    private func initView() {
        self.title = TITLE_TARGET
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(tapRefreshButton(_:)))
        let todayButton = UIBarButtonItem(title: TITLE_TODAY, style: .plain, target: self, action: #selector(tapTodayButton(_:)))
        navigationItem.leftBarButtonItems = [refreshButton]
        navigationItem.rightBarButtonItems = [todayButton]
        printTarget()
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
        self.adView.addSubview(adMobView!)
    }
    
    /// データの同期処理
    @objc func syncData() {
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            Task {
                let syncManager = SyncManager()
                await syncManager.syncDatabase()
                self.refreshData()
                HUD.hide()
            }
        } else {
            refreshData()
        }
    }
    
    /// データを取得
    @objc func refreshData() {
        DispatchQueue.main.async {
            let realmManager = RealmManager()
            self.noteArray = realmManager.getPracticeTournamentNote()
            self.calendar.reloadData()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Action
    
    /// 追加ボタンの処理
    @IBAction func tapAddButton(_ sender: Any) {
        self.delegate?.calendarVCAddTargetDidTap(self)
    }
    
    /// 更新ボタンの処理
    @objc func tapRefreshButton(_ sender: UIBarButtonItem) {
        syncData()
    }
    
    /// 「今日」ボタンの処理
    @objc func tapTodayButton(_ sender: UIBarButtonItem) {
        calendar.select(Date())
        // 選択された日付のノートを取得
        let realmManager = RealmManager()
        selectedNoteArray = realmManager.getNote(date: Date())
        tableView.reloadData()
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    /// 日付がタップされた時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 選択された日付のノートを取得
        let realmManager = RealmManager()
        selectedNoteArray = realmManager.getNote(date: date)
        tableView.reloadData()
    }
    
    /// ノートが存在する日付のセルを色付ける
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d (E)"
        let da = formatter.string(from: date)
        
        // ノートデータがある日付のセルを色付け
        for note in noteArray {
            if da == formatDate(date: note.date, format: "yyyy/M/d (E)") {
                if note.noteType == NoteType.practice.rawValue {
                    return UIColor.systemGreen
                } else {
                    return UIColor.systemRed
                }
            }
        }
        return nil
    }
    
    /// カレンダーをフリックした時の処理
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        printTarget()
    }
    
    /// 現在のページの年月目標を取得＆ラベル表示
    func printTarget() {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let year = Int(yearFormatter.string(from: calendar.currentPage))!
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "M"
        let month = Int(monthFormatter.string(from: calendar.currentPage))!
        
        let realmManager = RealmManager()
        
        if let yearlyTarget = realmManager.getTarget(year: year) {
            yearlyTargetLabel.text = "\(TITLE_YEARLY)\(yearlyTarget.title)"
        } else {
            yearlyTargetLabel.text = "\(TITLE_YEARLY)\(MESSAGE_TARGET_EMPTY)"
        }
        
        if let monthlyTarget = realmManager.getTarget(year: year, month: month, isYearlyTarget: false) {
            monthlyTargetLabel.text = "\(TITLE_MONTHLY)\(monthlyTarget.title)"
        } else {
            monthlyTargetLabel.text = "\(TITLE_MONTHLY)\(MESSAGE_TARGET_EMPTY)"
        }
    }
    
    /// 日付の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // ノートがある日付（白色）
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d (E)"
        let da = formatter.string(from: date)
        for note in noteArray {
            if da == formatDate(date: note.date, format: "yyyy/M/d (E)") {
                return UIColor.white
            }
        }
        
        // 今日（白色）
        let now = Date()
        if da == formatter.string(from: now) {
            return UIColor.white
        }
        
        // 祝日判定（祝日は赤色）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        // 土日の判定（土曜日は青色、日曜日は赤色）
        let weekday = self.getWeekIdx(date)
        if weekday == WeekDay.sunday.rawValue {
            return WeekDay.sunday.color
        } else if weekday == WeekDay.saturday.rawValue {
            return WeekDay.saturday.color
        }
        
        // 曜日ラベルの色,文字列を変更
        for index in 0...6 {
            calendar.calendarWeekdayView.weekdayLabels[index].textColor = WeekDay.allCases[index].color
            calendar.calendarWeekdayView.weekdayLabels[index].text = WeekDay.allCases[index].title
        }
        
        return nil
    }
    
    /// 祝日判定
    /// - Parameters:
    ///     - date: 日付
    /// - Returns: true→祝日、false→祝日以外
    private func judgeHoliday(_ date : Date) -> Bool {
        let tmpCalendar = Calendar(identifier: .gregorian)
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
    }
    
    /// 曜日判定
    /// - Parameters:
    ///     - date: 日付
    /// - Returns: 曜日番号
    private func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// TableView初期化
    private func initTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "NoteCell", bundle: nil), forCellReuseIdentifier: "NoteCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
    
    /// 選択されたセルの更新
    private func handleSelectedCell() {
        if let selectedIndex = tableView.indexPathForSelectedRow {
            // ノートが削除されていれば取り除く
            let note = selectedNoteArray[selectedIndex.row]
            if note.isDeleted {
                selectedNoteArray.remove(at: selectedIndex.row)
                tableView.reloadData()
                return
            }
            tableView.reloadRows(at: [selectedIndex], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedNoteArray.isEmpty {
            return 1
        } else {
            return selectedNoteArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedNoteArray.isEmpty {
            return 44
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedNoteArray.isEmpty {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = MESSAGE_EMPTY_NOTE
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
            cell.printInfo(note: selectedNoteArray[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedNoteArray.isEmpty {
            tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        } else {
            let note = selectedNoteArray[indexPath.row]
            if note.noteType == NoteType.practice.rawValue {
                delegate?.calendarVCPracticeNoteDidTap(practiceNote: note)
            } else {
                delegate?.calendarVCTournamentNoteDidTap(tournamentNote: note)
            }
        }
    }
    
}
