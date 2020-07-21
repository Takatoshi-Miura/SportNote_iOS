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
        
        // 課題データが読み込まれるまで保存ボタンを無効にする
        self.saveButton.isEnabled = false

        // 課題データの読み込みが終わるまで時間待ち
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
        
            // Containerの子配列からAddPracticeNoteContentViewControllerオブジェクトを取得
            let obj = self.children[0] as! AddPracticeNoteContentViewController
        
            // taskTableViewの高さを取得
            let height = obj.taskTableView.contentSize.height
        
            // デフォルトの高さより大きい場合、超過分をcontainerViewの高さにプラスする
            if height - 260 > 0 {
                self.containerViewHeight.constant = 1200 + height - 260
            }
        
            // 保存ボタンを有効にする
            self.saveButton.isEnabled = true
        }
    }
    
    
    
    //MARK:- UIの設定
    
    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    // 保存ボタン
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // コンテナからVC2のオブジェクトを取得
        let vc2 = self.children[0] as! AddPracticeNoteContentViewController
        
        // 練習ノートデータを保存する
        vc2.saveButton()
    }

}
