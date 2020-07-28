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
 
    
    
    //MARK:- 変数の宣言
    
    var previousControllerName:String = ""  // 前のViewController名
    var noteData = NoteData()               // ノート詳細画面からの遷移用
    
    
    
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
    
}
