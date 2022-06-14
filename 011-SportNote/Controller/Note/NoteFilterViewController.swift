//
//  NoteFilterViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/15.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol NoteFilterViewControllerDelegate: AnyObject {
    // キャンセルボタンタップ時の処理
    func noteFilterVCCancelDidTap(_ viewController: NoteFilterViewController)
    // 適用ボタンタップ時の処理
    func noteFilterVCApplyDidTap(_ viewController: NoteFilterViewController)
}

class NoteFilterViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    var delegate: NoteFilterViewControllerDelegate?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Action
    @IBAction func tapCancelButton(_ sender: Any) {
        delegate?.noteFilterVCCancelDidTap(self)
    }
    
    @IBAction func tapClearButton(_ sender: Any) {
    }
    
    @IBAction func tapApplyButton(_ sender: Any) {
        delegate?.noteFilterVCApplyDidTap(self)
    }
    
}

extension NoteFilterViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
