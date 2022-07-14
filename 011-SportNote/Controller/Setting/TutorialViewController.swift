//
//  TutorialViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2022/06/10.
//  Copyright © 2022 Takatoshi Miura. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {
    
    // MARK: - UI,Variable
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var titleText: String  = ""
    var detailText: String = ""
    var image:UIImage = UIImage(named: "①SportsNoteとは")!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleText
        detailLabel.text = detailText
        imageView.image = image
    }
    
    /// 画面初期化
    /// - Parameters:
    ///    - title: タイトル
    ///    - detail: 説明
    ///    - image: 画像
    func initView(title: String, detail: String, image: UIImage) {
        self.titleText = title
        self.detailText = detail
        self.image = image
    }
    
}
