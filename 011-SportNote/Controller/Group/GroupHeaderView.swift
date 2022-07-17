//
//  GroupHeaderView.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/04/10.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

protocol GroupHeaderViewDelegate: AnyObject {
    // ヘッダーをタップ時の処理
    func headerDidTap(view: GroupHeaderView)
    // infoボタンをタップ時の処理
    func infoButtonDidTap(view: GroupHeaderView)
}

class GroupHeaderView: UITableViewHeaderFooterView {

    // MARK: UI,Variable
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    var group = Group()
    var delegate: GroupHeaderViewDelegate?
    
    // MARK: LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = .systemGray6
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerViewDidTap(sender:))))
    }
    
    // MARK: - Action
    
    /// infoボタンの処理
    @IBAction func tapInfoButton(_ sender: Any) {
        self.delegate?.infoButtonDidTap(view: self)
    }
    
    /// headerViewタップ時の処理
    @objc func headerViewDidTap(sender: UITapGestureRecognizer) {
        self.delegate?.headerDidTap(view: self)
    }
    
    /// 情報表示
    /// - Parameters:
    ///    - group: グループ
    func printInfo(group: Group) {
        self.group = group
        imageView.backgroundColor = Color.allCases[group.color].color
        titleLabel.text = group.title
        infoButton.tintColor = .systemBlue
    }

}
