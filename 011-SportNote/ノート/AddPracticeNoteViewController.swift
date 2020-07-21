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
    
    
    
    //MARK:- その他のメソッド
    
    // containerViewの高さをセットするメソッド
    func setContainerViewHeight(height containerViewHeight:CGFloat) {
        // デフォルトの高さより大きい場合、超過分をcontainerViewの高さにプラスする
        if containerViewHeight - 260 > 0 {
            self.containerViewHeight.constant = 1200 + containerViewHeight - 260
        }
    }
    
    // 保存ボタンを有効にするメソッド
    func saveButtonEnable() {
        self.saveButton.isEnabled = true
    }

}
