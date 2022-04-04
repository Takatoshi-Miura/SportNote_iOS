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
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var adView: UIView!
    private var adMobView: GADBannerView?
    var syncManager = SyncManager()
    var relamManager = RealmManager()
    
    var taskArray: [Task] = []
    var measuresArray: [Measures] = []
    var memoArray: [Memo] = []
    var targetArray: [Target] = []
    var freeNote = FreeNote()
    var noteArray: [Any] = []
    
    var delegate: NoteViewControllerDelegate?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavigationController()
        if Network.isOnline() {
            HUD.show(.labeledProgress(title: "", subtitle: MESSAGE_SERVER_COMMUNICATION))
            // 旧データを新データに変換
            syncManager.convertOldDataToNew(completion: {
                // 新データをRealmに保存(確実に成功するまで繰り返し)
                var result = false
                repeat {
                    result = self.syncManager.createRealmWithUpdate()
                } while result == false
                
                self.noteArray.append(contentsOf: self.relamManager.getAllPracticeNote())
                self.noteArray.append(contentsOf: self.relamManager.getAllTournamentNote())
                self.tableView.reloadData()
                HUD.hide()
            })
        } else {
            
        }
        
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
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
        let addTargetAction = UIAlertAction(title: TITLE_TARGET, style: .default) { _ in
//            self.delegate?.taskVCAddGroupDidTap(self)
        }
        let addPracticeNoteAction = UIAlertAction(title: TITLE_PRACTICE_NOTE, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        let addTournamentNoteAction = UIAlertAction(title: TITLE_TOURNAMENT_NOTE, style: .default) { _ in
//            self.delegate?.taskVCAddTaskDidTap(self)
        }
        alertActions.append(addTargetAction)
        alertActions.append(addPracticeNoteAction)
        alertActions.append(addTournamentNoteAction)
        
        showActionSheet(title: TITLE_ADD_TARGET_NOTE_TASK,
                        message: MESSAGE_ADD_TARGET_NOTE_TASK,
                        actions: alertActions,
                        frame: addButton.frame)
    }
    
}

extension NoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noteArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        if !noteArray.isEmpty {
            if noteArray[indexPath.row] is PracticeNote {
                cell.textLabel?.text = PracticeNote(value: noteArray[indexPath.row]).detail
            } else {
                cell.textLabel?.text = TournamentNote(value: noteArray[indexPath.row]).target
            }
        }
        return cell
    }
    
}
