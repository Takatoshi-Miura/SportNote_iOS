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
    /// - Parameter note: Note
    func printInfo(note: Note) {
        switch NoteType.allCases[note.noteType] {
        case .free:
            self.setColorImageView(image: UIImage(systemName: "pin")!, backgroundColor: UIColor.systemBackground)
            titleLabel.text = note.title
            dateLabel.text = ""
            titleLabelTop.constant = CGFloat(16)
        case .practice:
            let realmManager = RealmManager()
            Task {
                let groupColor = await realmManager.getGroupColor(noteID: note.noteID)
                DispatchQueue.main.async {
                    self.setColorImageView(image: nil, backgroundColor: groupColor)
                    self.titleLabel.text = note.detail
                    self.dateLabel.text = formatDate(date: note.date, format: "yyyy/M/d (E)")
                    self.titleLabelTop.constant = CGFloat(8)
                }
            }
        case .tournament:
            let realmManager = RealmManager()
            Task {
                let groupColor = await realmManager.getGroupColor(noteID: note.noteID)
                DispatchQueue.main.async {
                    self.setColorImageView(image: nil, backgroundColor: groupColor)
                    self.titleLabel.text = note.result
                    self.dateLabel.text = formatDate(date: note.date, format: "yyyy/M/d (E)")
                    self.titleLabelTop.constant = CGFloat(8)
                }
            }
        }
    }
    
    /// ColorImageViewの設定
    /// - Parameter image: アイコン画像
    /// - Parameter backgroundColor: UIColor
    private func setColorImageView(image: UIImage?, backgroundColor: UIColor) {
        colorImageView.image = image
        colorImageView.backgroundColor = backgroundColor
        // 白色の場合は枠線をつける
        if backgroundColor == UIColor.white {
            colorImageView.layer.borderColor = UIColor.systemGray.cgColor
            colorImageView.layer.borderWidth = 0.5
        }
    }
    
}
