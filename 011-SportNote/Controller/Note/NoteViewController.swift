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
    @IBOutlet weak var adVIew: UIView!
    var syncManager = SyncManager()
    
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
        syncManager.convertOldDataToNew({
            self.taskArray = self.syncManager.taskArray
            self.measuresArray = self.syncManager.measuresArray
            self.memoArray = self.syncManager.memoArray
            self.targetArray = self.syncManager.targetArray
            self.freeNote = self.syncManager.freeNote
            self.noteArray = self.syncManager.noteArray
            self.tableView.reloadData()
        })
    }
    
    func initNavigationController() {
        self.title = TITLE_NOTE
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
