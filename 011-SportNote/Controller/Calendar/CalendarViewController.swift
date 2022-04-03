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

protocol CalendarViewControllerDelegate: AnyObject {
}

class CalendarViewController: UIViewController {
    
    var delegate: CalendarViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
    }
    
    func initNavigationController() {
        self.title = TITLE_CALENDAR
    }
    
}
