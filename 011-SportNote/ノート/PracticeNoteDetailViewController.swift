//
//  PracticeNoteDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/24.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class PracticeNoteDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // タイトル文字列の設定
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .systemGreen
        label.text = "\(noteData.getNavigationTitle())\n\(noteData.getNoteType())"
        self.navigationItem.titleView = label
        
        // 子ビューにnoteDataを渡す
        let vc = children[0] as! PracticeNoteContentViewController
        vc.noteData = self.noteData
    }
    
    
    
    //MARK:- 変数の宣言
    
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定

    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        // コンテナからVCのオブジェクトを取得
        let vc = self.children[0] as! PracticeNoteContentViewController
        
        // 編集画面へ遷移
        vc.editButton()
    }
    
    
    //MARK:- その他のメソッド
    
    // containerViewの高さをセットするメソッド
    func setContainerViewHeight(height containerViewHeight:CGFloat) {
        // デフォルトの高さより大きい場合、超過分をcontainerViewの高さにプラスする
        if containerViewHeight - 260 > 0 {
            self.containerViewHeight.constant = 1200 + containerViewHeight - 260
        }
    }
    
}
