//
//  AddCompetitionNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddCompetitionNoteViewController: UIViewController {
    
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
        let vc2 = self.children[0] as! AddCompetitionNoteContentViewController
        
        // 大会ノートデータを保存する
        vc2.saveButton()
    }
    
}
