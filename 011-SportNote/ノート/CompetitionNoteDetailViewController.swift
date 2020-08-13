//
//  ConpetitionNoteDetailViewController.swift
//  011-SportNote
//
//  Created by Takatoshi Miura on 2020/07/15.
//  Copyright © 2020 Takatoshi Miura. All rights reserved.
//

import UIKit

class CompetitionNoteDetailViewController: UIViewController {

    //MARK:- ライフサイクルメソッド
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // タイトル文字列の設定
        setNavigationTitle(title: "\(noteData.getNavigationTitle())\n\(noteData.getNoteType())")
        
        // データを表示
        printNoteData(noteData)
    }
    
    
    
    //MARK:- 変数の宣言
    
    var noteData = NoteData()
    
    
    
    //MARK:- UIの設定
    
    @IBOutlet weak var physicalConditionTextView: UITextView!
    @IBOutlet weak var targetTextView: UITextView!
    @IBOutlet weak var consciousnessTextView: UITextView!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var reflectionTextView: UITextView!
    
    // 編集ボタンの処理
    @IBAction func editButton(_ sender: Any) {
        // 大会記録追加画面に遷移
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddCompetitionNoteViewController") as! AddCompetitionNoteViewController
        
        // ノートデータの受け渡し
        nextView.noteData = self.noteData
        nextView.previousControllerName = "CompetitionNoteDetailViewController"
        
        // 画面遷移
        self.present(nextView, animated: true, completion: nil)
    }
    
    
    
    //MARK:- 画面遷移
    
    // CompetitionNoteDetailViewControllerに戻ったときの処理
    @IBAction func goToCompetitionNoteDetailViewController(_segue:UIStoryboardSegue) {
    }
    
    
    
    //MARK:- その他のメソッド
    
    // テキストビューにnoteDataを表示するメソッド
    func printNoteData(_ noteData:NoteData) {
        // テキストビューに表示
        physicalConditionTextView.text = noteData.getPhysicalCondition()
        targetTextView.text = noteData.getTarget()
        consciousnessTextView.text = noteData.getConsciousness()
        resultTextView.text = noteData.getResult()
        reflectionTextView.text = noteData.getReflection()
    }
    
    // ナビゲーションタイトルをセット
    func setNavigationTitle(title titleText:String) {
        let label = UILabel()
        label.backgroundColor = .clear
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        label.textAlignment = .center
        label.textColor = .systemRed
        label.text = titleText
        self.navigationItem.titleView = label
    }

}
