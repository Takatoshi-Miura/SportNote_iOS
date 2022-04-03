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
