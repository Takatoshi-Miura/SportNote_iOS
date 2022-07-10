//
//  NoteCell.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/07/09.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {
    
    // MARK: - UI,Variable
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabelTop: NSLayoutConstraint!
    
    // MARK: - LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    /// ノート内容を表示
    func printInfo(note: Note) {
        switch NoteType.allCases[note.noteType] {
        case .free:
            colorImageView.image = UIImage(systemName: "pin")!
            colorImageView.backgroundColor = UIColor.systemBackground
            colorImageView.layer.borderWidth = 0
            titleLabel.text = note.title
            dateLabel.text = ""
            titleLabelTop.constant = CGFloat(16)
        case .practice:
            let realmManager = RealmManager()
            colorImageView.image = nil
            colorImageView.backgroundColor = realmManager.getGroupColor(noteID: note.noteID)
            if colorImageView.backgroundColor == UIColor.white {
                colorImageView.layer.borderColor = UIColor.systemGray.cgColor
                colorImageView.layer.borderWidth = 0.5
            }
            titleLabel.text = note.detail
            dateLabel.text = formatDate(date: note.date)
            titleLabelTop.constant = CGFloat(8)
        case .tournament:
            let realmManager = RealmManager()
            colorImageView.image = nil
            colorImageView.backgroundColor = realmManager.getGroupColor(noteID: note.noteID)
            if colorImageView.backgroundColor == UIColor.white {
                colorImageView.layer.borderColor = UIColor.systemGray.cgColor
                colorImageView.layer.borderWidth = 0.5
            }
            titleLabel.text = note.target
            dateLabel.text = formatDate(date: note.date)
            titleLabelTop.constant = CGFloat(8)
        }
    }
    
}
