//
//  TaskViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/01.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PKHUD

protocol TaskViewControllerDelegate: AnyObject {
    // グループ追加タップ時の処理
    func taskVCAddGroupDidTap(_ viewController: UIViewController)
}

class TaskViewController: UIViewController {
    
    // MARK: UI,Variable
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    var delegate: TaskViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
    }
    
    func initNavigationController() {
        self.title = TITLE_TASK
        
        let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(openSettingView(_:)))
        navigationItem.rightBarButtonItems = [settingButton]
    }
    
    @objc func openSettingView(_ sender: UIBarButtonItem) {
//        self.delegate?.taskVCHumburgerMenuButtonDidTap(self)
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
    
    @IBAction func tapAddButton(_ sender: Any) {
        var alertActions: [UIAlertAction] = []
        let addGroupAction = UIAlertAction(title: TITLE_GROUP, style: .default) { _ in
            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addTaskAction = UIAlertAction(title: TITLE_TASK, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        alertActions.append(addGroupAction)
        alertActions.append(addTaskAction)
        
        showActionSheet(title: TITLE_ADD_GROUP_TASK,
                        message: MESSAGE_ADD_GROUP_TASK,
                        actions: alertActions,
                        frame: addButton.frame)
    }
    
}

extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
