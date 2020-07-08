//
//  AddPracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/06.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddPracticeNoteViewController: UIViewController, UINavigationControllerDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    //MARK:- UIの設定
    
    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // コンテナからVC2のオブジェクトを取得
        let vc2 = self.children[0] as! AddPracticeNoteContentViewController
        vc2.saveButton()
        
    }
    
    

}
