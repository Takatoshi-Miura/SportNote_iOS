//
//  AddPracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/27.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol AddPracticeNoteViewControllerDelegate: AnyObject {
    // モーダルを閉じる時の処理
    func addPracticeNoteVCDismiss(_ viewController: UIViewController)
}

class AddPracticeNoteViewController: UIViewController {
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var purposeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var reflectionLabel: UILabel!
    @IBOutlet weak var conditionTextView: UITextView!
    @IBOutlet weak var purposeTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var dateTableView: UITableView!
    @IBOutlet weak var taskTableView: UITableView!
    var delegate: AddPracticeNoteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func tapAddButton(_ sender: Any) {
    }
    
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.addPracticeNoteVCDismiss(self)
    }
    
    @IBAction func tapSaveButton(_ sender: Any) {
    }
    
}

extension AddPracticeNoteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
