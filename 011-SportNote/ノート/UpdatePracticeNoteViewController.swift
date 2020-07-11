//
//  UpdatePracticeNoteViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/11.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class UpdatePracticeNoteViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 子ビューにnoteDataを渡す
        let targetVC = children[0] as! UpdatePracticeNoteContentViewController
        targetVC.noteData = self.noteData
    }
    

    
    //MARK:- 変数の宣言
    
    // データ格納用
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func saveButton(_ sender: Any) {
        // コンテナからVC2のオブジェクトを取得
        let vc2 = self.children[0] as! UpdatePracticeNoteContentViewController
        
        // 練習ノートデータを保存する
        vc2.saveButton()
    }
    
}
