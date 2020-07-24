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
        
        // NoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "PracticeNoteDetailViewController" {
            // 子ビューにnoteDataを渡す
            let vc = children[0] as! AddPracticeNoteContentViewController
            vc.practiceNoteData = self.noteData
            vc.previousControllerName = "PracticeNoteDetailViewController"
            
            // タイトル文字列の設定
            navigationBar.items![0].title = "ノートの編集"
            
            // 保存ボタンを有効にする
            self.saveButtonEnable()
        }
    }
    
    
    
    //MARK:- 変数の宣言
    
    var previousControllerName:String = ""  // 前のViewController名
    var noteData = NoteData()               // ノート詳細画面からの遷移用
    
    
    
    //MARK:- UIの設定
    
    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    // ナビゲーションバー
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // 保存ボタン
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // コンテナからVCのオブジェクトを取得
        let vc = self.children[0] as! AddPracticeNoteContentViewController
        
        // 練習ノートデータを保存する
        vc.saveButton()
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
