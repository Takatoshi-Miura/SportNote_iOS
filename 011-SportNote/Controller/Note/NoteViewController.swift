//
//  NoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/02.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD

protocol NoteViewControllerDelegate: AnyObject {
}

class NoteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: NoteViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
