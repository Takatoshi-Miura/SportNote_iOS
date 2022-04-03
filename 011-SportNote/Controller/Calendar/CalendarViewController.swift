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
}

class CalendarViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    var delegate: CalendarViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
    }
    
    func initNavigationController() {
        self.title = TITLE_CALENDAR
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showAdMob()
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
        self.adView.addSubview(adMobView!)
    }
    
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    enum WeekDay: Int {
        case sunday = 1
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
    
    /// 日付がタップされた時の処理
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        print("\(year) / \(month) / \(day)")
    }
    
    /// 土日や祝日の日の文字色を変える
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        // 祝日判定（祝日は赤色で表示する）
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        // 土日の判定（土曜日は青色、日曜日は赤色で表示する）
        let weekday = self.getWeekIdx(date)
        if weekday == WeekDay.sunday.rawValue {
            return UIColor.red
        } else if weekday == WeekDay.saturday.rawValue {
            return UIColor.blue
        }
        
        // 曜日ラベルの色を変更
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor.red
        calendar.calendarWeekdayView.weekdayLabels[1].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[2].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[3].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[4].textColor = UIColor.label
        calendar.calendarWeekdayView.weekdayLabels[5].textColor = UIColor.label
        
        // 曜日ラベルの文字列を変更
        calendar.calendarWeekdayView.weekdayLabels[0].text = "Sun"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "Mon"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "Tue"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "Wed"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "Thu"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "Fri"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "Sat"
        
        return nil
    }
    
    /// 祝日判定
    /// - Parameters:
    ///     - date: 日付
    /// - Returns: true→祝日、false→祝日以外
    func judgeHoliday(_ date : Date) -> Bool {
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
    func getWeekIdx(_ date: Date) -> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "ノートがありません。"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
