//
//  AddPracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/06.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddPracticeNoteViewController: UIViewController, UINavigationControllerDelegate,UIScrollViewDelegate {
    
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
            navigationBar.items![0].title = "ノート編集"
            
            // 保存ボタンを有効にする
            self.saveButtonEnable()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // safeareaInsetsを取得
        bottomPadding = self.view.safeAreaInsets.bottom
        
        // 子ビューにbottomPaddingを渡す
        let vc = children[0] as! AddPracticeNoteContentViewController
        vc.bottomPadding = self.bottomPadding
    }
    
    
    
    //MARK:- 変数の宣言
    
    var previousControllerName:String = ""  // 前のViewController名
    var noteData = NoteData()               // ノート詳細画面からの遷移用
    var scrollPosition:CGFloat = 0          // スクロール位置(初期地点からの移動量)
    var bottomPadding:CGFloat = 0           // safearea下側の余白
    
    
    
    //MARK:- UIの設定
    
    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
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
            self.containerView.layoutIfNeeded()
            self.containerView.updateConstraints()
            self.containerViewHeight.constant = 1000 + containerViewHeight - 260
        }
        self.scrollView.layoutIfNeeded()
        self.scrollView.updateConstraints()
        self.scrollView.contentSize.height = self.containerViewHeight.constant
    }
    
    // 保存ボタンを有効にするメソッド
    func saveButtonEnable() {
        self.saveButton.isEnabled = true
    }
    
    // 現在のスクロール位置(最下点)を取得するメソッド
    func getScrollPosition() -> CGFloat {
        return UIScreen.main.bounds.size.height + self.scrollPosition
    }
    
    // スクロールするたびに呼ばれるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollPosition = scrollView.contentOffset.y
        
        // スクロールを検知したらPickerを閉じる
        let obj = children[0] as! AddPracticeNoteContentViewController
        obj.closePicker()
    }

}
