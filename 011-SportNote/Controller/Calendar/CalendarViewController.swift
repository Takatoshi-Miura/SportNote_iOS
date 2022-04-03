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
    var delegate: CalendarViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
    }
    
    func initNavigationController() {
        self.title = TITLE_CALENDAR
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
