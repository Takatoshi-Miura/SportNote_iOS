//
//  FirstViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/08/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // チュートリアルデータを表示
        printData()
    }
    
    
    
    //MARK:- 変数の宣言
    
    var titleText:String  = ""
    var detailText:String = ""
    var image:UIImage = UIImage(named: "①概要")!
    
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
    //MARK:- その他のメソッド
    
    // チュートリアルデータを表示するメソッド
    func printData() {
        self.titleLabel.text  = titleText
        self.detailLabel.text = detailText
        self.imageView.image  = image
    }
    
}
