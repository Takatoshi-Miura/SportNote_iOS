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
        setTextColor()
        
        // 同意していないなら利用規約を表示
        if UserDefaults.standard.bool(forKey: "ver1.4") == false {
            displayAgreement()
        }
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
    
    // 文字色を設定するメソッド
    func setTextColor() {
        self.titleLabel.textColor = UIColor.white
        self.detailLabel.textColor = UIColor.white
    }
    
    // 利用規約表示メソッド
    func displayAgreement() {
        // アラートダイアログを生成
        let alertController = UIAlertController(title:"利用規約の更新",message:"本アプリの利用規約とプライバシーポリシーに同意します。",preferredStyle:UIAlertController.Style.alert)
        
        // 同意ボタンを宣言
        let agreeAction = UIAlertAction(title:"同意する",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 同意ボタンがタップされたときの処理
            // 次回以降、利用規約を表示しないようにする
            UserDefaults.standard.set(true, forKey: "ver1.4")
        }
        
        // 利用規約ボタンを宣言
        let termsAction = UIAlertAction(title:"利用規約を読む",style:UIAlertAction.Style.default){(action:UIAlertAction)in
            // 利用規約ボタンがタップされたときの処理
            let url = URL(string: "https://sportnote-b2c92.firebaseapp.com/")
            UIApplication.shared.open(url!)
            
            // アラートが消えるため再度表示
            self.displayAgreement()
        }
        
        // ボタンを追加
        alertController.addAction(termsAction)
        alertController.addAction(agreeAction)
        
        //アラートダイアログを表示
        present(alertController,animated:true,completion:nil)
    }
    
}
