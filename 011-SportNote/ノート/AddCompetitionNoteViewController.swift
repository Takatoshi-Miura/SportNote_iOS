//
//  AddCompetitionNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/07.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class AddCompetitionNoteViewController: UIViewController,UIScrollViewDelegate {
    
    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CompetitionNoteDetailViewControllerから遷移してきた場合
        if previousControllerName == "CompetitionNoteDetailViewController" {
            // 子ビューにnoteDataを渡す
            let vc = children[0] as! AddCompetitionNoteContentViewController
            vc.competitionNoteData = self.noteData
            vc.previousControllerName = "CompetitionNoteDetailViewController"
            
            // タイトル文字列の設定
            navigationBar.items![0].title = "ノート編集"
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // safeareaInsetsを取得
        bottomPadding = self.view.safeAreaInsets.bottom
        
        // 子ビューにbottomPaddingを渡す
        let vc = children[0] as! AddCompetitionNoteContentViewController
        vc.bottomPadding = self.bottomPadding
    }
 
    
    
    //MARK:- 変数の宣言
    
    var previousControllerName:String = ""  // 前のViewController名
    var noteData = NoteData()               // ノート詳細画面からの遷移用
    var scrollPosition:CGFloat = 0          // スクロール位置
    var bottomPadding:CGFloat = 0           // safearea下側の余白
    
    
    
    //MARK:- UIの設定
    
    // スクロールビュー
    @IBOutlet weak var scrollView: UIScrollView!
    
    // ナビゲーションバー
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    // 保存ボタンの処理
    @IBAction func saveButton(_ sender: Any) {
        // コンテナからVCのオブジェクトを取得
        let vc = self.children[0] as! AddCompetitionNoteContentViewController
        
        // 大会ノートデータを保存する
        vc.saveButton()
    }
    
    
    
    //MARK:- その他のメソッド
    
    // 現在のスクロール位置(最下点)を取得するメソッド
    func getScrollPosition() -> CGFloat {
        return UIScreen.main.bounds.size.height + self.scrollPosition
    }
    
    // スクロールするたびに呼ばれるメソッド
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.scrollPosition = scrollView.contentOffset.y
        
        // スクロールを検知したらPickerを閉じる
        let obj = children[0] as! AddCompetitionNoteContentViewController
        obj.closePicker()
    }
    
}
